
-- instructor sp

--create type table
CREATE TYPE QuestionPoolType AS TABLE (
    questionID INT PRIMARY KEY,
    content VARCHAR(100),
    degree INT,
    qType VARCHAR(10) CHECK (qType IN ('TF','MCQ','Text'))
);
go

CREATE PROCEDURE InsertQuestionsToPool
    @Questions QuestionPoolType READONLY
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO Exams.questionPool (questionID, content, degree, qType)
        SELECT questionID, content, degree, qType
        FROM @Questions;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;

----decalre table 
DECLARE @MyQuestions QuestionPoolType
INSERT INTO @MyQuestions (questionID, content, degree, qType)
VALUES

--(6, 'What is polymorphism?', 5, 'Text'),
(70, 'Which symbol is used for comm', 5, 'MCQ'),
(80, 'True or False: A constructor has ', 5, 'TF'),
--(9, 'Define encapsulation', 10, 'Text'),
(100, 'Which access modifier makes ', 5, 'MCQ')
--(11, 'True or False: C# supports multiple inheritance via interfaces', 5, 'TF'),
--(12, 'What is a delegate?', 10, 'Text'),
--(13, 'Which data type is used to store decimal values in C#?', 5, 'MCQ'),
--(14, 'True or False: The ''static'' keyword allows method sharing', 5, 'TF'),
--(15, 'Explain the use of ''using'' keyword in C#', 10, 'Text'),
--(16, 'Which collection class represents a dynamic array in C#?', 5, 'MCQ'),
--(17, 'True or False: A class can inherit from multiple base classes', 5, 'TF'),
--(18, 'What is the base class of all classes in C#?', 10, 'Text'),
--(19, 'Which keyword is used to inherit from a base class?', 5, 'MCQ'),
--(20, 'True or False: Abstract classes can be instantiated', 5, 'TF')

--test the sp
EXEC InsertQuestionsToPool @Questions = @MyQuestions
select * from [Exams].[questionPool]

go
-- create exam
CREATE PROCEDURE Exams.InsertExam
    @examID INT,
    @examType VARCHAR(15),
    @startTime TIME,
    @endTime TIME,
    @insID INT,
    @examDate DATE,
    @csrID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- ensure that instructor gives this course 
    IF EXISTS (
        SELECT 1
        FROM units.course
        WHERE csrID = @csrID AND insID = @insID
    )
    BEGIN
        INSERT INTO Exams.exam (examID, examType, startTime, endTime, insID, examDate, csrID)
        VALUES (@examID, @examType, @startTime, @endTime, @insID, @examDate, @csrID);
    END
    ELSE
    BEGIN
        RAISERROR('Instructor is not assigned to this course.', 16, 1);
    END
END;

--test insertExam
EXEC Exams.InsertExam
    @examID = 11,
    @examType = 'Corrective',
    @startTime = '09:00',
    @endTime = '11:00',
    @insID = 1,
    @examDate = '2025-05-12',
    @csrID = 1;

select * from[Exams].[exam]

go
-- add  questions to exam
CREATE or alter PROCEDURE Exams.AddRandomMCQ_TF_QuestionsToExam
@examID INT,
@numberOfQuestions INT = 2
AS
BEGIN
    SET NOCOUNT ON;
	
	if not ((select count(1) from Exams.exam_question E where E.examID = @examID) = @numberOfQuestions)
    begin
		INSERT INTO Exams.exam_question (examID, questionID)
		SELECT TOP (@numberOfQuestions) @examID, questionID
		FROM Exams.questionPool
		WHERE qType IN ('MCQ', 'TF')
		  AND questionID NOT IN (
			  SELECT questionID FROM Exams.exam_question WHERE examID = @examID
		  )
		ORDER BY NEWID();
	end
	else
	begin
		UPDATE eq
		SET questionID = qp.questionID
		FROM Exams.exam_question eq
		JOIN (
			SELECT TOP (@numberOfQuestions) questionID
			FROM Exams.questionPool
			WHERE qType IN ('MCQ', 'TF')
			  AND questionID NOT IN (
				  SELECT questionID FROM Exams.exam_question WHERE examID = @examID
			  )
			ORDER BY NEWID()
		) qp ON eq.examID = @examID;

	end
END; 

--execute sp for add question exam by identify exam id
EXEC Exams.AddRandomMCQ_TF_QuestionsToExam
    @examID = 11,
    @numberOfQuestions = 7;
select *from [Exams].[exam_question] where [examID]=11


go
--add answers for mcq  type
CREATE PROCEDURE Exams.AddAnswersForMSQ
    @questionID INT,
    @ch1 VARCHAR(50),
    @ch2 VARCHAR(50),
    @ch3 VARCHAR(50),
    @ch4 VARCHAR(50),
    @correctAnswer VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
	   IF NOT EXISTS (
        SELECT 1 FROM Exams.questionPool
        WHERE questionID = @questionID AND qType = 'MCQ'
    )
    BEGIN
        RAISERROR('Question does not exist or is not of type MCQ.', 16, 1);
        RETURN;
    END

	IF @correctAnswer NOT IN ('ch1','ch2','ch3','ch4')
    BEGIN
        RAISERROR('CorrectAnswer must be one of: ch1, ch2, ch3, ch4.', 16, 1);
        RETURN;
    END

	IF EXISTS (
        SELECT 1 FROM Exams.msq_type WHERE questionID = @questionID
    )
    BEGIN
        RAISERROR('this already exist for this question.', 16, 1);
        RETURN;
    END
	else
	begin
		INSERT INTO Exams.msq_type (questionID, ch1, ch2, ch3, ch4, correctAnswer)
		VALUES (@questionID, @ch1, @ch2, @ch3, @ch4, @correctAnswer);
	end

    -- Insert data into MSQ_TYPE table
    
END;
--exectute sp to add answers to MCQ
EXEC Exams.AddAnswersForMSQ
    @questionID = 70,
    @ch1 = '/',
    @ch2 = '--',
    @ch3 = ',',
    @ch4 = '//',
    @correctAnswer = 'ch2';

select * from [Exams].[msq_type]

go
--add answers for TF  type
CREATE PROCEDURE Exams.AddAnswerForTF
    @questionID INT,
    @correctAnswer varchar(5) 
AS
BEGIN
    SET NOCOUNT ON;

    -- check if question exist in question pool
    IF EXISTS (
        SELECT 1 FROM Exams.questionPool
        WHERE questionID = @questionID AND qType = 'TF'
    )
    BEGIN
	IF EXISTS (
        SELECT 1 FROM Exams.TF_type WHERE questionID = @questionID
    )
    BEGIN
        RAISERROR('this already exist for this question.', 16, 1);
        RETURN;
    END
		IF EXISTS (
			SELECT 1 FROM Exams.msq_type WHERE questionID = @questionID
		)
		BEGIN
			RAISERROR('this already exist for this question.', 16, 1);
			RETURN;
		END
		ELSE
		BEGIN
			INSERT INTO Exams.TF_type (questionID, correctAnswer)
			VALUES (@questionID, @correctAnswer);
		END
    END
    ELSE
    BEGIN
        RAISERROR('Either question does not exist or it is not of type TF.', 16, 1);
    END
END;

----------------------------------------------------------
EXEC  Exams.AddAnswerForTF
    @questionID = 1,
    @correctAnswer = 'F';  
	select * from [Exams].[TF_type]



go
-- assin student to exam
CREATE PROCEDURE AddStudentToExam
    @stdID INT,
    @examID INT,
    @score INT = 0
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Exams.exam WHERE examID = @examID)
    BEGIN
        RAISERROR ('exam does not exist', 16, 1);
        RETURN;
    END
    IF NOT EXISTS (SELECT 1 FROM Person.student WHERE stdID = @stdID)
    BEGIN
        RAISERROR ('student does not exist', 16, 1);
        RETURN;
    END
    DECLARE @csrID INT;
    SELECT @csrID = csrID FROM Exams.exam WHERE examID = @examID;
    IF NOT EXISTS (
        SELECT 1
        FROM Person.student s
        JOIN units.track_course tc ON s.trackID = tc.trackID
        WHERE s.stdID = @stdID AND tc.courseId = @csrID
    )
    BEGIN
        RAISERROR ('student is not enrolled in the course associated with this exam', 16, 1);
        RETURN;
    END

    INSERT INTO Exams.std_exam (stdID, examID, score)
    VALUES (@stdID, @examID, @score);

    SELECT 'std added to exam' AS Result;
END;

EXEC AddStudentToExam @stdID = 1, @examID = 11, @score = 0;


go
--check instructor in certain course
CREATE PROCEDURE CheckInstructorInCourse
    @insID INT,
    @csrID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM units.course WHERE insID = @insID AND csrID = @csrID)
        SELECT 'instructor is assigned to the course.' AS Result;
    ELSE
        SELECT 'instructor is not assigned to the course.' AS Result;
END;

EXEC CheckInstructorInCourse @insID = 1, @csrID = 10;


go


-- std sp
-- show view, take exam id as input param
create or alter proc creatExamView @examId int
as
begin
	--declar var to all quesitonId that  belong to the exam id and its type
	declare @questionsId table(
		id int primary key,
		qtype varchar(10)
	)
	declare @msqQuest table(
		id int primary key ,
		content varchar(50),
		ch1 varchar(50),
		ch2 varchar(50),
		ch3 varchar(50),
		ch4 varchar(50)
	)
	declare @tfQuest table(
		id int primary key,
		content varchar(50)
	)

	--select all quesitonsid and store it in the var
	if exists ( select  1 from Exams.exam E where E.examID = @examId)
	begin
			insert into @questionsId(id, qtype)
			select eq.questionID, qp.qtype from Exams.exam_question  eq, Exams.questionPool qp where eq.examID = @examId and  qp.questionID =eq.questionID
	
			--declare cursor walk through the var table
			declare questionCursor cursor for select id, qtype from @questionsId 
	
			declare @qID int
			declare @qType varchar(10)

			--open cursor and walk through each row in the var table to check the type and insert into table based on the type
			open questionCursor

			fetch next from questionCursor into @qID, @qType

			WHILE @@FETCH_STATUS = 0
			begin
				if @qType = 'MCQ'
					begin
						insert into @msqQuest(id, content, ch1, ch2, ch3, ch4)
						select qp.questionID , qp.content, msq.ch1, msq.ch2, msq.ch3, msq.ch4
						from Exams.questionPool qp, Exams.msq_type msq where qp.questionID = @qID and qp.questionID = msq.questionID
					end
				else if @qType = 'TF'
					begin
						insert into @tfQuest(id, content)
						select qp.questionID, qp.content
						from Exams.questionPool qp  where qp.questionID = @qID
					end
					fetch next from questionCursor into @qID, @qType
			end
			CLOSE questionCursor;
			DEALLOCATE questionCursor;
			select * from @msqQuest
			select * from @tfQuest
	end
	else
		RAISERROR ('there is no such exam with this id', 16, 1);

end

exec creatExamView 11

go


--create global temp table that only with  std
create or alter proc answerSheet @stdID int , @examID int
as
begin
	if exists (select 1 from Exams.std_exam se where se.stdID = @stdID and se.examID = @examID)
	begin
		create table ##answerSheet(
			qID int ,
			stdAnswer varchar(5)
		) 
	end
end

exec answerSheet 1, 1

go

-- add answer to answer sheet
create or alter proc addAnswer @stdID int, @examID int, @qID int , @stdAnswer varchar(50)
as
begin

	declare @strTime time
	declare @endTime time


		IF OBJECT_ID('tempdb..##answerSheet') IS NULL
		begin
			exec answerSheet @stdID, @examID
		end
	
		select @strTime = E.startTime , @endTime = E.endtime
		from Exams.exam E where E.examID = @examID

		if CONVERT(TIME, GETDATE()) between @strTime and @endTime
		begin

			if exists (select 1 from  ##answerSheet  S where S.qID = @qID )
			begin
				update ##answerSheet  set stdAnswer = @stdAnswer where qID = @qID
			end
			else
			begin
				insert into ##answerSheet(qID,stdAnswer) values(@qID, @stdAnswer)
			end
		end
		else
		begin
			--calc the score of the stdExam
			exec student_results_proc @examID, @stdID
			print 'time has finsihed'
		end

end

exec addAnswer 1,1, 1, 'F'
exec addAnswer 1,1, 2, 'ch1'

select * from ##answersheet
go 
create or alter function Exams.totalScore(@MCQ_Score int  , @TF_score  int )
returns int
as 
begin 
	return @MCQ_Score + @TF_score
end

go

create or alter procedure student_results_proc @examID int, @stdID int
as
begin
	--variable declaration
	declare @QID int;
	declare @Qanswer varchar(5);
	declare @Qtype varchar(10);
	declare @MCQ_score int;
	declare @TF_score int;
	declare @total_score int 

	set  @MCQ_score = 0
	set @TF_score = 0
	
	-- create table qid,choice,correct answer,degree,score 
	declare cursor_correct cursor
	for select qID, stdAnswer from ##answerSheet

	open cursor_correct

	-- walk though the answer table
	fetch next from cursor_correct INTO @QID, @Qanswer
	while @@FETCH_STATUS =0
		begin
				select @Qtype= qp.qType
				from Exams.questionPool qp
				where qp.questionID = @QID
				
			 if @QType = 'MCQ'
				begin

					select @MCQ_score = sum(q.degree) --,correctAnswer,choice,
					from Exams.msq_type Qtype, ##answerSheet StdAns, Exams.questionPool q
					where QType.questionID = StdAns.qID  and  q.questionID = StdAns.qID and correctAnswer = StdAns.stdAnswer
					
				end
			  else if @QType = 'TF'
				begin
					select @TF_score = sum(degree) --,correctAnswer,choice,
					from Exams.[TF_type] Qtype, ##answerSheet StdAns, Exams.questionPool q
					where  QType.questionID  = StdAns.qID and   q.questionID = StdAns.qID  and correctAnswer = StdAns.stdAnswer
				end
			 fetch next from cursor_correct INTO @QID, @QType
		end
		
	close cursor_correct
	DEALLOCATE cursor_correct;
	
	-- calling total score function
	set @total_score = Exams.totalScore(@MCQ_Score, @TF_score );
	-- check the total score against maxDegree
	
	update stdTakeExam
	set score = @total_score
	
	from  Exams.std_exam stdTakeExam
	where   stdTakeExam.stdID =@stdID and stdTakeExam.examID = @examID

end

go

--check exam time to show the exam to the std
CREATE or ALTER PROCEDURE CheckExamAccess
    @std_id INT, @examID int
AS
BEGIN

		-- Check if the student exists in exam and track
	 IF EXISTS (
			SELECT 1
			FROM Exams.std_exam se
			WHERE se.stdID = @std_id and se.examID = @examID
	)
	BEGIN
		-- Return start time
		DECLARE @exam_start_date date;
		declare @exam_start_time TIME;
		declare @exam_end_time TIME;

		SELECT @exam_start_date = e.examDate, @exam_start_time = e.startTime,@exam_end_time = e.endTime
		FROM Exams.exam e
		WHERE e.examID = @examID;

		-- Check the start time
		 
		IF  (CONVERT(date, GETDATE()) =  @exam_start_date  and  (CONVERT(TIME, GETDATE()) between @exam_start_time and @exam_end_time)) 
		BEGIN
			

			
			exec creatExamView @std_id
	
		 END
		 ELSE
		 BEGIN
			
				print 'You aren''t allowed to start the exam yet.'
				print @exam_start_date
				print @exam_start_time

		 END
	END
	else
		print 'u dont have exam or u not anssined to this exam'
    
END


exec CheckExamAccess 1,2

go
--show stds who pass and whos  fail
create or alter procedure show_students_results @insID int
as
begin
	--declare variable table
	declare @results_table table 
	(
		studentID int,
		courseID int,
		examID int,
		result varchar(10)
	)
	--declare needed variables
	declare @stdID int
	declare @examID int
	declare @score int
	declare @minDegree int
	declare @courseID int
	-- declare cursor , move cursor thought select
	declare cursor_check_result cursor
	for select c.csrID ,stdID,e.examID,score,c.minDegree
	from Exams.std_exam ste ,Exams.exam e ,units.course c
	where ste.examID = e.examID and e.csrID = c.csrID  and c.insID = @insID

	open cursor_check_result

	fetch next from cursor_check_result INTO @courseID,@stdID,@examID,@score,@minDegree 
	while @@FETCH_STATUS =0
		begin
			 --select @courseID,@stdID,@examID,@score,@minDegree
			 if(@score >= @minDegree)
				begin
					insert into @results_table
					values(@stdID,@courseID,@examID,'pass')
				end
			 else 
				begin
					insert into @results_table
					values(@stdID,@courseID,@examID,'fail')
				end


			 fetch next from cursor_check_result INTO @courseID,@stdID,@examID,@score ,@minDegree
		end
		
	close cursor_check_result
	DEALLOCATE cursor_check_result;
	select concat (P.firstName,' ' ,P.lastName) stdName , C.courseName, R.examID, R.result 
	from @results_table R , Person.person P, Person.student S, units.course C
	where R.studentID = S.stdID and P.personID = S.personID and R.courseID = C.csrID

end

exec show_students_results 1



go

--show all students that and the instrcutor that teach them 
create or alter procedure get_all_student_for_instructor @instructorID int
as
begin
	select s.stdID,concat(p.firstName,' ', p.lastName) 'student name',t.trackName, c.courseName
	from units.course c , units.track_course tc , units.track t,
	Person.instructor i, Person.student s, Person.person p
	where tc.courseId = c.csrID and s.trackID = tc.trackID and c.insID = i.insID
	and s.personID = p.personID and  t.trackID = tc.trackId and i.insID = @instructorID 
end

exec get_all_student_for_instructor 1


--------------
--views



go
--view to show exam details
CREATE VIEW Exams.vw_ExamWithQuestions AS
SELECT 
    e.examID,
    e.examType,
    e.startTime,
    e.endTime,
    e.examDate,
    e.insID,
    e.csrID,
    qp.questionID,
    qp.content,
    qp.qType,
    qp.degree
FROM Exams.exam e
JOIN Exams.exam_question eq ON e.examID = eq.examID
JOIN Exams.questionPool qp ON eq.questionID = qp.questionID;


go
SELECT * FROM Exams.vw_ExamWithQuestions WHERE examID = 11;



CREATE or alter VIEW Person.vw_instructor_students AS
SELECT 
    I.InsID AS InstructorID,
    C.csrID AS CourseID,
    S.stdID AS StudentID
FROM 
    Person.instructor I
    JOIN units.course C ON I.InsID = C.insID
    JOIN units.track_course TC ON C.csrID = TC.courseId
    JOIN Person.student S ON TC.trackId = S.trackId;


drop view Person.vw_instructor_students


SELECT * FROM Person.vw_instructor_students
WHERE InstructorID = 1

create or alter view std_track
as
select S.stdID, concat(P.firstName,' ', P.lastName) [Name], T.trackName
from Person.student S , units.track T, Person.person P
where S.personID = P.personID and S.trackId = T.trackID
go
select *  from std_track