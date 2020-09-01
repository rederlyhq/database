-- DROP FUNCTION createDefFileFromProblemQuery;
CREATE OR REPLACE FUNCTION createDefFileFromProblemQuery(TEXT) RETURNS TEXT LANGUAGE plpgsql AS $$
DECLARE topic_row course_topic_content %ROWTYPE;
DECLARE result_content text := '';
DECLARE topic_type_name text := '';
DECLARE problem_record RECORD;
BEGIN
	result_content := result_content || 'openDate = 01/08/2013 at 12:35am EST' || E'\n';
	result_content := result_content || 'dueDate = 09/28/2019 at 12:35am EST' || E'\n';
	result_content := result_content || 'reducedScoringDate = 01/26/2200 at 12:35am EST' || E'\n';
	result_content := result_content || 'answerDate = 09/28/2019 at 12:35am EST' || E'\n';
	result_content := result_content || 'enableReducedScoring = Y' || E'\n';

	result_content := result_content || E'\n';
	
	result_content := result_content || 'assignmentType = default' || E'\n';
	
	result_content := result_content || E'\n';
	result_content := result_content || E'\n';
	result_content := result_content || E'\n';


	result_content := result_content || 'problemListV2' || E'\n';
	result_content := result_content || E'\n';

	FOR problem_record IN execute $1 LOOP
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

-- SELECT * FROM createDefFileFromProblemQuery('SELECT * FROM course_topic_question WHERE course_topic_question_active = true LIMIT 5');
