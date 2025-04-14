-- 为 response_details 表添加 answer_values 列
ALTER TABLE response_details
ADD COLUMN IF NOT EXISTS answer_values text[];

-- 更新现有记录的 answer_values 列
UPDATE response_details
SET answer_values = ARRAY[answer_value]
WHERE answer_value IS NOT NULL;

-- 添加非空约束
ALTER TABLE response_details
ALTER COLUMN answer_values SET NOT NULL; 