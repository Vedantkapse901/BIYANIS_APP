-- Check what's in the database for order_index values

-- Show Chemistry chapters with their order_index
SELECT
  chapter_name,
  order_index,
  data_type
FROM chapters
WHERE batch = 'ICSE 10'
  AND (chapter_name LIKE '%ACID%'
       OR chapter_name LIKE '%ANALYTICAL%'
       OR chapter_name LIKE '%AMMONIA%'
       OR chapter_name LIKE '%NITRIC%'
       OR chapter_name LIKE '%SULPHURIC%')
ORDER BY chapter_name;

-- Check the data type of order_index column
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'chapters' AND column_name = 'order_index';

-- Show ALL Chemistry chapter order indices
SELECT
  chapter_name,
  order_index,
  LENGTH(order_index::text) as text_length
FROM chapters
WHERE batch = 'ICSE 10' AND subject_id = 'c60c4ac3-a762-49d7-ab64-f128dbaf5f02'
ORDER BY chapter_name;
