DO $$ 
DECLARE
  v_survey_id UUID;
BEGIN
  -- 插入问卷
  INSERT INTO surveys (id, title, description, is_active)
  VALUES (
    gen_random_uuid(),  -- 使用UUID作为ID
    '学习者画像多选问卷',
    '这份问卷旨在了解学习者的基本情况、技能水平、兴趣方向、学习偏好等多个维度，帮助我们为您提供更个性化的学习建议。',
    true
  );

  -- 获取刚插入的问卷ID
  SELECT id INTO v_survey_id FROM surveys WHERE title = '学习者画像多选问卷' ORDER BY created_at DESC LIMIT 1;

  -- 插入问题
  INSERT INTO questions (id, survey_id, section, question_type, question_text, question_order, is_required)
  VALUES 
    -- 基础信息
    (gen_random_uuid(), v_survey_id, '基础信息', 'multiple_choice', '您的学习主要动机是？', 1, true),
    (gen_random_uuid(), v_survey_id, '基础信息', 'multiple_choice', '您当前所处阶段？', 2, true),
    
    -- 技能评估
    (gen_random_uuid(), v_survey_id, '技能评估', 'multiple_choice', '请选择您已掌握的通用能力', 3, true),
    (gen_random_uuid(), v_survey_id, '技能评估', 'multiple_choice', '您擅长的实践形式是？', 4, true),
    
    -- 兴趣图谱
    (gen_random_uuid(), v_survey_id, '兴趣图谱', 'multiple_choice', '选择您最感兴趣的3个主领域', 5, true),
    (gen_random_uuid(), v_survey_id, '兴趣图谱', 'multiple_choice', '您感兴趣的跨领域组合是？', 6, true),
    
    -- 学习模式
    (gen_random_uuid(), v_survey_id, '学习模式', 'multiple_choice', '您偏好的学习资源类型', 7, true),
    (gen_random_uuid(), v_survey_id, '学习模式', 'multiple_choice', '您的最佳学习时段是？', 8, true),
    
    -- 约束条件
    (gen_random_uuid(), v_survey_id, '约束条件', 'multiple_choice', '您能接受的学习投入方式', 9, true),
    (gen_random_uuid(), v_survey_id, '约束条件', 'multiple_choice', '您的主要学习设备是？', 10, true),
    
    -- 目标系统
    (gen_random_uuid(), v_survey_id, '目标系统', 'multiple_choice', '您希望达成的里程碑', 11, true);

  -- 为每个问题插入选项
  -- 基础信息-动机
  INSERT INTO options (id, question_id, option_text, option_value, option_order)
  SELECT 
    gen_random_uuid(),
    q.id,
    unnest(ARRAY[
      '职业晋升',
      '兴趣拓展',
      '学术研究',
      '跨领域转型',
      '解决实际问题',
      '社交需求'
    ]),
    unnest(ARRAY[
      'career_promotion',
      'interest_expansion',
      'academic_research',
      'domain_transition',
      'problem_solving',
      'social_needs'
    ]),
    generate_series(1, 6)
  FROM questions q
  WHERE q.survey_id = v_survey_id AND q.question_text = '您的学习主要动机是？';

  -- 基础信息-阶段
  INSERT INTO options (id, question_id, option_text, option_value, option_order)
  SELECT 
    gen_random_uuid(),
    q.id,
    unnest(ARRAY[
      '完全新手（无相关背景）',
      '有一定基础（需系统提升）',
      '资深从业者（需深化专精）',
      '跨界探索者（从其他领域转入）'
    ]),
    unnest(ARRAY[
      'beginner',
      'intermediate',
      'advanced',
      'explorer'
    ]),
    generate_series(1, 4)
  FROM questions q
  WHERE q.survey_id = v_survey_id AND q.question_text = '您当前所处阶段？';

  -- 技能评估-通用能力
  INSERT INTO options (id, question_id, option_text, option_value, option_order)
  SELECT 
    gen_random_uuid(),
    q.id,
    unnest(ARRAY[
      '数据分析与可视化',
      '项目管理与协作',
      '多语言沟通',
      '创意思维与设计',
      '逻辑推理与数学建模',
      '快速学习与适应能力'
    ]),
    unnest(ARRAY[
      'data_analysis',
      'project_management',
      'multilingual',
      'creative_thinking',
      'logical_reasoning',
      'quick_learning'
    ]),
    generate_series(1, 6)
  FROM questions q
  WHERE q.survey_id = v_survey_id AND q.question_text = '请选择您已掌握的通用能力';

  -- 技能评估-实践形式
  INSERT INTO options (id, question_id, option_text, option_value, option_order)
  SELECT 
    gen_random_uuid(),
    q.id,
    unnest(ARRAY[
      '理论研究（文献阅读/论文写作）',
      '技术实操（工具使用/编程开发）',
      '艺术创作（设计/音乐/写作）',
      '人际协作（团队管理/社区运营）',
      '实验探索（原型开发/田野调查）'
    ]),
    unnest(ARRAY[
      'theoretical_research',
      'technical_practice',
      'artistic_creation',
      'interpersonal_collaboration',
      'experimental_exploration'
    ]),
    generate_series(1, 5)
  FROM questions q
  WHERE q.survey_id = v_survey_id AND q.question_text = '您擅长的实践形式是？';

  -- 兴趣图谱-主领域
  INSERT INTO options (id, question_id, option_text, option_value, option_order)
  SELECT 
    gen_random_uuid(),
    q.id,
    unnest(ARRAY[
      '人工智能与机器学习',
      '生物技术与医疗健康',
      '可持续能源与环境科学',
      '金融科技与区块链',
      '教育创新与认知科学',
      '文化遗产与数字人文',
      '社会科学与政策研究',
      '艺术设计与创意科技'
    ]),
    unnest(ARRAY[
      'ai_ml',
      'biotech_health',
      'energy_environment',
      'fintech_blockchain',
      'edu_cognitive',
      'culture_digital',
      'social_policy',
      'art_creative'
    ]),
    generate_series(1, 8)
  FROM questions q
  WHERE q.survey_id = v_survey_id AND q.question_text = '选择您最感兴趣的3个主领域';

  -- 兴趣图谱-跨领域组合
  INSERT INTO options (id, question_id, option_text, option_value, option_order)
  SELECT 
    gen_random_uuid(),
    q.id,
    unnest(ARRAY[
      '数据科学 × 社会科学',
      '神经科学 × 用户体验',
      '材料工程 × 工业设计',
      '生态学 × 城市规划',
      '历史学 × 游戏开发',
      '心理学 × 市场营销'
    ]),
    unnest(ARRAY[
      'data_social',
      'neuro_ux',
      'material_design',
      'eco_urban',
      'history_game',
      'psych_marketing'
    ]),
    generate_series(1, 6)
  FROM questions q
  WHERE q.survey_id = v_survey_id AND q.question_text = '您感兴趣的跨领域组合是？';

  -- 学习模式-资源类型
  INSERT INTO options (id, question_id, option_text, option_value, option_order)
  SELECT 
    gen_random_uuid(),
    q.id,
    unnest(ARRAY[
      '系统化在线课程（如Coursera）',
      '短平快知识胶囊（如微信公众号）',
      '交互式实验环境（如Jupyter Notebook）',
      '社区讨论与问答（如知乎/Reddit）',
      '行业报告与白皮书',
      '工具文档与API手册'
    ]),
    unnest(ARRAY[
      'online_course',
      'knowledge_capsule',
      'interactive_env',
      'community_qa',
      'industry_report',
      'tool_doc'
    ]),
    generate_series(1, 6)
  FROM questions q
  WHERE q.survey_id = v_survey_id AND q.question_text = '您偏好的学习资源类型';

  -- 学习模式-时段
  INSERT INTO options (id, question_id, option_text, option_value, option_order)
  SELECT 
    gen_random_uuid(),
    q.id,
    unnest(ARRAY[
      '清晨（6:00-9:00）',
      '上午（9:00-12:00）',
      '下午（12:00-18:00）',
      '晚间（18:00-22:00）',
      '深夜（22:00后）'
    ]),
    unnest(ARRAY[
      'early_morning',
      'morning',
      'afternoon',
      'evening',
      'late_night'
    ]),
    generate_series(1, 5)
  FROM questions q
  WHERE q.survey_id = v_survey_id AND q.question_text = '您的最佳学习时段是？';

  -- 约束条件-投入方式
  INSERT INTO options (id, question_id, option_text, option_value, option_order)
  SELECT 
    gen_random_uuid(),
    q.id,
    unnest(ARRAY[
      '完全免费资源',
      '付费订阅（≤500元/月）',
      '硬件设备投入',
      '线下工作坊参与',
      '长期导师指导'
    ]),
    unnest(ARRAY[
      'free_resource',
      'paid_subscription',
      'hardware_investment',
      'offline_workshop',
      'long_term_mentor'
    ]),
    generate_series(1, 5)
  FROM questions q
  WHERE q.survey_id = v_survey_id AND q.question_text = '您能接受的学习投入方式';

  -- 约束条件-学习设备
  INSERT INTO options (id, question_id, option_text, option_value, option_order)
  SELECT 
    gen_random_uuid(),
    q.id,
    unnest(ARRAY[
      'Windows电脑',
      'Mac电脑',
      '智能手机/平板',
      '云开发环境（如Colab）',
      '专业实验设备'
    ]),
    unnest(ARRAY[
      'windows_pc',
      'mac_pc',
      'mobile_tablet',
      'cloud_env',
      'pro_equipment'
    ]),
    generate_series(1, 5)
  FROM questions q
  WHERE q.survey_id = v_survey_id AND q.question_text = '您的主要学习设备是？';

  -- 目标系统-里程碑
  INSERT INTO options (id, question_id, option_text, option_value, option_order)
  SELECT 
    gen_random_uuid(),
    q.id,
    unnest(ARRAY[
      '完成认证考试（如PMP/CFA）',
      '产出可展示作品（论文/作品集）',
      '实现产品原型',
      '建立行业人脉网络',
      '完成职业转型'
    ]),
    unnest(ARRAY[
      'certification',
      'portfolio',
      'prototype',
      'network',
      'career_change'
    ]),
    generate_series(1, 5)
  FROM questions q
  WHERE q.survey_id = v_survey_id AND q.question_text = '您希望达成的里程碑';

END $$; 