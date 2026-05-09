#!/usr/bin/env python3
"""
Transform ICSE Curriculum CSV into Supabase-compatible CSVs
Splits one CSV into: subjects.csv, topics.csv, tasks.csv
"""

import csv
import sys
from datetime import datetime
from pathlib import Path
import uuid

def generate_uuid():
    """Generate a UUID string"""
    return str(uuid.uuid4())

def parse_csv(filepath):
    """Parse the input CSV file"""
    subjects_data = {}
    current_batch = None
    current_subject = None
    
    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        lines = list(reader)
    
    print(f"📖 Parsing {len(lines)} lines from CSV...")
    
    for i, line in enumerate(lines):
        # Skip empty lines
        if not line or (len(line) < 2 and not line[0]):
            continue
        
        # Extract batch (STD - 10 ICSE)
        if line[0] and 'STD' in line[0]:
            import re
            match = re.search(r'STD[^0-9]*(\d+)[^A-Z]*([A-Z]+)', line[0])
            if match:
                standard = match.group(1)
                board = match.group(2)
                current_batch = f"{board} {standard}"
                print(f"  ✓ Found batch: {current_batch}")
            continue
        
        # Extract subject header (contains TASK columns)
        if not line[0].isdigit() and len(line) > 1 and line[1] and 'TASK' in ' '.join(line[2:]):
            current_subject = line[1].strip()
            if current_batch not in subjects_data:
                subjects_data[current_batch] = {}
            
            if current_subject not in subjects_data[current_batch]:
                subjects_data[current_batch][current_subject] = {
                    'id': generate_uuid(),
                    'topics': []
                }
                print(f"  ✓ Found subject: {current_subject}")
            continue
        
        # Extract topic data
        if line[0].strip().isdigit() and current_batch and current_subject:
            topic_num = int(line[0].strip())
            topic_name = line[1].strip() if len(line) > 1 else ""
            
            if not topic_name:
                continue
            
            topic_obj = {
                'id': generate_uuid(),
                'number': topic_num,
                'name': topic_name,
                'tasks': []
            }
            
            # Extract tasks (columns 2-14 = 13 tasks)
            for task_idx in range(2, min(15, len(line))):
                task_title = line[task_idx].strip() if task_idx < len(line) else ""
                if task_title:
                    task_obj = {
                        'id': generate_uuid(),
                        'title': task_title,
                        'order': task_idx - 1
                    }
                    topic_obj['tasks'].append(task_obj)
            
            subjects_data[current_batch][current_subject]['topics'].append(topic_obj)
            print(f"    → Topic: {topic_name} ({len(topic_obj['tasks'])} tasks)")
    
    return subjects_data

def write_subjects_csv(subjects_data, output_dir):
    """Write subjects CSV"""
    filepath = output_dir / 'subjects_for_import.csv'
    
    with open(filepath, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'name', 'batch', 'description', 'is_active', 'created_at', 'updated_at'])
        
        # Map to keep track of subject names to IDs
        subject_map = {}
        
        for batch, subjects in subjects_data.items():
            for subject_name, subject_data in subjects.items():
                subject_id = subject_data['id']
                subject_map[f"{batch}|{subject_name}"] = subject_id
                
                writer.writerow([
                    subject_id,
                    subject_name,
                    batch,
                    'Imported from curriculum CSV',
                    'true',
                    datetime.now().isoformat(),
                    datetime.now().isoformat()
                ])
    
    print(f"\n✅ Created: {filepath}")
    return subject_map

def write_topics_csv(subjects_data, subject_map, output_dir):
    """Write topics CSV"""
    filepath = output_dir / 'topics_for_import.csv'
    
    with open(filepath, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'subject_id', 'title', 'order_index', 'description', 'created_at', 'updated_at'])
        
        # Map to keep track of topic names to IDs
        topic_map = {}
        
        for batch, subjects in subjects_data.items():
            for subject_name, subject_data in subjects.items():
                subject_id = subject_data['id']
                
                for topic in subject_data['topics']:
                    topic_id = topic['id']
                    topic_key = f"{batch}|{subject_name}|{topic['name']}"
                    topic_map[topic_key] = topic_id
                    
                    writer.writerow([
                        topic_id,
                        subject_id,
                        topic['name'],
                        topic['number'],
                        'Imported from curriculum CSV',
                        datetime.now().isoformat(),
                        datetime.now().isoformat()
                    ])
    
    print(f"✅ Created: {filepath}")
    return topic_map

def write_tasks_csv(subjects_data, topic_map, output_dir):
    """Write tasks CSV"""
    filepath = output_dir / 'tasks_for_import.csv'
    
    with open(filepath, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'topic_id', 'title', 'order_index', 'created_at', 'updated_at'])
        
        for batch, subjects in subjects_data.items():
            for subject_name, subject_data in subjects.items():
                for topic in subject_data['topics']:
                    topic_key = f"{batch}|{subject_name}|{topic['name']}"
                    topic_id = topic_map[topic_key]
                    
                    for task in topic['tasks']:
                        writer.writerow([
                            task['id'],
                            topic_id,
                            task['title'],
                            task['order'],
                            datetime.now().isoformat(),
                            datetime.now().isoformat()
                        ])
    
    print(f"✅ Created: {filepath}")

def main():
    # Input file
    if len(sys.argv) < 2:
        input_csv = "uploads/ICSE 10TH & 9TH PORTION FILE FINAL( IC 10 ).csv"
    else:
        input_csv = sys.argv[1]
    
    input_path = Path(input_csv)
    
    if not input_path.exists():
        print(f"❌ Error: File not found: {input_csv}")
        sys.exit(1)
    
    # Output directory
    output_dir = Path('supabase_import_csvs')
    output_dir.mkdir(exist_ok=True)
    
    print("\n" + "="*70)
    print("🔄 TRANSFORMING ICSE CSV FOR SUPABASE IMPORT")
    print("="*70 + "\n")
    
    print(f"📂 Input: {input_path}")
    print(f"📁 Output directory: {output_dir}\n")
    
    # Parse the CSV
    subjects_data = parse_csv(input_path)
    
    print(f"\n📊 Summary:")
    total_subjects = sum(len(subjects) for subjects in subjects_data.values())
    total_topics = sum(len(topic) for batch_subjects in subjects_data.values() 
                      for subject_data in batch_subjects.values() 
                      for topic in subject_data['topics'])
    total_tasks = sum(len(task) for batch_subjects in subjects_data.values() 
                     for subject_data in batch_subjects.values() 
                     for topic in subject_data['topics']
                     for task in topic['tasks'])
    
    print(f"  - Batches: {len(subjects_data)}")
    print(f"  - Subjects: {total_subjects}")
    print(f"  - Topics: {total_topics}")
    print(f"  - Tasks: {total_tasks}\n")
    
    # Write CSV files
    print("📝 Writing CSV files...\n")
    subject_map = write_subjects_csv(subjects_data, output_dir)
    topic_map = write_topics_csv(subjects_data, subject_map, output_dir)
    write_tasks_csv(subjects_data, topic_map, output_dir)
    
    print("\n" + "="*70)
    print("✅ TRANSFORMATION COMPLETE!")
    print("="*70 + "\n")
    
    print("📂 Files created in 'supabase_import_csvs' folder:")
    print("  1. subjects_for_import.csv")
    print("  2. topics_for_import.csv")
    print("  3. tasks_for_import.csv\n")
    
    print("📲 Next steps:")
    print("  1. Open Supabase dashboard: https://app.supabase.com")
    print("  2. Go to 'subjects' table → Import CSV → subjects_for_import.csv")
    print("  3. Note down the subject IDs")
    print("  4. Go to 'topics' table → Import CSV → topics_for_import.csv")
    print("  5. Go to 'tasks' table → Import CSV → tasks_for_import.csv")
    print("  6. Run SQL to create student_progress records\n")

if __name__ == '__main__':
    main()
