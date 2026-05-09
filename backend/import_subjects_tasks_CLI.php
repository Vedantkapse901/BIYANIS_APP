<?php
/**
 * Import Subjects and Tasks from CSV - CLI Version
 * Run: php backend/import_subjects_tasks_CLI.php /path/to/csv/file.csv
 */

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/Database.php';

$db = Database::getInstance();

// Get CSV file path from command line argument
$csvFile = $argc > 1 ? $argv[1] : __DIR__ . '/../uploads/ICSE 10TH & 9TH PORTION FILE FINAL( IC 10 ).csv';

if (!file_exists($csvFile)) {
    echo "❌ ERROR: CSV file not found at: $csvFile\n";
    exit(1);
}

echo "\n" . str_repeat("=", 70) . "\n";
echo "📚 ICSE CURRICULUM IMPORT TOOL\n";
echo str_repeat("=", 70) . "\n\n";
echo "📄 CSV File: $csvFile\n";
echo "📊 File Size: " . filesize($csvFile) . " bytes\n";

// Read CSV
$file = fopen($csvFile, 'r');
$lines = [];
while (($line = fgetcsv($file, 2000, ',')) !== FALSE) {
    $lines[] = $line;
}
fclose($file);

echo "📋 Total lines read: " . count($lines) . "\n\n";

// Statistics
$stats = [
    'subjects' => 0,
    'topics' => 0,
    'tasks' => 0,
    'progress' => 0,
    'errors' => 0
];

$currentBatch = null;
$currentSubject = null;
$subjectId = null;

// Parse the CSV
for ($i = 0; $i < count($lines); $i++) {
    $line = $lines[$i];
    
    // Trim all fields
    $line = array_map('trim', $line);
    
    // Skip empty lines
    if (empty($line[0]) && (empty($line[1]) || !is_numeric($line[0]))) {
        continue;
    }
    
    // ========== EXTRACT BATCH ==========
    if (strpos($line[0], 'STD') !== false) {
        // Parse batch line: "STD - 10 ICSE" or "STD - 9 ICSE"
        if (preg_match('/STD[^0-9]*(\d+)[^A-Z]*([A-Z]+)/', $line[0], $matches)) {
            $standard = $matches[1];
            $board = $matches[2];
            $currentBatch = "$board $standard";
            echo "✨ Found Batch: $currentBatch\n";
        }
        continue;
    }
    
    // ========== SUBJECT HEADER ROW ==========
    if (!empty($line[1]) && !is_numeric($line[0])) {
        // Check if this line contains "TASK 1", "TASK 2", etc. - if so, it's a subject header
        $isSubjectHeader = false;
        for ($j = 2; $j < count($line); $j++) {
            if (strpos($line[$j], 'TASK') !== false) {
                $isSubjectHeader = true;
                break;
            }
        }
        
        if ($isSubjectHeader) {
            $currentSubject = $line[1];
            
            // Check if subject exists
            $sql = "SELECT id FROM subjects WHERE name = '{$db->escape($currentSubject)}' 
                    AND batch = '{$db->escape($currentBatch)}' LIMIT 1";
            $existing = $db->fetchOne($sql);
            
            if ($existing) {
                $subjectId = $existing['id'];
                echo "  ✅ Subject exists: $currentSubject\n";
            } else {
                // Insert subject
                $sql = "INSERT INTO subjects (id, name, description, batch, is_active, created_at, updated_at)
                        VALUES (UUID(), '{$db->escape($currentSubject)}', 'Imported from CSV', '{$db->escape($currentBatch)}', 1, NOW(), NOW())";
                
                if ($db->execute($sql)) {
                    // Fetch the inserted ID
                    $result = $db->fetchOne("SELECT id FROM subjects WHERE name = '{$db->escape($currentSubject)}' 
                                           AND batch = '{$db->escape($currentBatch)}' ORDER BY created_at DESC LIMIT 1");
                    $subjectId = $result['id'];
                    $stats['subjects']++;
                    echo "  ✨ Inserted: $currentSubject\n";
                } else {
                    echo "  ❌ Failed to insert: $currentSubject\n";
                    $stats['errors']++;
                    continue;
                }
            }
        }
        continue;
    }
    
    // ========== TOPIC DATA ROW ==========
    if (is_numeric($line[0]) && !empty($line[1]) && !empty($currentBatch) && !empty($subjectId)) {
        $topicNumber = (int)$line[0];
        $topicName = $line[1];
        
        // Check if topic exists
        $sql = "SELECT id FROM topics WHERE title = '{$db->escape($topicName)}' 
                AND subject_id = '$subjectId' LIMIT 1";
        $existing = $db->fetchOne($sql);
        
        if ($existing) {
            $topicId = $existing['id'];
            echo "    ✅ Topic: $topicName\n";
        } else {
            // Insert topic
            $sql = "INSERT INTO topics (id, subject_id, title, description, order_index, created_at, updated_at)
                    VALUES (UUID(), '$subjectId', '{$db->escape($topicName)}', 'Imported from CSV', $topicNumber, NOW(), NOW())";
            
            if ($db->execute($sql)) {
                // Fetch the inserted ID
                $result = $db->fetchOne("SELECT id FROM topics WHERE title = '{$db->escape($topicName)}' 
                                       AND subject_id = '$subjectId' ORDER BY created_at DESC LIMIT 1");
                $topicId = $result['id'];
                $stats['topics']++;
                echo "    ✨ Topic: $topicName\n";
            } else {
                echo "    ❌ Failed to insert topic: $topicName\n";
                $stats['errors']++;
                continue;
            }
        }
        
        // ========== INSERT TASKS (13 columns) ==========
        for ($taskNum = 1; $taskNum <= 13; $taskNum++) {
            $taskTitle = !empty($line[$taskNum + 1]) ? $line[$taskNum + 1] : null;
            
            if (empty($taskTitle)) {
                continue; // Skip empty tasks
            }
            
            // Check if task exists
            $sql = "SELECT id FROM tasks WHERE topic_id = '$topicId' AND order_index = $taskNum LIMIT 1";
            $existing = $db->fetchOne($sql);
            
            if (!$existing) {
                $sql = "INSERT INTO tasks (id, topic_id, title, order_index, created_at, updated_at)
                        VALUES (UUID(), '$topicId', '{$db->escape($taskTitle)}', $taskNum, NOW(), NOW())";
                
                if ($db->execute($sql)) {
                    $stats['tasks']++;
                    echo "      ✅ Task $taskNum: $taskTitle\n";
                } else {
                    echo "      ❌ Failed to insert task: $taskTitle\n";
                    $stats['errors']++;
                }
            }
        }
    }
}

echo "\n" . str_repeat("=", 70) . "\n";
echo "📊 IMPORT SUMMARY\n";
echo str_repeat("=", 70) . "\n";
echo "✅ Subjects inserted: " . $stats['subjects'] . "\n";
echo "✅ Topics inserted: " . $stats['topics'] . "\n";
echo "✅ Tasks inserted: " . $stats['tasks'] . "\n";
echo "❌ Errors: " . $stats['errors'] . "\n";

// Create student_progress records
echo "\n🔗 Creating student_progress records...\n";

$allTasks = $db->fetchAll(
    "SELECT t.id, s.batch FROM tasks t
     JOIN topics tp ON t.topic_id = tp.id
     JOIN subjects s ON tp.subject_id = s.id"
);

$allStudents = $db->fetchAll(
    "SELECT id, batch FROM students WHERE batch IS NOT NULL"
);

foreach ($allStudents as $student) {
    foreach ($allTasks as $task) {
        if ($student['batch'] === $task['batch']) {
            $existing = $db->fetchOne(
                "SELECT id FROM student_progress WHERE student_id = '{$student['id']}' 
                 AND task_id = '{$task['id']}' LIMIT 1"
            );
            
            if (!$existing) {
                $sql = "INSERT INTO student_progress (id, student_id, task_id, is_completed, created_at, updated_at)
                        VALUES (UUID(), '{$student['id']}', '{$task['id']}', 0, NOW(), NOW())";
                
                if ($db->execute($sql)) {
                    $stats['progress']++;
                }
            }
        }
    }
}

echo "✅ Student progress records created: " . $stats['progress'] . "\n";
echo "\n🎉 Import completed successfully!\n";
echo str_repeat("=", 70) . "\n\n";

?>
