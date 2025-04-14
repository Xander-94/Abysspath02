-- 删除通用问卷及其相关数据
DO $$
DECLARE
    v_survey_id UUID;
BEGIN
    -- 获取通用问卷ID
    SELECT id INTO v_survey_id 
    FROM surveys 
    WHERE title = '通用学习能力评估问卷' 
    LIMIT 1;

    -- 删除问卷相关的回答明细
    DELETE FROM response_details
    WHERE response_id IN (
        SELECT id 
        FROM responses 
        WHERE survey_id = v_survey_id
    );

    -- 删除问卷的回答记录
    DELETE FROM responses
    WHERE survey_id = v_survey_id;

    -- 删除问题的选项
    DELETE FROM options
    WHERE question_id IN (
        SELECT id 
        FROM questions 
        WHERE survey_id = v_survey_id
    );

    -- 删除问题
    DELETE FROM questions
    WHERE survey_id = v_survey_id;

    -- 删除问卷
    DELETE FROM surveys
    WHERE id = v_survey_id;
END $$; 