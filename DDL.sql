CREATE DATABASE ExaminationSystemDb
ON 
PRIMARY (
    NAME = ExaminationSystemD_Data,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\\ExamSystem_Data',
    SIZE = 10MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
),
FILEGROUP ExaminationSystemD_FG1 (
    NAME = ExaminationSystemD_FG1_Data,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\\ExamSystem_FG1.ndf',
    SIZE = 10MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5MB
)
LOG ON (
    NAME = ExaminationSystemD_Log,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\\ExamSystem_Log.ldf',
    SIZE = 5MB,
    MAXSIZE = 50MB,
    FILEGROWTH = 5MB
);

go
CREATE SCHEMA Person;

create table Person.person(
	personID int,
	firstName varchar(30),
	lastName varchar(30),
	email varchar(30),
	password varchar(256) unique,
	role varchar(10)
	
	constraint pk_person primary key (personId),
	constraint unique_email unique(email),
	constraint chk_email check( email like '_%@_%._%')
	)ON [PRIMARY];
	-------
alter table Person.person add constraint unique_pass unique (password)
alter table Person.person add constraint person_role check([role] in ('student','instructor'))

create table Person.instructor(
	InsID int primary key,
	personID int

	constraint fk_person foreign key (personID) references Person.person(personID)
)ON [PRIMARY];

-------
create table Person.student(
	stdID int primary key,
	personID int,
	trackId int

	constraint fk_std_track foreign key (trackId) references units.track(trackID),
	constraint fk_person_std foreign key (personID) references Person.person(personID)
)ON [PRIMARY];

create schema Exams

go 
-------
create table Exams.exam(
	examID int primary key,
	examType varchar(15), 
	startTime Time,
	endTime Time,
	insID int, 
	examDate date, 
	csrID int
	
	constraint fk_inst_exam foreign key(insID) references Person.instructor(insID),
	constraint fk_csr_exam foreign key(csrID) references units.course(csrID)
	
)ON [ExaminationSystemD_FG1 ];
alter table Exams.exam add constraint exam_type check (examType in ('normal','corrective'))

create table Exams.std_exam(

	stdID int,
	examID int,
	score int

	constraint fk_std_exam foreign key(stdID) references Person.student(stdID),
	constraint fk_exam foreign key(examID) references Exams.exam(examID)
)ON [ExaminationSystemD_FG1 ];


create table Exams.questionPool(
	questionID int  primary key,
	content varchar(50),
	degree int,
	qType varchar(10)


)ON [ExaminationSystemD_FG1 ];
alter table Exams.questionPool add constraint question_Type check (qType in ('TF','MCQ','Text'))


create table Exams.exam_question(
	examID int not null,
	questionID int not null

	constraint fk_exam_quest foreign key(examID) references Exams.exam(examID),
	constraint fk_quest foreign key(questionID) references Exams.questionPool(questionID)

)ON [ExaminationSystemD_FG1 ];

alter table Exams.exam_question add constraint composite_exam_question_pk primary key (examID,questionID)


create table Exams.msq_type(
	questionID int,
	ch1 varchar(50),
	ch2 varchar(50),
	ch3 varchar(50), 
	ch4 varchar(50),
	correctAnswer varchar(10)

	constraint fk_msq_quest foreign key(questionID) references  Exams.questionPool(questionID)
)ON [ExaminationSystemD_FG1 ];

alter table Exams.msq_type add constraint msq_answer check (correctAnswer in ('ch1','ch2','ch3','ch4'))

create table Exams.TF_type(
	questionID int ,
	correctAnswer varchar(5)

	constraint fk_TF_quest foreign key(questionID) references  Exams.questionPool(questionID)
)ON [ExaminationSystemD_FG1 ];
alter table Exams.TF_type add constraint tf_answer check (correctAnswer in ('T','F'))

create schema units
go

create table units.course(
	csrID int primary key,
	courseName varchar(10),
	minDegree int, 
	maxDegree int,
	insID int,
	teachingYear date

	constraint fk_inst_course foreign key(insID) references Person.instructor(insID)
)ON [ExaminationSystemD_FG1 ];

create table units.track(
	trackID int primary key,
)ON [ExaminationSystemD_FG1 ];
alter table units.track add trackName varchar(5)


create table units.track_course(
	trackId int,
	courseId int

	constraint fk_track_course foreign key(trackId) references units.track(trackID),
	constraint fk_course foreign key(courseId) references units.course(csrID),
	constraint composite_track_course_pk primary key(trackID,courseId)

)ON [ExaminationSystemD_FG1 ];

 CREATE TABLE  units.Intake (
    IntakeID INT PRIMARY KEY,
    IntakeCode VARCHAR(50)
)ON [ExaminationSystemD_FG1 ];



CREATE TABLE units.Department (
    deptID INT PRIMARY KEY,
    depName VARCHAR(100)
)ON [ExaminationSystemD_FG1 ];


CREATE TABLE units.Branch (
    branchID INT PRIMARY KEY,
    branchLoc VARCHAR(100)
)ON [ExaminationSystemD_FG1 ];


CREATE TABLE units.Track_Intake (
    trackID INT,
    IntakeID INT,
    PRIMARY KEY (trackID, IntakeID),
    FOREIGN KEY (trackID) REFERENCES units.Track(trackID),
    FOREIGN KEY (IntakeID) REFERENCES units.Intake(IntakeID)
)ON [ExaminationSystemD_FG1 ];


CREATE TABLE units.Intake_Department (
    IntakeID INT,
    deptID INT,
    PRIMARY KEY (IntakeID, deptID),
    FOREIGN KEY (IntakeID) REFERENCES units.Intake(IntakeID),
    FOREIGN KEY (deptID) REFERENCES units.Department(deptID)
)ON [ExaminationSystemD_FG1 ];


CREATE TABLE units.Department_Branch (
    deptID INT,
    branchID INT,
    PRIMARY KEY (deptID, branchID),
    FOREIGN KEY (deptID) REFERENCES units.Department(deptID),
    FOREIGN KEY (branchID) REFERENCES units.Branch(branchID)
)ON [ExaminationSystemD_FG1 ];




--we have four important entities instructor student exam question
--check that the student in certain track before he takes the exam
--check that the student assined to the exam before we show it to him 
--the exam should be view that we select from the exam questoin table then we go to the questoins tables to get the questoin and
--view the content + choices to him 
-- show a table that he can insert his answers to it and then compair it with the correct answer
-- count how many right answers then we update the score in std_exam table 
--check that the instructor in teach certain course before he put the exam
--instructor can update std_exam table to set student to certain exam


-- v1
-- instructor - create exam ,  add std to std_exam table,  add questions, check if he in certain course

-- student   apply in certain exam , show view exam and anwer feild(var table) , check answer with the correct answer , check that he apply in certain track
-- close view of the exam  after pass given time of the exam, update score table,
-- check date time of certain exam , (transcation)

-- t2sema
-- neveen ,abdo alla , abd elsbor
-- ana  , mostfa , marwan 


--mrwan--- check condition std in track , in std _exam table , check 3la exam date and show timer if he  did enter early
 --ana  w mostfa -- show exam, go to question_exam get question id based on exam id and type 
			     --//first logic insert answers sequentially  
			     --view (content in questions table + declare table(questionid , choice) var to insert the answer,then close view after exam end time (using trigger)
			    -- go to question table based on type and compare answr with declared table var, then update score in std_exam table



