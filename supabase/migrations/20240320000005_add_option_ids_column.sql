-- 为 response_details 表添加 option_ids 列
ALTER TABLE response_details
ADD COLUMN IF NOT EXISTS option_ids text[];

-- 更新现有记录的 option_ids 列
UPDATE response_details
SET option_ids = ARRAY[option_id]
WHERE option_id IS NOT NULL;

-- 移除 option_id 列的非空约束（如果存在）
ALTER TABLE response_details
ALTER COLUMN option_id DROP NOT NULL; 