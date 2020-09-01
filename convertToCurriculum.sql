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
BEGIN
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
                  );
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
-- SELECT convertToCurriculum(1);
