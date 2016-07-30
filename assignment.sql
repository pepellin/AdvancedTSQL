/*
Create an employee Log table which contain all the rows with operation (insert/update/delete) performed on rows
*/
-- Use testData
-- GO

Create Table EmpDemo
(
EmpNo int identity Primary Key,
Ename Varchar(15),
Salary Money,
DeptNo int
);

Create Table [EmpDemo_Log]
(
EmpNo int ,
Ename Varchar(15),
Salary Money,
DeptNo int,
[Action] varchar(15),
DateCreated DateTime
);
Go

--1.	Create a trigger for EmpDemo table so that when a record is inserted/updated and deleted it get inserted into the EmpDemo_Log table

Create Trigger AfterCreate On EmpDemo
After Insert
As
Begin
	Declare @EmpNo int
	Declare @Ename varchar(15)
	Declare @Salary Money
	Declare @DeptNo int
	Select @EmpNo = EmpNo from inserted
	Select @EName = Ename from inserted
	Select @Salary = Salary from inserted
	Select @DeptNo = DeptNo from inserted
	Insert Into EmpDemo_Log values (@EmpNo, @Ename, @Salary, @DeptNo, 'Create', GETDATE())
END

Create Trigger [AfterDelete] On EmpDemo
After Delete
As
Begin
	Declare @EmpNo int
	Declare @Ename varchar(15)
	Declare @Salary Money
	Declare @DeptNo int
	Select @EmpNo = EmpNo from deleted
	Select @EName = Ename from deleted
	Select @Salary = Salary from deleted
	Select @DeptNo = DeptNo from deleted
	Insert Into EmpDemo_Log values (@EmpNo, @Ename, @Salary, @DeptNo, 'Delete', GETDATE())
END

Create Trigger [AfterUpdate] On EmpDemo
After Update
As
Begin
	Declare @EmpNo int
	Declare @Ename varchar(15)
	Declare @Salary Money
	Declare @DeptNo int
	Select @EmpNo = EmpNo from inserted
	Select @EName = Ename from inserted
	Select @Salary = Salary from inserted
	Select @DeptNo = DeptNo from inserted
	Insert Into EmpDemo_Log values (@EmpNo, @Ename, @Salary, @DeptNo, 'Update', GETDATE())
END

Drop trigger AfterUpdate
Insert Into EmpDemo Values ('testtt!', 150.00, 3);
select * from EmpDemo;
select * from EmpDemo_Log;
Delete from EmpDemo Where EmpNo = 10;
Delete from EmpDemo;
Delete from EmpDemo_Log;
Update EmpDemo Set Ename = 'updated test' where EmpNo = 11;

--2.	Write a procedure to get employee data based on DeptNo. If value for DeptNo  is not given get all employees (Using Optional parameter)
Create Procedure 
GetEmpData 
(
	@Number int = null
)
As
Begin
	If (@Number IS NULL)
		Begin
			Select * From EmpDemo;
		End
	Else
		Begin
			Select * From EmpDemo Where DeptNo = @Number;
		End
End
Go

drop procedure GetEmpData
Exec GetEmpData @Number = 1
Select * from EmpDemo

--3.	Write a procedure to insert data into EmpDemo table and get new EmpNo generated as Output parameter
Create Procedure InsertToEmpDemo 
(
	@Ename varchar(15),
	@Salary Money,
	@DeptNo int,
	@EmpNo int output
)
As
Begin 
	Insert into EmpDemo Values (@Ename, @Salary, @DeptNo);
End
GO

Drop Procedure InsertToEmpDemo;
Declare @EmpNoReturn int;
Exec InsertToEmpDemo 'John', 100.00, 20, @EmpNoReturn Output;
Print @EmpNoReturn;

Select * from EmpDemo;
Select * from EmpDemo_Log;

--4.	Write a user defined function to get total salary of given department (user transaction and error handling)
Create Function GetDeptSalary(@DeptNo int)
Returns Money
As
Begin
	Declare @ret Money;
	Select @ret = SUM(E.Salary) From EmpDemo As E Where E.DeptNo = @DeptNo Group By DeptNo;
	If (@ret Is Null)
		Set @ret = 0
		Return @ret
End

drop function GetDeptSalary

Create Procedure SP
As
Begin
	Begin try
		Begin Tran
			Select distinct E.DeptNo, dbo.GetDeptSalary(3) From EmpDemo As E where E.DeptNo = 3;
		Commit Tran
	End try
	Begin catch
		Print 'error'
		Rollback Tran
	End catch
End

Select * From EmpDemo;

Exec SP;

--5.	Write a user defined function to get department and total salary
Create Function GetEachDeptSalary()
Returns Table
As
Return
(
	Select DeptNo, SUM(Salary) As Total From EmpDemo Group By DeptNo
);

Select * From GetEachDeptSalary();

--6.	Write a Cursor to concatenate all ename from EmpDemo table to a string
Declare @Ename varchar(50);
Declare @EnameAll nvarchar(100);
DECLARE @MyCursor CURSOR 
SET @MyCursor = CURSOR
	For Select Ename From EmpDemo
OPEN @MyCursor
FETCH NEXT FROM @MyCursor
INTO @Ename
WHILE @@FETCH_STATUS = 0
	BEGIN
		Set @EnameAll =  Concat(@EnameAll, @Ename)
		print @EnameAll
		FETCH NEXT FROM @MyCursor
		INTO @Ename
	END
	print @EnameAll
CLOSE @MyCursor
DEALLOCATE @MyCursor


--7.	Create a view for EmpDemo table and try to Insert records into the view
Create View EmpDemoView
AS 
Select * From EmpDemo

Select * From EmpDemoView
Insert into EmpDemoView Values ('insertIntoView', 5, 5);

Select * From EmpDemo

/*
ERROR_NUMBER() Returns error number

ERROR_MESSAGE() Returns the error message

ERROR_SEVERITY() Returns the severity of error

ERROR_STATE() Returns the state of the error

ERROR_LINE() Returns the line number

ERROR_PROCEDURE() Return the procedure or trigger name in which error occurred.


@@ Version Date of the current version of SQL Server

@@ Servername Name of the SQL Server

@@ Error 0 if last transaction succeeded, else last error no

@@ Total_Errors Contains the total number of errors that have occurred while the 

@@Fetch_Status Status of Last Cursor fetch Operation current SQL Server session is on.

0 � Success, 
1 � Failed because of end of rows or beginning of the row
2 � Failed because a row wasn�t found.

@@Identity Last set identity column value on current connection otherwise Ident_Current(�tablename�) Same as @@IDENTITY but return for a specified table

@@RowCount No of rows affected by last statement.
*/