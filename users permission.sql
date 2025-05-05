*************************************************
---------- -----  student  ----------
*************************************************
Create Login student With Password = '123';

Use ExaminationSystemDb;
Create User student For Login student;

--Grant Execute on Object::creatExamView to student;
--Grant Execute on Object::answerSheet to student;
Grant Execute on Object::addAnswer to student;
Grant Execute on Object::CheckExamAccess to student;

--revoke Execute on Object::creatExamView to student;
*************************************************
---------- -----  instructor  --------------
*************************************************

Create Login instructor With Password = '123';

Use ExaminationSystemDb;

Create User instructor For Login instructor;

Grant Execute on Object::InsertQuestionsToPool to instructor;
Grant Execute on Object::Exams.InsertExam to instructor;
Grant Execute on Object::Exams.AddAnswersForMSQ to instructor;
Grant Execute on Object::Exams.AddAnswerForTF to instructor;
Grant Execute on Object::Exams.AddRandomMCQ_TF_QuestionsToExam to instructor;
Grant Execute on Object::AddStudentToExam to instructor;
Grant Execute on Object::get_all_student_for_instructor to instructor;
Grant Execute on Object::show_students_results to instructor;
Grant SELECT ON std_track TO instructor
--Alter Role db_datareader Add Member instructor;
--Alter Role db_datawriter Add Member instructor;

************************************

Grant View DEFINITION to instructor;

 ------------------------------------------------------------

Grant Execute on Schema::dbo to instructor;
 
 ------------------------------------------------------------

Deny select on Object::Person.student to instructor;
--Deny Execute on Object::CheckExamAccess to instructor;

**********************************************************
----------------------  manager  -------------------------
**********************************************************

Create Login manager With Password = '123';

Use ExaminationSystemDb;

Create User manager For Login manager;

Alter Role db_datareader Add Member manager;

--------------------------------------------------
Grant Control on Schema::dbo to manager;



--------------------------------------------------
 
Grant Create Table, Create View, Create Procedure to manager;

 --------------------------------------------------
grant select, insert, update, delete on object::units.branch to manager;

grant select, insert, update, delete on object::units.department to manager;

grant select, insert, update, delete on object::units.intake to manager;

grant select, insert, update, delete on object::units.course to manager;

grant select, insert, update, delete on object::Person.person to manager;

grant select, insert, update, delete on object::Person.student to manager;
grant select, insert, update, delete on object::Person.student to instructor;

--Deny Update on Object::Exams.std_exam to manager ;
--Deny Insert on Object::Exams.std_exam to manager;
--Deny Delete on Object::Exams.std_exam to manager;

--Deny Execute on Object::student_results_proc to manager;

*************************************************
---- ------ -----  admin  ------- ----- -------
*************************************************

Create Login [admin] With Password = '123';

Use ExaminationSystemDb;
Create User [admin] For Login [admin];


Alter Role db_owner Add Member [admin];
