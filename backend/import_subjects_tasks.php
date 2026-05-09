<?php
/**
 * Import Subjects and Tasks from CSV
 * Parses ICSE curriculum CSV and inserts into database
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/Database.php';
require_once __DIR__ . '/Response.php';

ini_set('display_errors', 1);
error_reporting(E_ALL);

$db = Database::getInstance();

// File path - adjust if needed
$csvFile = __DIR__ . '/../uploads/ICSE 10TH & 9TH PORTION FILE FINAL( IC 10 ).csv';

if (!file_exists($csvFile)) {
    die("❌ CSV file not found at: $csvFile\n");
}

echo "🔄 Starting CSV import...\n";
echo "📄 File: $csvFile\n";

// Read CSV
$file = fopen($csvFile, 'r');
$lines = [];
while (($line = fgetcsv($file)) !== FALSE) {
    $lines[] = $line;
}
fclose($file);

echo "📊 Total lines: " . count($lines) . "\n\n";

// Variables to track data
$currentBatch = null;
$currentSubject = null;
$subjectId = null;
$insertedTopics = 0;
$insertedTasks = 0;
$insertedSubjects = 0;

// Parse the CSV
for ($i = 0; $i < count($lines); $i++) {
    $line = $lines[$i];
    
    // Skip empty lines
    if (empty($line[0]) && empty($line[1])) {
        continue;
    }
    
    // Extract batch from first column (e.g., "STD - 10 ICSE")
    if (strpos($line[0] ?? '', 'STD') !== false) {
        preg_match('/STD[^0-9]*(\d+)\s*([A-Z]+)/', $line[0], $matches);
        if (!empty($matches)) {
            $standard = $matches[1];
            $board = $matches[2];
            $currentBatch = "$board $standard";
            echo "📚 Found Batch: $currentBatch\n";
        }
        continue;
    }
    
    // Subject header row (contains TASK 1, TASK 2, etc.)
    if (!empty($line[1]) && strpos($line[1], 'TASK') === false && 
        !is_numeric($line[0]) && !empty($line[1])) {
        
        // This is a subject header row if the second column is a subject name
        if (strpos(implode(',', $line), 'TASK') !== false) {
            $currentSubject = trim($line[1]);
            
            // Check if subject already exists
            $existingSubject = $db->fetchOne(
                "SELECT id FROM subjects WHERE name = '{$db->escape($currentSubject)}' 
                 AND batch = '{$db->escape($currentBatch)}' LIMIT 1"
            );
            
            if ($existingSubject) {
                $subjectId = $existingSubject['id'];
                echo "  ✅ Subject exists: $currentSubject\n";
            } else {
                // Insert subject
                $subjectInsert = "INSERT INTO subjects 
                                 (id, name, description, batch, is_active, created_at, updated_at)
                                 VALUES (
                                     UUID(),
                                     '{$db->escape($currentSubject)}',
                                     'Auto-imported from CSV',
                                     '{$db->escape($currentBatch)}',
                                     TRUE,
                                     NOW(),
                                     NOW()
                                 )";
                
                if ($db->execute($subjectInsert)) {
                    $subjectId = $db->getLastInsertId();
                    $insertedSubjects++;
                    echo "  ✨ Inserted subject: $currentSubject\n";
                } else {
                    echo "  ❌ Failed to insert subject: $currentSubject\n";
                    continue;
                }
            }
        }
        continue;
    }
    
    // Data row (Topic with tasks)
    if (is_numeric($line[0] ?? null) && !empty($line[1]) && !empty($currentBatch)) {
        $topicNumber = trim($line[0]);
        $topicName = trim($line[1]);
        
        echo "\n  📖 Topic $topicNumber: $topicName\n";
        
        // Check if topic already exists
        $existingTopic = $db->fetchOne(
            "SELECT id FROM topics WHERE title = '{$db->escape($topicName)}' 
             AND subject_id = (SELECT id FROM subjects WHERE name = '{$db->escape($currentSubject)}' 
                               AND batch = '{$db->escape($currentBatch)}' LIMIT 1) LIMIT 1"
        );
        
        if ($existingTopic) {
            $topicId = $existingTopic['id'];
            echo "    ✅ Topic exists\n";
        } else {
            // Insert topic
            $topicInsert = "INSERT INTO topics 
                           (id, subject_id, title, description, order_index, created_at, updated_at)
                           VALUES (
                               UUID(),
                               (SELECT id FROM subjects WHERE name = '{$db->escape($currentSubject)}' 
                                AND batch = '{$db->escape($currentBatch)}' LIMIT 1),
                               '{$db->escape($topicName)}',
                               'Auto-imported from CSV',
                               $topicNumber,
                               NOW(),
                               NOW()
                           )";
            
            if ($db->execute($topicInsert)) {
                $insertedTopics++;
                echo "    ✨ Inserted topic\n";
                
                // Get the inserted topic ID
                $topicId = $db->fetchValue(
                    "SELECT id FROM topics WHERE title = '{$db->escape($topicName)}' 
                     AND subject_id = (SELECT id FROM subjects WHERE name = '{$db->escape($currentSubject)}' 
                                       AND batch = '{$db->escape($currentBatch)}' LIMIT 1) 
                     ORDER BY created_at DESC LIMIT 1"
                );
            } else {
                echo "    ❌ Failed to insert topic\n";
                continue;
            }
        }
        
        // Insert the 13 tasks for this topic
        for ($taskNum = 2; $taskNum <= 14; $taskNum++) {
            $taskTitle = !empty(trim($line[$taskNum] ?? '')) ? trim($line[$taskNum]) : null;
            
            if (empty($taskTitle)) {
                continue; // Skip empty tasks
            }
            
            // Check if task already exists
            $existingTask = $db->fetchOne(
                "SELECT id FROM tasks WHERE topic_id = '$topicId' 
                 AND order_index = " . ($taskNum - 1) . " LIMIT 1"
            );
            
            if (!$existingTask) {
                $taskInsert = "INSERT INTO tasks 
                              (id, topic_id, title, order_index, created_at, updated_at)
                              VALUES (
                                  UUID(),
                                  '$topicId',
                                  '{$db->escape($taskTitle)}',
                                  " . ($taskNum - 1) . ",
                                  NOW(),
                                  NOW()
                              )";
                
                if ($db->execute($taskInsert)) {
                    $insertedTasks++;
                    echo "      ✅ Task " . ($taskNum - 1) . ": $taskTitle\n";
                }
            }
        }
    }
}

echo "\n" . str_repeat("=", 60) . "\n";
echo "✅ IMPORT COMPLETED!\n";
echo str_repeat("=", 60) . "\n";
echo "📊 Summary:\n";
echo "   - Subjects inserted: $insertedSubjects\n";
echo "   - Topics inserted: $insertedTopics\n";
echo "   - Tasks inserted: $insertedTasks\n";
echo "\n";

// Now create student_progress records for all students
echo "🔗 Creating student_progress records...\n";

// Get all tasks
$allTasks = $db->fetchAll(
    "SELECT t.id, s.batch FROM tasks t
     JOIN topics tp ON t.topic_id = tp.id
     JOIN subjects s ON tp.subject_id = s.id"
);

// Get all students
$allStudents = $db->fetchAll(
    "SELECT id, batch FROM students WHERE batch IS NOT NULL"
);

$progressInserted = 0;

foreach ($allStudents as $student) {
    foreach ($allTasks as $task) {
        // Only create progress for matching batch
        if ($student['batch'] === $task['batch']) {
            // Check if already exists
            $exists = $db->fetchOne(
                "SELECT id FROM student_progress WHERE student_id = '{$student['id']}' 
                 AND task_id = '{$task['id']}' LIMIT 1"
            );
            
            if (!$exists) {
                $progressInsert = "INSERT INTO student_progress 
                                  (id, student_id, task_id, is_completed, created_at, updated_at)
                                  VALUES (
                                      UUID(),
                                      '{$student['id']}',
                                      '{$task['id']}',
                                      FALSE,
                                      NOW(),
                                      NOW()
                                  )";
                
                if ($db->execute($progressInsert)) {
                    $progressInserted++;
                }
            }
        }
    }
}

echo "✅ Student progress records created: $progressInserted\n";
echo "\n🎉 All done! Students and tasks are now linked and ready to use.\n";

?>
