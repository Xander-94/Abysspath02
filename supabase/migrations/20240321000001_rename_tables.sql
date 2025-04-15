-- 重命名学习路径表
ALTER TABLE IF EXISTS learning_paths RENAME TO learning_path_history;

-- 重命名学习任务表
ALTER TABLE IF EXISTS learning_tasks RENAME TO learning_path_interactions;

-- 更新外键引用
DO $$ 
BEGIN
    -- 删除旧的外键约束（如果存在）
    IF EXISTS (
        SELECT 1 
        FROM information_schema.table_constraints 
        WHERE constraint_name = 'learning_tasks_path_id_fkey'
        AND table_name = 'learning_path_interactions'
    ) THEN
        ALTER TABLE learning_path_interactions DROP CONSTRAINT learning_tasks_path_id_fkey;
    END IF;

    -- 删除新的外键约束（如果存在）
    IF EXISTS (
        SELECT 1 
        FROM information_schema.table_constraints 
        WHERE constraint_name = 'learning_path_interactions_path_id_fkey'
        AND table_name = 'learning_path_interactions'
    ) THEN
        ALTER TABLE learning_path_interactions DROP CONSTRAINT learning_path_interactions_path_id_fkey;
    END IF;

    -- 添加新的外键约束
    ALTER TABLE learning_path_interactions
    ADD CONSTRAINT learning_path_interactions_path_id_fkey 
    FOREIGN KEY (path_id) 
    REFERENCES learning_path_history(id) 
    ON DELETE CASCADE;
END $$;

-- 更新策略
DROP POLICY IF EXISTS "用户可以访问自己的学习路径" ON learning_path_history;
DROP POLICY IF EXISTS "用户可以访问自己的学习任务" ON learning_path_interactions;

CREATE POLICY "用户可以访问自己的学习路径历史"
    ON learning_path_history
    FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "用户可以访问自己的学习路径交互"
    ON learning_path_interactions
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM learning_path_history
            WHERE learning_path_history.id = learning_path_interactions.path_id
            AND learning_path_history.user_id = auth.uid()
        )
    ); 