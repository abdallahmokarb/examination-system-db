# Examination System Database 
SQL Server database schema for an Examination System, designed to manage students, instructors, courses, exams, questions, and student answers in an academic setting. The database supports tracking student performance, exam scheduling, and question management with multiple-choice (MSQ) and true/false (TF) question types


# Designed, Programmed, and Developed by Software Engineers

# Neveen Reda

# Said Ali

# Mostafa Mohamed

# MarwaN 3bdeeN

# Abdelraman Abdelsabour

# Abdallah Hassan Mokarb

User Management: Stores personal details (person) and roles (students, instructors) with email and password validation.

Course and Track Management: Organizes courses (course) and tracks (track) with many-to-many relationships (track_course).

Exam Management: Schedules exams (exam) with types (normal, corrective), dates, and times, linked to courses and instructors.

Question Bank: Manages a question pool (questionPool) with MSQ (msq_type) and TF (tf_type) questions, including content, degree, and correct answers.

Student Answers: Tracks student responses (student_answers) to exam questions.

Views: Includes a view to display exam questions, choices, correct answers, and student answers for a student-focused perspective.

License
Licensed under the MIT License.
