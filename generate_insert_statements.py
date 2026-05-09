#!/usr/bin/env python3
"""
Generate SQL INSERT statements from ICSE10_chapters_TEXT_orderindex.csv
This creates a complete SQL script to import all 146 chapters with embedded tasks
"""

import csv
import sys

def escape_sql_string(s):
    """Escape single quotes in SQL strings"""
    if s is None or s == '':
        return "NULL"
    s = str(s).strip()
    if s == '':
        return "NULL"
    # Escape single quotes by doubling them
    s = s.replace("'", "''")
    return f"'{s}'"

def generate_insert_statements(csv_file):
    """Read CSV and generate INSERT statements"""

    insert_statements = []
    row_count = 0

    try:
        with open(csv_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)

            for row in reader:
                row_count += 1

                # Extract values
                subject_id = row['subject_id'].strip()
                chapter_name = row['chapter_name'].strip()
                order_index = row['order_index'].strip()
                batch = row['batch'].strip()

                # Extract task columns
                tasks = []
                for i in range(1, 14):
                    task_key = f'task_{i}'
                    task_value = row.get(task_key, '').strip()
                    tasks.append(escape_sql_string(task_value))

                # Build the VALUES clause
                values_clause = f"""({escape_sql_string(subject_id)}, {escape_sql_string(chapter_name)}, {escape_sql_string(order_index)}, {escape_sql_string(batch)}, {', '.join(tasks)}, NOW(), NOW())"""

                insert_statements.append(values_clause)

                if row_count % 20 == 0:
                    print(f"Processed {row_count} chapters...", file=sys.stderr)

    except Exception as e:
        print(f"Error reading CSV: {e}", file=sys.stderr)
        return None

    return insert_statements, row_count

def main():
    csv_file = '/sessions/nifty-epic-ride/mnt/LOGBOOK_APP-main/ICSE10_chapters_TEXT_orderindex.csv'

    print(f"Reading {csv_file}...", file=sys.stderr)

    result = generate_insert_statements(csv_file)

    if result is None:
        print("Failed to read CSV file", file=sys.stderr)
        return

    insert_statements, row_count = result

    # Write to SQL file
    output_file = '/sessions/nifty-epic-ride/mnt/LOGBOOK_APP-main/IMPORT_ICSE10_EMBEDDED_TASKS.sql'

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("""-- AUTO-GENERATED: Import ICSE 10 Chapters with Embedded Tasks
-- Generated from ICSE10_chapters_TEXT_orderindex.csv
-- Total chapters: """ + str(row_count) + """

-- Delete old ICSE 10 data first
DELETE FROM chapters WHERE batch = 'ICSE 10';

-- Insert all ICSE 10 chapters with embedded tasks
INSERT INTO chapters (subject_id, title, order_index, batch, task_1, task_2, task_3, task_4, task_5, task_6, task_7, task_8, task_9, task_10, task_11, task_12, task_13, created_at, updated_at)
VALUES
""")

        # Write all INSERT statements
        for i, statement in enumerate(insert_statements, 1):
            if i < len(insert_statements):
                f.write(statement + ",\n")
            else:
                f.write(statement + ";\n")

        # Add verification queries
        f.write("""
-- Verification queries
SELECT COUNT(*) as total_imported FROM chapters WHERE batch = 'ICSE 10';

SELECT
  COUNT(*) FILTER (WHERE task_1 IS NOT NULL AND task_1 != '') as with_task_1,
  COUNT(*) FILTER (WHERE task_2 IS NOT NULL AND task_2 != '') as with_task_2,
  COUNT(*) FILTER (WHERE task_3 IS NOT NULL AND task_3 != '') as with_task_3,
  COUNT(*) FILTER (WHERE task_4 IS NOT NULL AND task_4 != '') as with_task_4,
  COUNT(*) FILTER (WHERE task_5 IS NOT NULL AND task_5 != '') as with_task_5,
  COUNT(*) FILTER (WHERE task_6 IS NOT NULL AND task_6 != '') as with_task_6,
  COUNT(*) FILTER (WHERE task_7 IS NOT NULL AND task_7 != '') as with_task_7,
  COUNT(*) FILTER (WHERE task_8 IS NOT NULL AND task_8 != '') as with_task_8,
  COUNT(*) FILTER (WHERE task_9 IS NOT NULL AND task_9 != '') as with_task_9,
  COUNT(*) FILTER (WHERE task_10 IS NOT NULL AND task_10 != '') as with_task_10,
  COUNT(*) FILTER (WHERE task_11 IS NOT NULL AND task_11 != '') as with_task_11,
  COUNT(*) FILTER (WHERE task_12 IS NOT NULL AND task_12 != '') as with_task_12,
  COUNT(*) FILTER (WHERE task_13 IS NOT NULL AND task_13 != '') as with_task_13
FROM chapters WHERE batch = 'ICSE 10';

-- Sample output
SELECT
  title as chapter_name,
  order_index,
  ARRAY[task_1, task_2, task_3, task_4, task_5, task_6, task_7, task_8, task_9, task_10, task_11, task_12, task_13] as tasks
FROM chapters
WHERE batch = 'ICSE 10'
LIMIT 10;
""")

    print(f"\n✓ Generated SQL file: {output_file}", file=sys.stderr)
    print(f"✓ Total chapters to import: {row_count}", file=sys.stderr)
    print(f"\nNow you can:", file=sys.stderr)
    print(f"1. Run IMPORT_ICSE10_EMBEDDED_TASKS.sql in Supabase SQL Editor", file=sys.stderr)
    print(f"2. Or upload ICSE10_chapters_TEXT_orderindex.csv via Supabase UI", file=sys.stderr)

if __name__ == '__main__':
    main()
