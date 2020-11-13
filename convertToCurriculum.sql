-- DROP FUNCTION converttocurriculum;

CREATE OR REPLACE FUNCTION convertToCurriculum(INT) RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    course_row course%ROWTYPE;
    unit_record RECORD;
    topic_record RECORD;
    problem_record RECORD;
    resultant_curriculum_id INT;
    resultant_curriculum_unit_content_id INT;
    resultant_curriculum_topic_content_id INT;
    resultant_curriculum_topic_question_id INT;
	course_topic_assessment_row topic_assessment_info%ROWTYPE;
	course_question_assessment_row course_question_assessment_info%ROWTYPE;
BEGIN
    -- Create a Curriculum object from the base Course object
    SELECT * INTO course_row FROM course WHERE course_active = true AND course_id = $1;
    INSERT INTO curriculum
    (
         curriculum_id,
         university_id,
         curriculum_name,
         curriculum_textbooks,
         curriculum_subject,
         curriculum_comment,
         curriculum_active,
         curriculum_public,
         created_at,
         updated_at
    )
    VALUES
    (
         DEFAULT, -- curriculum id
         course_row.university_id, -- university id
		 -- Uncomment this for a cheap hack to let you keep testing this script on the same course.
         -- course_row.course_name || (random() * 100000)::"text",
         course_row.course_name,
         course_row.course_textbooks,
         '', -- subject
         '', -- comment
         course_row.course_active, -- active
         false, -- public
         NOW(),
         NOW()
    )
    RETURNING curriculum_id INTO resultant_curriculum_id;

    FOR unit_record IN execute 'SELECT * FROM course_unit_content WHERE course_unit_content_active = true AND course_id = ' || $1
    LOOP
         INSERT INTO curriculum_unit_content
         (
             curriculum_unit_content_id,
             curriculum_id,
             curriculum_unit_content_order,
             curriculum_unit_content_name,
             curriculum_unit_content_active,
             created_at,
             updated_at
         )
         VALUES
         (
             DEFAULT,
             resultant_curriculum_id,
             unit_record.course_unit_content_order,
             unit_record.course_unit_content_name,
             unit_record.course_unit_content_active,
             NOW(),
             NOW()
         )
         RETURNING curriculum_unit_content_id INTO resultant_curriculum_unit_content_id;

         FOR topic_record IN execute 'SELECT * FROM course_topic_content WHERE course_topic_content_active = true AND course_unit_content_id = ' || unit_record.course_unit_content_id
         LOOP
             INSERT INTO curriculum_topic_content
             (
                 curriculum_topic_content_id,
                 curriculum_unit_content_id,
                 topic_type_id,
                 curriculum_topic_content_name,
                 curriculum_topic_content_active,
                 curriculum_topic_content_order,
                 created_at,
                 updated_at
             )
             VALUES
             (
                 DEFAULT,
                 resultant_curriculum_unit_content_id,
                 topic_record.topic_type_id,
                 topic_record.course_topic_content_name,
                 topic_record.course_topic_content_active,
                 topic_record.course_topic_content_order,
                 NOW(),
                 NOW()
             )
             RETURNING curriculum_topic_content_id INTO resultant_curriculum_topic_content_id;
			 
                --  Select the assessment info that belongs to this topic. There should only be one.
    			SELECT * INTO course_topic_assessment_row FROM topic_assessment_info 
				WHERE topic_assessment_info_active = true AND topic_assessment_info.course_topic_content_id = topic_record.course_topic_content_id;
	
                -- Copy over the fields to the curriculum version of the assessment info.
				IF course_topic_assessment_row.topic_assessment_info_id NOTNULL THEN
					INSERT INTO curriculum_topic_assessment_info (
						curriculum_topic_assessment_info_id,
						curriculum_topic_content_id,
						curriculum_topic_assessment_info_duration,
						curriculum_topic_assessment_info_hard_cutoff,
						curriculum_topic_assessment_info_max_graded_attempts_per_version,
						curriculum_topic_assessment_info_max_versions,
						curriculum_topic_assessment_info_version_delay,
						curriculum_topic_assessment_info_hide_hints,
						curriculum_topic_assessment_info_show_itemized_results,
						curriculum_topic_assessment_info_show_total_grade_immediately,
						curriculum_topic_assessment_info_hide_problems_after_finish,
						curriculum_topic_assessment_info_randomize_order,
						curriculum_topic_assessment_info_active
					) VALUES (
						DEFAULT,
						resultant_curriculum_topic_content_id,
						course_topic_assessment_row.topic_assessment_info_duration,
						course_topic_assessment_row.topic_assessment_info_hard_cutoff,
						course_topic_assessment_row.topic_assessment_info_max_graded_attempts_per_version,
						course_topic_assessment_row.topic_assessment_info_max_versions,
						course_topic_assessment_row.topic_assessment_info_version_delay,
						course_topic_assessment_row.topic_assessment_info_hide_hints,
						course_topic_assessment_row.topic_assessment_info_show_itemized_results,
						course_topic_assessment_row.topic_assessment_info_show_total_grade_immediately,
						course_topic_assessment_row.topic_assessment_info_hide_problems_after_finish,
						course_topic_assessment_row.topic_assessment_info_randomize_order,
						course_topic_assessment_row.topic_assessment_info_active
					);
				END IF;

              FOR problem_record IN execute 'SELECT * FROM course_topic_question WHERE course_topic_question_active = true AND course_topic_content_id = ' || topic_record.course_topic_content_id
              LOOP
                  INSERT INTO curriculum_topic_question
                  (
                      curriculum_topic_question_id,
                      curriculum_topic_content_id,
                      curriculum_topic_question_problem_number,
                      curriculum_topic_question_webwork_question_ww_path,
                      curriculum_topic_question_weight,
                      curriculum_topic_question_hidden,
                      curriculum_topic_question_active,
                      curriculum_topic_question_optional,
                      created_at,
                      updated_at
                  )
                  VALUES
                  (
                      DEFAULT,
                      resultant_curriculum_topic_content_id,
                      problem_record.course_topic_question_problem_number,
                      problem_record.course_topic_question_webwork_question_ww_path,
                      problem_record.course_topic_question_weight,
                      problem_record.course_topic_question_hidden,
                      problem_record.course_topic_question_active,
                      problem_record.course_topic_question_optional,
                      NOW(),
                      NOW()
                  )
                  RETURNING curriculum_topic_question_id INTO resultant_curriculum_topic_question_id;

                  			 
                --  Select the assessment info that belongs to this question. There should only be one.
    			SELECT * INTO course_question_assessment_row FROM course_question_assessment_info 
				WHERE course_question_assessment_info_active = true AND course_question_assessment_info.course_topic_question_id = problem_record.course_topic_question_id;
	
                -- Copy over the fields to the curriculum version of the assessment info.
				IF course_question_assessment_row.course_question_assessment_info_id NOTNULL THEN
					INSERT INTO curriculum_question_assessment_info (
                        curriculum_question_assessment_info_id,
                        curriculum_topic_question_id,
                        curriculum_question_assessment_info_random_seed_set,
                        curriculum_question_assessment_info_additional_problem_paths,
                        curriculum_question_assessment_info_active
					) VALUES (
						DEFAULT,
						resultant_curriculum_topic_question_id,
						course_question_assessment_row.course_question_assessment_info_random_seed_set,
						course_question_assessment_row.course_question_assessment_info_additional_problem_paths,
						course_question_assessment_row.course_question_assessment_info_active
					);
				END IF;
              END LOOP;
         END LOOP;
    END LOOP;
    RETURN resultant_curriculum_id;
END;
$$;

-- -- Validation
-- SELECT * FROM course;
-- SELECT * FROM course_unit_content;
-- SELECT * FROM course_topic_content;
-- SELECT * FROM course_topic_question;

-- SELECT * FROM curriculum;
-- SELECT * FROM curriculum_unit_content;
-- SELECT * FROM curriculum_topic_content;
-- SELECT * FROM curriculum_topic_question;

-- DELETE FROM curriculum_topic_question WHERE curriculum_topic_question_id > 100;
-- DELETE FROM curriculum_topic_content WHERE curriculum_topic_content_id > 100;
-- DELETE FROM curriculum_unit_content WHERE curriculum_unit_content_id > 10;
-- DELETE FROM curriculum WHERE curriculum_id > 5;
-- -- execution
-- SELECT convertToCurriculum(55);
