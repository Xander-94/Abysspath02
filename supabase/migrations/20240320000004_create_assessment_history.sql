-- 创建评估历史表
CREATE TABLE IF NOT EXISTS assessment_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,  -- 主键
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,  -- 用户ID
    type VARCHAR(50) NOT NULL DEFAULT 'dialogue',  -- 评估类型：dialogue(对话评估)
    title VARCHAR(255),  -- 评估标题
    status VARCHAR(50) NOT NULL DEFAULT 'in_progress',  -- 状态：in_progress(进行中), completed(已完成)
    summary TEXT,  -- 评估总结
    skill_proficiency JSONB,  -- 技能熟练度 {"skill_name": score}
    meta_skills JSONB,  -- 元能力 {"skill_name": score}
    interests JSONB,  -- 兴趣爱好 ["interest1", "interest2"]
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),  -- 创建时间
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),  -- 更新时间
    completed_at TIMESTAMPTZ,  -- 完成时间
    
    CONSTRAINT valid_type CHECK (type IN ('dialogue')),
    CONSTRAINT valid_status CHECK (status IN ('in_progress', 'completed'))
);

-- 创建评估对话记录表
CREATE TABLE IF NOT EXISTS assessment_interactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,  -- 主键
    assessment_id UUID NOT NULL,  -- 关联的评估ID
    user_message TEXT NOT NULL,  -- 用户消息
    ai_response TEXT NOT NULL,  -- AI回复
    traits JSONB,  -- 特征分析 {"trait_name": score}
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),  -- 创建时间
    
    CONSTRAINT assessment_interactions_assessment_id_fkey 
        FOREIGN KEY (assessment_id) 
        REFERENCES assessment_history(id) 
        ON DELETE CASCADE
);

-- 创建更新时间触发器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_assessment_history_updated_at
    BEFORE UPDATE ON assessment_history
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 创建RLS策略
ALTER TABLE assessment_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_interactions ENABLE ROW LEVEL SECURITY;

-- 用户只能访问自己的评估记录
CREATE POLICY "用户可以访问自己的评估记录"
    ON assessment_history
    FOR ALL
    USING (auth.uid() = user_id);

-- 用户只能访问自己的评估对话
CREATE POLICY "用户可以访问自己的评估对话"
    ON assessment_interactions
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM assessment_history
            WHERE assessment_history.id = assessment_interactions.assessment_id
            AND assessment_history.user_id = auth.uid()
        )
    );

-- 创建索引
CREATE INDEX idx_assessment_history_user_id ON assessment_history(user_id);
CREATE INDEX idx_assessment_history_type ON assessment_history(type);
CREATE INDEX idx_assessment_history_status ON assessment_history(status);
CREATE INDEX idx_assessment_interactions_assessment_id ON assessment_interactions(assessment_id);

-- 添加注释
COMMENT ON TABLE assessment_history IS '评估历史记录表';
COMMENT ON TABLE assessment_interactions IS '评估对话记录表';

COMMENT ON COLUMN assessment_history.id IS '评估ID';
COMMENT ON COLUMN assessment_history.user_id IS '用户ID';
COMMENT ON COLUMN assessment_history.type IS '评估类型';
COMMENT ON COLUMN assessment_history.title IS '评估标题';
COMMENT ON COLUMN assessment_history.status IS '评估状态';
COMMENT ON COLUMN assessment_history.summary IS '评估总结';
COMMENT ON COLUMN assessment_history.skill_proficiency IS '技能熟练度';
COMMENT ON COLUMN assessment_history.meta_skills IS '元能力';
COMMENT ON COLUMN assessment_history.interests IS '兴趣爱好';

COMMENT ON COLUMN assessment_interactions.id IS '对话记录ID';
COMMENT ON COLUMN assessment_interactions.assessment_id IS '关联的评估ID';
COMMENT ON COLUMN assessment_interactions.user_message IS '用户消息';
COMMENT ON COLUMN assessment_interactions.ai_response IS 'AI回复';
COMMENT ON COLUMN assessment_interactions.traits IS '特征分析'; 