// Table and column constants for Supabase PostgREST Question Bank queries.

const String kMcqQuestionsTable = 'mcq_questions';

const String kMcqQuestionSelectColumns =
    'id,external_code,subject_id,chapter_id,topic_id,stimulus_id,'
    'question_type,title,statements,options,correct_option,explanation,'
    'difficulty,source_type,board_id,exam_year,rights_status,status,'
    'is_verified,version,archived_at,created_at,updated_at';
