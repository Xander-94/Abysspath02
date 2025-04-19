-- backend/supabase/migrations/YYYYMMDDHHMMSS_create_learning_path_tables.sql

-- 创建 learning_paths 表
create table public.learning_paths (
    id uuid primary key default gen_random_uuid(),                     -- 路径唯一标识符
    user_id uuid references auth.users(id) on delete cascade not null, -- 用户ID，关联用户表
    title text not null,                                               -- 路径标题
    description text,                                                  -- 路径描述
    target_goal text,                                                  -- 学习目标
    estimated_duration text,                                           -- 预计学习时长
    created_at timestamptz default now() not null,                     -- 创建时间
    updated_at timestamptz default now() not null                      -- 更新时间
);
comment on table public.learning_paths is '存储用户生成的学习路径元数据';
comment on column public.learning_paths.id is '路径唯一标识符';
comment on column public.learning_paths.user_id is '关联的用户ID';
comment on column public.learning_paths.title is '路径标题';
comment on column public.learning_paths.description is '路径详细描述';
comment on column public.learning_paths.target_goal is '学习目标';
comment on column public.learning_paths.estimated_duration is '预计学习时长';

-- 创建 path_nodes 表
create table public.path_nodes (
    id uuid primary key default gen_random_uuid(),                     -- 节点唯一标识符
    path_id uuid references public.learning_paths(id) on delete cascade not null, -- 关联的学习路径ID
    label text not null,                                               -- 节点标签（名称）
    type text not null,                                                -- 节点类型（例如: skill, concept, project, goal, meta, influence）
    details text,                                                      -- 节点详细信息
    position_x float,                                                  -- 节点在图中的X坐标（可选）
    position_y float,                                                  -- 节点在图中的Y坐标（可选）
    created_at timestamptz default now() not null,                     -- 创建时间
    updated_at timestamptz default now() not null                      -- 更新时间
);
comment on table public.path_nodes is '存储学习路径中的知识节点';
comment on column public.path_nodes.id is '节点唯一标识符';
comment on column public.path_nodes.path_id is '关联的学习路径ID';
comment on column public.path_nodes.label is '节点显示的名称';
comment on column public.path_nodes.type is '节点类型 (skill, concept, project, goal, meta, influence)';
comment on column public.path_nodes.details is '节点的详细描述';
comment on column public.path_nodes.position_x is '可视化布局的X坐标';
comment on column public.path_nodes.position_y is '可视化布局的Y坐标';

-- 创建 path_edges 表
create table public.path_edges (
    id uuid primary key default gen_random_uuid(),                     -- 边唯一标识符
    path_id uuid references public.learning_paths(id) on delete cascade not null, -- 关联的学习路径ID
    source_node_id uuid references public.path_nodes(id) on delete cascade not null, -- 起始节点ID
    target_node_id uuid references public.path_nodes(id) on delete cascade not null, -- 目标节点ID
    relationship_type text,                                            -- 关系类型（例如: requires, leads_to, part_of）
    created_at timestamptz default now() not null,                     -- 创建时间
    updated_at timestamptz default now() not null                      -- 更新时间
);
comment on table public.path_edges is '存储学习路径中节点之间的关系（边）';
comment on column public.path_edges.id is '边唯一标识符';
comment on column public.path_edges.path_id is '关联的学习路径ID';
comment on column public.path_edges.source_node_id is '边的起始节点ID';
comment on column public.path_edges.target_node_id is '边的目标节点ID';
comment on column public.path_edges.relationship_type is '边的关系类型 (requires, leads_to)';

-- 创建 node_resources 表
create table public.node_resources (
    id uuid primary key default gen_random_uuid(),                     -- 资源唯一标识符
    node_id uuid references public.path_nodes(id) on delete cascade not null, -- 关联的节点ID
    title text not null,                                               -- 资源标题
    type text not null,                                                -- 资源类型（例如: video, article, book, course, tool）
    url text,                                                          -- 资源链接
    description text,                                                  -- 资源描述
    created_at timestamptz default now() not null,                     -- 创建时间
    updated_at timestamptz default now() not null                      -- 更新时间
);
comment on table public.node_resources is '存储与学习路径节点关联的学习资源';
comment on column public.node_resources.id is '资源唯一标识符';
comment on column public.node_resources.node_id is '关联的节点ID';
comment on column public.node_resources.title is '资源标题';
comment on column public.node_resources.type is '资源类型 (video, article, book, course, tool)';
comment on column public.node_resources.url is '资源的URL链接';
comment on column public.node_resources.description is '资源描述';

-- 为 updated_at 列创建自动更新触发器函数
create or replace function public.update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- 将触发器应用于每个表
create trigger update_learning_paths_updated_at before update on public.learning_paths for each row execute function public.update_updated_at_column();
create trigger update_path_nodes_updated_at before update on public.path_nodes for each row execute function public.update_updated_at_column();
create trigger update_path_edges_updated_at before update on public.path_edges for each row execute function public.update_updated_at_column();
create trigger update_node_resources_updated_at before update on public.node_resources for each row execute function public.update_updated_at_column();

-- 为关键外键添加索引以优化查询性能
create index idx_learning_paths_user_id on public.learning_paths(user_id);
create index idx_path_nodes_path_id on public.path_nodes(path_id);
create index idx_path_edges_path_id on public.path_edges(path_id);
create index idx_path_edges_source_node_id on public.path_edges(source_node_id);
create index idx_path_edges_target_node_id on public.path_edges(target_node_id);
create index idx_node_resources_node_id on public.node_resources(node_id); 