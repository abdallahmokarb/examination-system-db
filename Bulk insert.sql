

Bulk insert Person.person
From 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Persons.csv'
With (
	Fieldterminator = ',',
	Rowterminator = '\n',
	Firstrow = 2
);

 select * From Person.person

 Delete From Person.person;

  -- ***************************************************************

Bulk insert Person.student
From 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Students.csv'
With (
	Fieldterminator = ',',
	Rowterminator = '\n',
	Firstrow = 2
);

 Delete From Person.student;


 select * From Person.student
 
 -- ***************************************************************

