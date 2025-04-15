-- 学习路径历史记录表
CREATE TABLE IF NOT EXISTS learning_path_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'in_progress',
    path_data JSONB,  -- 存储完整的学习路径JSON数据
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- 学习路径对话记录表
CREATE TABLE IF NOT EXISTS learning_path_interactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    path_id UUID NOT NULL REFERENCES learning_path_history(id) ON DELETE CASCADE,
    user_message TEXT NOT NULL,
    ai_response TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_learning_path_history_user_id ON learning_path_history(user_id);
CREATE INDEX IF NOT EXISTS idx_learning_path_interactions_path_id ON learning_path_interactions(path_id);

-- 添加RLS策略
ALTER TABLE learning_path_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_path_interactions ENABLE ROW LEVEL SECURITY;

-- 创建策略
CREATE POLICY "用户可以访问自己的学习路径"
    ON learning_path_history
    FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY "用户可以访问自己的学习路径对话"
    ON learning_path_interactions
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM learning_path_history
            WHERE id = learning_path_interactions.path_id
            AND user_id = auth.uid()
        )
    ); 