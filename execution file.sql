DECLARE @MyQuestions QuestionPoolType
INSERT INTO @MyQuestions (questionID, content, degree, qType)
VALUES
--(6, 'What is polymorphism?', 5, 'Text')
--(70, 'Which symbol is used for comm', 5, 'MCQ'),
--(80, 'True or False: A constructor has ', 5, 'TF'),
--(9, 'Define encapsulation', 10, 'Text'),
--(100, 'Which access modifier makes ', 5, 'MCQ')
--(11, 'True or False: C# supports multiple inheritance via interfaces', 5, 'TF'),
--(12, 'What is a delegate?', 10, 'Text'),
(13, 'Which data type is in C#?', 5, 'MCQ'),
(14, 'True or False: The  method sharing', 5, 'TF')
--(15, 'Explain the use of ''using'' keyword in C#', 10, 'Text'),


--1--
EXEC InsertQuestionsToPool @Questions = @MyQuestions
select * from [Exams].[questionPool]

--2--
EXEC Exams.AddAnswersForMSQ
    @questionID = 13,
    @ch1 = '/',
    @ch2 = '--',
    @ch3 = ',',
    @ch4 = '//',
    @correctAnswer = 'ch4';

select * from [Exams].[msq_type]

--3--
EXEC  Exams.AddAnswerForTF
    @questionID = 14,
    @correctAnswer = 'F';  

select * from [Exams].[TF_type]

--4--
EXEC Exams.InsertExam
    @examID = 16,
    @examType = 'normal',
    @startTime = '03:00',
    @endTime = '11:00',
    @insID = 1,
    @examDate = '2025-05-05',
    @csrID = 1;

select * from Exams.exam

--5--
EXEC Exams.AddRandomMCQ_TF_QuestionsToExam
    @examID = 16

select *from [Exams].[exam_question] where [examID]=16

--6-- 
EXEC AddStudentToExam @stdID = 1, @examID = 16, @score = 0;

--7--
-- after taking exam--
exec show_students_results 1
--8-- 
exec get_all_student_for_instructor 1

--9--
select *  from std_track


-- std taking exam--

exec CheckExamAccess 1,16

--stdID,examID,questionId, answer
exec addAnswer 1,16, 13, 'ch4'
exec addAnswer 1,16, 14, 'T'

