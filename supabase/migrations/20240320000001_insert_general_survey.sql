-- 插入通用问卷
INSERT INTO surveys (id, title, description, is_active) VALUES 
(gen_random_uuid(), '通用学习能力评估问卷', '用于评估用户的学习能力、兴趣和目标的综合问卷', true);

-- 获取问卷ID
DO $$
DECLARE
    v_survey_id UUID;
BEGIN
    SELECT id INTO v_survey_id FROM surveys WHERE title = '通用学习能力评估问卷' LIMIT 1;

    -- 插入基础信息部分问题
    INSERT INTO questions (id, survey_id, section, question_type, question_text, question_order, is_required)
    VALUES 
    -- 基础信息
    (gen_random_uuid(), v_survey_id, '基础信息', 'single_choice', '您的主要身份是？', 1, true),
    (gen_random_uuid(), v_survey_id, '基础信息', 'multiple_choice', '您评估的主要目的是？', 2, true),
    
    -- 能力评估
    (gen_random_uuid(), v_survey_id, '能力评估', 'scale', '请评估信息检索与分析能力（1-5级，1=完全生疏，5=精通）', 3, true),
    (gen_random_uuid(), v_survey_id, '能力评估', 'scale', '请评估跨文化沟通能力（1-5级，1=完全生疏，5=精通）', 4, true),
    (gen_random_uuid(), v_survey_id, '能力评估', 'scale', '请评估项目/时间管理能力（1-5级，1=完全生疏，5=精通）', 5, true),
    (gen_random_uuid(), v_survey_id, '能力评估', 'scale', '请评估创造性思维能力（1-5级，1=完全生疏，5=精通）', 6, true),
    (gen_random_uuid(), v_survey_id, '能力评估', 'single_choice', '您有深度接触的领域数量是？', 7, true),
    (gen_random_uuid(), v_survey_id, '能力评估', 'multiple_choice', '您最擅长的实践形式是？', 8, true),
    
    -- 兴趣图谱
    (gen_random_uuid(), v_survey_id, '兴趣图谱', 'multiple_choice', '请选择您最想探索的3个主领域', 9, true),
    (gen_random_uuid(), v_survey_id, '兴趣图谱', 'scale', '您对心理学 × 产品设计组合领域的兴趣程度如何？', 10, true),
    (gen_random_uuid(), v_survey_id, '兴趣图谱', 'scale', '您对环境科学 × 政策研究组合领域的兴趣程度如何？', 11, true),
    (gen_random_uuid(), v_survey_id, '兴趣图谱', 'scale', '您对数字技术 × 文化遗产组合领域的兴趣程度如何？', 12, true),
    
    -- 学习模式
    (gen_random_uuid(), v_survey_id, '学习模式', 'multiple_choice', '您更倾向的学习方式是？', 13, true),
    (gen_random_uuid(), v_survey_id, '学习模式', 'scale', '您期望的学习强度是？', 14, true),
    
    -- 约束条件
    (gen_random_uuid(), v_survey_id, '约束条件', 'single_choice', '您能接受的单领域最大学习成本是？', 15, true),
    (gen_random_uuid(), v_survey_id, '约束条件', 'multiple_choice', '您的主要学习场景是？', 16, true),
    
    -- 目标系统
    (gen_random_uuid(), v_survey_id, '目标系统', 'single_choice', '您希望达到的掌握程度是？', 17, true),
    (gen_random_uuid(), v_survey_id, '目标系统', 'single_choice', '您期望在多长时间内看到进展？', 18, true),
    
    -- 开放映射
    (gen_random_uuid(), v_survey_id, '开放映射', 'text', '请用"领域A × 领域B"的形式描述您想探索的任意组合', 19, true),
    (gen_random_uuid(), v_survey_id, '开放映射', 'text', '用一句话定义您的学习人格', 20, true);

    -- 为每个问题插入选项
    -- 基础信息 - 主要身份
    INSERT INTO options (id, question_id, option_text, option_value, option_order)
    SELECT 
        gen_random_uuid(),
        q.id,
        unnest(ARRAY['学生', '职场新人', '资深从业者', '自由职业者', '其他']),
        unnest(ARRAY['student', 'new_employee', 'senior_professional', 'freelancer', 'other']),
        generate_series(1, 5)
    FROM questions q
    WHERE q.survey_id = v_survey_id AND q.question_text = '您的主要身份是？';

    -- 基础信息 - 评估目的
    INSERT INTO options (id, question_id, option_text, option_value, option_order)
    SELECT 
        gen_random_uuid(),
        q.id,
        unnest(ARRAY['职业转型', '兴趣拓展', '学术深造', '技能补充', '跨领域探索']),
        unnest(ARRAY['career_change', 'interest_expansion', 'academic_advancement', 'skill_supplement', 'cross_field']),
        generate_series(1, 5)
    FROM questions q
    WHERE q.survey_id = v_survey_id AND q.question_text = '您评估的主要目的是？';

    -- 能力评估 - 领域数量
    INSERT INTO options (id, question_id, option_text, option_value, option_order)
    SELECT 
        gen_random_uuid(),
        q.id,
        unnest(ARRAY['0个（全新领域）', '1-2个', '3-5个', '>5个']),
        unnest(ARRAY['0', '1-2', '3-5', '>5']),
        generate_series(1, 4)
    FROM questions q
    WHERE q.survey_id = v_survey_id AND q.question_text = '您有深度接触的领域数量是？';

    -- 能力评估 - 实践形式
    INSERT INTO options (id, question_id, option_text, option_value, option_order)
    SELECT 
        gen_random_uuid(),
        q.id,
        unnest(ARRAY['理论研究', '实践操作', '团队协作', '独立创作']),
        unnest(ARRAY['theory', 'practice', 'team', 'independent']),
        generate_series(1, 4)
    FROM questions q
    WHERE q.survey_id = v_survey_id AND q.question_text = '您最擅长的实践形式是？';

    -- 兴趣图谱 - 主领域
    INSERT INTO options (id, question_id, option_text, option_value, option_order)
    SELECT 
        gen_random_uuid(),
        q.id,
        unnest(ARRAY['人文艺术', '社会科学', '自然科学', '工程技术', '商业管理', '健康医学', '教育传播', '新兴交叉领域']),
        unnest(ARRAY['art', 'social', 'science', 'engineering', 'business', 'medical', 'education', 'cross']),
        generate_series(1, 8)
    FROM questions q
    WHERE q.survey_id = v_survey_id AND q.question_text = '请选择您最想探索的3个主领域';

    -- 学习模式 - 学习方式
    INSERT INTO options (id, question_id, option_text, option_value, option_order)
    SELECT 
        gen_random_uuid(),
        q.id,
        unnest(ARRAY['系统课程学习', '碎片化阅读', '导师指导', '同辈交流', '实践实验', '案例研究']),
        unnest(ARRAY['course', 'reading', 'mentor', 'peer', 'experiment', 'case']),
        generate_series(1, 6)
    FROM questions q
    WHERE q.survey_id = v_survey_id AND q.question_text = '您更倾向的学习方式是？';

    -- 约束条件 - 学习成本
    INSERT INTO options (id, question_id, option_text, option_value, option_order)
    SELECT 
        gen_random_uuid(),
        q.id,
        unnest(ARRAY['完全免费', '<500元', '500-2000元', '不设限']),
        unnest(ARRAY['free', 'under_500', '500_2000', 'unlimited']),
        generate_series(1, 4)
    FROM questions q
    WHERE q.survey_id = v_survey_id AND q.question_text = '您能接受的单领域最大学习成本是？';

    -- 约束条件 - 学习场景
    INSERT INTO options (id, question_id, option_text, option_value, option_order)
    SELECT 
        gen_random_uuid(),
        q.id,
        unnest(ARRAY['居家自学', '线下课堂', '工作实践', '移动场景']),
        unnest(ARRAY['home', 'classroom', 'work', 'mobile']),
        generate_series(1, 4)
    FROM questions q
    WHERE q.survey_id = v_survey_id AND q.question_text = '您的主要学习场景是？';

    -- 目标系统 - 掌握程度
    INSERT INTO options (id, question_id, option_text, option_value, option_order)
    SELECT 
        gen_random_uuid(),
        q.id,
        unnest(ARRAY['基础认知', '熟练应用', '专业水准', '领域创新']),
        unnest(ARRAY['basic', 'proficient', 'professional', 'innovative']),
        generate_series(1, 4)
    FROM questions q
    WHERE q.survey_id = v_survey_id AND q.question_text = '您希望达到的掌握程度是？';

    -- 目标系统 - 进展时间
    INSERT INTO options (id, question_id, option_text, option_value, option_order)
    SELECT 
        gen_random_uuid(),
        q.id,
        unnest(ARRAY['1个月内', '3个月', '半年', '1年以上']),
        unnest(ARRAY['1_month', '3_months', '6_months', '1_year']),
        generate_series(1, 4)
    FROM questions q
    WHERE q.survey_id = v_survey_id AND q.question_text = '您期望在多长时间内看到进展？';

END $$; 