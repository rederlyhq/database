-- DROP FUNCTION converttocurriculum;
CREATE OR REPLACE FUNCTION createDefFileFromCourseTopic(INT) RETURNS TEXT LANGUAGE plpgsql AS $$
DECLARE topic_row course_topic_content %ROWTYPE;
DECLARE result_content text := '';
DECLARE topic_type_name text := '';
DECLARE problem_record RECORD;
BEGIN
	SELECT * INTO topic_row
	FROM course_topic_content t
	WHERE t.course_topic_content_id = $1;

	SELECT topic_type.topic_type_name INTO topic_type_name FROM topic_type;

	-- result_content := result_content || 'topicName = ' || topic_row.course_topic_content_name || E'\n';
	-- TODO dates
	result_content := result_content || 'openDate = ' || TO_CHAR(topic_row.course_topic_content_start_date, 'mm/dd/yyyy at HH12:MI') || E'\n';
	result_content := result_content || 'dueDate = ' || TO_CHAR(topic_row.course_topic_content_end_date, 'mm/dd/yyyy at HH12:MI') || E'\n';
	result_content := result_content || 'reducedScoringDate = ' || TO_CHAR(topic_row.course_topic_content_dead_date, 'mm/dd/yyyy at HH12:MI') || E'\n';
	-- TODO what is this?
	result_content := result_content || 'answerDate = ' || TO_CHAR(topic_row.course_topic_content_dead_date, 'mm/dd/yyyy at HH12:MI') || E'\n';
	-- TODO change true/false to Y/N
	result_content := result_content || 'enableReducedScoring = ' || topic_row.course_topic_content_partial_extend || E'\n';

	result_content := result_content || E'\n';
	
	result_content := result_content || 'assignmentType = ' || topic_type_name || E'\n';
	
	result_content := result_content || E'\n';
	result_content := result_content || E'\n';
	result_content := result_content || E'\n';


	result_content := result_content || 'problemListV2' || E'\n';
	result_content := result_content || E'\n';

	FOR problem_record IN execute 'SELECT * FROM course_topic_question WHERE course_topic_question_active = true AND course_topic_content_id = ' || $1 LOOP
		result_content := result_content || 'problem_start' || E'\n';
		result_content := result_content || 'problem_id = ' || problem_record.course_topic_question_id || E'\n';
		result_content := result_content || 'source_file = ' || problem_record.course_topic_question_webwork_question_ww_path || E'\n';
		result_content := result_content || 'value = ' || problem_record.course_topic_question_weight || E'\n';
		result_content := result_content || 'max_attempts = ' || problem_record.course_topic_question_max_attempts || E'\n';
		-- result_content := result_content || 'showMeAnother = ' ||  || E'\n';
		-- result_content := result_content || 'prPeriod = ' ||  || E'\n';
		-- result_content := result_content || 'counts_parent_grade = ' ||  || E'\n';
		-- result_content := result_content || 'att_to_open_children = ' ||  || E'\n';

		result_content := result_content || 'problem_end' || E'\n';
		result_content := result_content || E'\n';
	END LOOP;
	-- SELECT * INTO course_row FROM course WHERE course_active = true AND course_id = $1;
	RETURN result_content;
END;
$$;
SELECT *
FROM createDefFileFromCourseTopic(1570);
