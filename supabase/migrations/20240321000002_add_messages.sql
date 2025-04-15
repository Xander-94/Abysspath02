-- 添加消息表
CREATE TABLE IF NOT EXISTS learning_path_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    path_id UUID NOT NULL REFERENCES learning_path_history(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL CHECK (role IN ('user', 'assistant')),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb,
    CONSTRAINT fk_learning_path
        FOREIGN KEY (path_id)
        REFERENCES learning_path_history(id)
        ON DELETE CASCADE
);

-- 更新学习路径表
ALTER TABLE learning_path_history
    ADD COLUMN IF NOT EXISTS last_message_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS message_count INTEGER DEFAULT 0;

-- 创建触发器函数：更新学习路径的最后消息时间和消息数量
CREATE OR REPLACE FUNCTION update_learning_path_message_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE learning_path_history
        SET last_message_at = NEW.created_at,
            message_count = message_count + 1
        WHERE id = NEW.path_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE learning_path_history
        SET message_count = message_count - 1
        WHERE id = OLD.path_id;
        
        -- 更新最后消息时间为最新的消息时间
        UPDATE learning_path_history
        SET last_message_at = (
            SELECT MAX(created_at)
            FROM learning_path_messages
            WHERE path_id = OLD.path_id
        )
        WHERE id = OLD.path_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器
DROP TRIGGER IF EXISTS trigger_update_learning_path_message_stats ON learning_path_messages;
CREATE TRIGGER trigger_update_learning_path_message_stats
    AFTER INSERT OR DELETE ON learning_path_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_learning_path_message_stats();

-- 添加RLS策略
ALTER TABLE learning_path_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "用户可以访问自己的学习路径消息"
    ON learning_path_messages
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM learning_path_history
            WHERE learning_path_history.id = learning_path_messages.path_id
            AND learning_path_history.user_id = auth.uid()
        )
    ); 