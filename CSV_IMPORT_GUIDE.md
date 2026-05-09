# ✅ CORRECT CSV IMPORT STRUCTURE

## Table Hierarchy

```
SUBJECTS (13 subjects)
    ↓
CHAPTERS (groups/books per subject)
    ↓
TOPICS (individual topics within chapters)
    ↓
TASKS (13 tasks per topic)
```

---

## 1️⃣ SUBJECTS TABLE

**Required Columns:**
- name (TEXT) - Subject name
- description (TEXT) - Optional
- color (TEXT) - Hex color
- icon (TEXT) - Emoji
- batch (TEXT) - ICSE 10 (REQUIRED)
- branch (TEXT) - Optional
- is_active (BOOLEAN) - true/false

**CSV Format:**
```csv
name,description,color,icon,batch,branch,is_active,created_at,updated_at
PHYSICS,Learn physics,#FF6B6B,🔬,ICSE 10,Thane,true,2026-05-04T18:32:52Z,2026-05-04T18:32:52Z
CHEMISTRY,Learn chemistry,#4ECDC4,⚗️,ICSE 10,Thane,true,2026-05-04T18:32:52Z,2026-05-04T18:32:52Z
```

---

## 2️⃣ CHAPTERS TABLE

**Required Columns:**
- subject_id (UUID) - From SUBJECTS table
- title (TEXT) - Chapter name
- order_index (INT) - Chapter order

**Note:** For your CSV, chapters = subject groups (like "PHYSICS" is one chapter per subject for now)

**CSV Format:**
```csv
subject_id,title,order_index,created_at,updated_at
<PHYSICS_UUID>,PHYSICS Chapters,1,2026-05-04T18:32:52Z,2026-05-04T18:32:52Z
<CHEMISTRY_UUID>,CHEMISTRY Chapters,1,2026-05-04T18:32:52Z,2026-05-04T18:32:52Z
```

---

## 3️⃣ TOPICS TABLE

**Required Columns:**
- chapter_id (UUID) - From CHAPTERS table
- title (TEXT) - Topic name
- description (TEXT) - Optional
- order_index (INT) - Topic order

**CSV Format:**
```csv
chapter_id,title,description,order_index,created_at,updated_at
<CHAPTER_UUID>,FORCE,Learn about force,1,2026-05-04T18:32:52Z,2026-05-04T18:32:52Z
<CHAPTER_UUID>,WORK & ENERGY,Learn about work,2,2026-05-04T18:32:52Z,2026-05-04T18:32:52Z
```

---

## 4️⃣ TASKS TABLE

**Required Columns:**
- topic_id (UUID) - From TOPICS table
- title (TEXT) - Task name
- order_index (INT) - Task order (1-13)

**CSV Format:**
```csv
topic_id,title,order_index,created_at,updated_at
<TOPIC_UUID>,TEXTBOOK READING,1,2026-05-04T18:32:52Z,2026-05-04T18:32:52Z
<TOPIC_UUID>,SOLVED EXAMPLES,2,2026-05-04T18:32:52Z,2026-05-04T18:32:52Z
```

---

## 📋 IMPORT ORDER (IMPORTANT!)

1. ✅ **SUBJECTS first** - Gets UUID for each subject
2. ✅ **CHAPTERS second** - Uses subject_id from SUBJECTS
3. ✅ **TOPICS third** - Uses chapter_id from CHAPTERS
4. ✅ **TASKS last** - Uses topic_id from TOPICS

---

## ⚠️ THE CHALLENGE

Your original CSV doesn't have a "CHAPTERS" level. So you need to:

**Option A:** Create one chapter per subject (simplest)
- PHYSICS subject → 1 PHYSICS chapter → 12 topics → 8-10 tasks each

**Option B:** Create multiple chapters per subject (more complex)
- PHYSICS subject → CHAPTERS (Mechanics, Optics, Electricity...) → topics → tasks

**Which option do you prefer?**

---

## Next Steps

Tell me:
1. Option A or B?
2. Should I generate all 4 CSV files with the correct structure?
3. Do you want me to map your topics to chapters automatically?

