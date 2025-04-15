-- 创建学习路径表
CREATE TABLE IF NOT EXISTS learning_paths (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'in_progress',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now())
);

-- 创建学习任务表
CREATE TABLE IF NOT EXISTS learning_tasks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    path_id UUID NOT NULL REFERENCES learning_paths(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'pending',
    due_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now())
);

-- 添加RLS策略
ALTER TABLE learning_paths ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_tasks ENABLE ROW LEVEL SECURITY;

-- 创建学习路径的访问策略
CREATE POLICY "用户可以访问自己的学习路径"
    ON learning_paths
    FOR ALL
    USING (auth.uid() = user_id);

-- 创建学习任务的访问策略
CREATE POLICY "用户可以访问自己的学习任务"
    ON learning_tasks
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM learning_paths
            WHERE learning_paths.id = learning_tasks.path_id
            AND learning_paths.user_id = auth.uid()
        )
    ); 