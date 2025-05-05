------------insertion 
INSERT INTO units.track (trackID, trackName) VALUES
(1,  'CS'),
(2,  'AI'),
(3,  'DS'),
(4,  'SE'),
(5, 'IT');


INSERT INTO Person.person (personID, firstName, lastName, email, password, role)
VALUES
(1, 'Ali', 'Said', 'ali@exam.com', 'passAli', 'student'),
(2, 'Sara', 'Ali', 'sara@exam.com', 'passSara', 'student'),
(3, 'Omar', 'Ibrahim', 'omar@exam.com', 'passOmar', 'instructor'),
(4, 'Mona', 'Fathy', 'mona@exam.com', 'passMona', 'instructor'),
(5, 'Tarek', 'Gamal', 'tarek@exam.com', 'passTarek', 'student');

INSERT INTO Person.instructor (InsID, personID) VALUES
(1, 3),
(2, 4);

INSERT INTO Person.student (stdID, personID, trackId) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 5, 3);

INSERT INTO units.course (csrID, courseName, minDegree, maxDegree, insID, teachingYear) VALUES
(1, 'Math', 50, 100, 1, '2024-01-01'),
(2, 'AI', 40, 100, 2, '2024-01-01'),
(3, 'DS', 60, 100, 1, '2024-01-01'),
(4, 'SE', 70, 100, 2, '2024-01-01'),
(5, 'DB', 65, 100, 1, '2024-01-01');

INSERT INTO units.track_course (trackId, courseId) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);


INSERT INTO Exams.exam (examID, examType, startTime, endTime, insID, examDate, csrID) VALUES
(1, 'normal', '09:00', '11:00', 1, '2024-05-01', 1),
(2, 'corrective', '10:00', '12:00', 2, '2024-05-02', 2),
(3, 'normal', '11:00', '13:00', 1, '2024-05-03', 3),
(4, 'normal', '08:00', '10:00', 2, '2024-05-04', 4),
(5, 'corrective', '13:00', '15:00', 1, '2024-05-05', 5);

INSERT INTO Exams.std_exam (stdID, examID, score) VALUES
(1, 1, 0),
(2, 2, 0),
(3, 3, 0),
(1, 4, 0),
(2, 5, 0);

INSERT INTO Exams.questionPool (questionID, content, degree, qType)
VALUES
(1, 'C# is a programming language', 5, 'TF'),
(2, 'Which data type is used to store whole', 5, 'MCQ'),
(3, 'True or False: int can store decimal numbers in C#', 5, 'TF'),
(4, 'Which keyword is used to define a class in C#?', 5, 'MCQ'),
(5, 'True or False: "if" is a loop in C#', 5, 'TF');



INSERT INTO Exams.exam_question (examID, questionID) VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(3, 5);

INSERT INTO Exams.msq_type (questionID, ch1, ch2, ch3, ch4, correctAnswer)
VALUES
(2, 'int', 'float', 'string', 'bool', 'ch1'),  
(4, 'define', 'object', 'class', 'struct', 'ch3');

INSERT INTO Exams.TF_type (questionID, correctAnswer)
VALUES
(1, 'T'), 
(3, 'F'), 
(5, 'F');