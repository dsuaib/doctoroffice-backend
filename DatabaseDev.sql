/* create valid payment table  */
CREATE TABLE ValidPaymentType 
PaymentTypeID int IDENTITY NOT NULL PRIMARY KEY,
PaymentType varchar(50) NOT NULL UNIQUE,

/* create payment table  */
CREATE TABLE Payment 
PaymentID int IDENTITY NOT NULL PRIMARY KEY,
Date date NOT NULL,
PaymentAmount numeric(12,2) NOT NULL,
PaymentTypeID int NOT NULL FOREIGN KEY REFERENCES ValidPaymentType(PaymentTypeID),
PatientID int NOT NULL FOREIGN KEY REFERENCES Patient(PatientID)

/* create valid diagnosis type table  */
CREATE TABLE ValidDiagnosisType 
DiagnosisID int IDENTITY NOT NULL PRIMARY KEY,
DiagnosisName varchar(50) NOT NULL UNIQUE,

/* create employee table  */
CREATE TABLE Employee 
EmployeeID int IDENTITY NOT NULL PRIMARY KEY,
FirstName varchar(50) NOT NULL,
LastName varchar(50) NOT NULL,
OfficeID int NOT NULL FOREIGN KEY REFERENCES Office(OfficeID),
DepartmentID int NOT NULL FOREIGN KEY REFERENCES Department(DepartmentID),
SSN int NOT NULL UNIQUE,
Salary numeric (12,2) NOT NULL,
GenderID int NOT NULL FOREIGN KEY REFERENCES Gender(GenderID)

/* create record table  */
CREATE TABLE Record 
RecordID int IDENTITY NOT NULL PRIMARY KEY,
Date date NOT NULL,
AmountCharged numeric(12,2) NOT NULL,
DiagnosisID int NOT NULL FOREIGN KEY REFERENCES ValidDiagnosisType(DiagnosisID),
EmployeeID int NOT NULL FOREIGN KEY REFERENCES Employee(EmployeeID),
PatientID int NOT NULL FOREIGN KEY REFERENCES Patient(PatientID)

/*  create procedure to show error information for easier debugging */

create procedure ShowErrorDetails  
as  
select  
     ERROR_STATE() as ErrorState,
	 ERROR_LINE() as ErrorLine,
     ERROR_NUMBER() as ErrorNumber,
	 ERROR_SEVERITY() as ErrorSeverity,   
     ERROR_PROCEDURE() as ErrorProcedure,    
     ERROR_MESSAGE() as ErrorMessage
     if @@TRANCOUNT > 0  
        rollback transaction    
go; 

/* Procedure to add officetype */

create procedure add_officetype (@OfficeType varchar(50))
as
begin
begin try
/* check to see if the diagnosis already exists in table  */
If exists (select 1 from ValidOfficeType where lower(OfficeType) = lower(@OfficeType))
begin
select 'Cannot add another office of the same type'
return
end
begin transaction
/* Attempt to insert values passed in */
insert into ValidOfficeType values (@OfficeType)
/* Error checking to rollback transaction if an error has occurred */
If @@error <> 0
Begin
Print 'An error has occurred and the office type was not added'
Rollback Transaction
Return
End
commit transaction
begin
print 'The office type has been successfully added'
end
end try
begin catch  
/* If an error show the errors from procedure */
execute ShowErrorDetails
end catch  
end;


/* Procedure to add office */
create procedure add_office (@OfficeName varchar(50), @OfficeTypeID int, @Address varchar(50), @City varchar(50), @State varchar(50), @ZIP int)
as
begin
begin try
/* check to see if the office name already exists  */
If exists (select 1 from Office where lower(OfficeName) = lower(@OfficeName))
begin
select 'Cannot add another office with the same office name'
return
end
begin transaction
/* Attempt to insert values passed in */
insert into Office values (@OfficeName, @OfficeTypeID, @Address, @City, @State, @ZIP)
/* Error checking to rollback transaction if an error has occurred */
If @@error <> 0
Begin
Print 'An error has occurred and the office was not added'
Rollback Transaction
Return
End
commit transaction
Begin
print 'The office has been successfully added'
end
end try
begin catch  
/* If an error show the errors from procedure */
execute ShowErrorDetails
end catch  
end;


/* Procedure to update address */
create procedure update_address
(@OfficeID int, @Address varchar(50), @City varchar(50), @State varchar(50), @ZIP int)
as
begin
begin try
/* Make sure the OfficeID exist */
if not exists (select 1 from Office
where (OfficeID) = (@OfficeID))
begin
select 'You must enter an OfficeID that exists'
return
end
begin transaction
/* update statement to update the address of the office */
update Office set Address = @Address, City = @City, State = @State, ZIP = @ZIP where OfficeID = @OfficeID
/* error checking and returning an error message if error exists */
If @@error <> 0
Begin
Print 'An error has occured while updating the address for this office. The address has not been updated'
Rollback Transaction
Return
End
commit transaction
/* show a message on successful update */
begin
print 'The office address has been updated successfully'
end
end try
begin catch 
execute ShowErrorDetails
end catch  
End;


/* procedure delete_office */
create procedure delete_office
(@OfficeID int)
as
begin
  begin try
  /* Make sure the OfficeID exist */
if not exists (select 1 from Office
where (OfficeID) = (@OfficeID))
begin
select 'You must enter an OfficeID that exists'
return
end
begin transaction
/* delete statement to delete office from passed in OfficeID */
delete from Office where OfficeID = @OfficeID
/* error checking and returning an error message if error exists */
If @@error <> 0
Begin
Print 'An error has occurred while deleting this office. This office has not been deleted'
Rollback Transaction
Return
End
commit transaction
/* show a message on successful deletion */
begin
print 'The office has been deleted successfully'
end
end try
begin catch 
execute ShowErrorDetails
end catch  
end;


/* procedure report_offices_in_ZIP */
create procedure report_offices_in_ZIP
(@ZIP int)
as
begin
begin try
  /* Make sure the ZIP of an office exists */
if not exists (select 1 from Office
where (ZIP) = (@ZIP))
begin
select 'No offices have this ZIP code'
return
end
/* Report offices in that ZIP code area */
select OfficeName, Address, City, State, ZIP from Office where ZIP = @ZIP
/* error checking and returning an error message if error exists */
If @@error <> 0
Begin
Print 'An error has occurred while searching for offices in this ZIP code'
Return
End
end try
begin catch 
execute ShowErrorDetails
end catch  
end;


/* procedure add_department */
create procedure add_department (@DepartmentName varchar(50), @OfficeID int)
as
begin
begin try
/* check to see if the department name already exists  */
If exists (select 1 from Department where lower(DepartmentName) = lower(@DepartmentName))
begin
select 'Cannot add another department with the same department name'
return
end
/* Make sure another department cannot be added to an office where a department already exists */
If exists (select 1 from Department where OfficeID = @OfficeID)
begin
print 'A department is already located in that office'
return
end
begin transaction
/* Attempt to insert values passed in */
insert into Department values (@DepartmentName, @OfficeID)
/* Error checking to rollback transaction if an error has occurred */
If @@error <> 0
Begin
Print 'An error has occurred and the department was not added'
Rollback Transaction
Return
End
commit transaction
begin
print 'The department has been successfully added'
end
end try
begin catch  
/* If an error show the errors from procedure */
Execute ShowErrorDetails
end catch
end;


/* create procedure update_department_name */
create procedure update_department_name
(@DepartmentID int, @DepartmentName varchar(50))
as
begin
begin try
  /* Make sure the OfficeID exist */
if not exists (select 1 from Department
where (DepartmentID) = (@DepartmentID))
begin
select 'You must enter a DepartmentID that exists'
return
end
begin transaction
/* update statement to update the department name */
update Department set DepartmentName = @DepartmentName where DepartmentID = @DepartmentID
/* error checking and returning an error message if error exists */
If @@error <> 0
Begin
Print 'An error has occured while updating the name for this department. The department has not been updated'
Rollback Transaction
Return
End
commit transaction
/* show a message on successful update */
begin
print 'The department name has been updated successfully'
end
end try
begin catch 
execute ShowErrorDetails
end catch  
end;


/* create procedure delete_department */
create procedure delete_department
(@DepartmentID int)
as
begin
begin try
 /* Make sure the DepartmentID exists */
if not exists (select 1 from Department
where (DepartmentID) = (@DepartmentID))
begin
select 'You must enter an DepartmentID that exists'
return
end
begin transaction
/* delete statement to delete department from passed in DepartmentID */
delete from Department where DepartmentID = @DepartmentID
/* error checking and returning an error message if error exists */
if @@error <> 0
Begin
Print 'An error has occurred while deleting this department. This department has not b	een deleted.'
Rollback Transaction
Return
End
commit transaction
/* show a message on successful deletion */
begin
print 'The department has been deleted successfully'
end
end try
begin catch 
execute ShowErrorDetails
end catch  
end;


/* create procedure add_gender */
create procedure add_gender (@GenderName varchar(50))
as
begin
begin try
/* check to see if the gender already exists in table  */
If exists (select 1 from Gender where lower(GenderName) = lower(@GenderName))
begin
select 'Cannot add another gender with the same gender name'
return
end
begin transaction
/* Attempt to insert values passed in */
insert into Gender values (@GenderName)
/* Error checking to rollback transaction if an error has occurred */
If @@error <> 0
Begin
Print 'An error has occurred and the gender was not added'
Rollback Transaction
Return
End
commit transaction
begin
print 'The gender has been successfully added'
end
end try
begin catch  
/* If an error show the errors from procedure */
execute ShowErrorDetails
end catch  
end;


/* create procedure add_employee */
create procedure add_employee (@FirstName varchar(50), @LastName varchar(50), @OfficeID int, @DepartmentID int, @SSN int, @Salary numeric(12,2),  @GenderID int)
as
begin
begin try
/* check to see if the employee already exists  */
If exists (select 1 from Employee where SSN = @SSN)
begin
select 'Cannot add another employee with the same SSN'
return
end
/* Make sure salary is not a negative amount*/
if @Salary < 0
begin
select  'Salary amount cannot be below 0'
return
end
begin transaction
/* Attempt to insert values passed in */
insert into Employee values(@FirstName, @LastName,@OfficeID, @DepartmentID, @SSN, @Salary,  @GenderID)
/* Error checking to rollback transaction if an error has occurred */
If @@error <> 0
Begin
Print 'An error has occurred and the employee was not added'
Rollback Transaction
Return
End
commit transaction
begin
print 'The employee has been successfully added'
end
end try
begin catch  
/* If an error show the errors from procedure */
execute ShowErrorDetails
end catch  
end


/* report_average_gender_salary */
create procedure report_average_gender_salary
(@GenderID int)
as
begin
begin try
/* Make sure the gender exists in the table */
if not exists (select 1 from Employee
where (GenderID) = (@GenderID))
begin
select 'Please enter a GenderID that exists in the employee table'
return
end
begin transaction
/* Report all the average salary of the GenderID passed in */
select AVG(Salary) from Employee where GenderID = @GenderID
/* error checking and returning an error message if error exists */
If @@error <> 0
Begin
Print 'An error has occurred while calculating the average salary'
Rollback Transaction
Return
End
commit transaction
end try
begin catch 
 execute ShowErrorDetails
end catch  
end


/* create procedure delete_employee */
create procedure delete_employee
(@EmployeeID int)
as
begin
begin try
/* Make sure the EmployeeID exists */
if not exists (select 1 from Employee
where (EmployeeID) = (@EmployeeID))
begin
select 'You must enter an EmployeeID that exists'
return
end
begin transaction
/* delete statement to delete employee from passed in EmployeeID */
delete from Employee where EmployeeID = @EmployeeID
/* error checking and returning an error message if error exists */
If @@error <> 0
Begin
Print 'An error has occurred while deleting this employee. This employee has not been deleted'
Rollback Transaction
Return
End
commit transaction
/* show a message on successful deletion */
begin
print 'The employee has been deleted successfully'
end
end try
begin catch 
execute ShowErrorDetails
end catch  
end;


/* create procedure update_employee_information */
create procedure update_employee_information
 (@EmployeeID int, @FirstName varchar(50), @LastName varchar(50), @OfficeID int, @DepartmentID int, @SSN int, @Salary numeric(12,2), @GenderID int)
as
begin
begin try
/* Make sure the EmployeeID exists */
if not exists (select 1 from Employee
where (EmployeeID) = (@EmployeeID))
begin
select 'You must enter an EmployeeID that exists'
return
end
/* Make sure salary is not a negative amount*/
if @Salary < 0
begin
select  'Salary amount cannot be below 0'
return
end
begin transaction
/* update statement to update the employee information */
update Employee set FirstName = @FirstName, LastName = @LastName, OfficeID = @OfficeID, DepartmentID = @DepartmentID, SSN = @SSN, Salary = @Salary,  
GenderID = @GenderID
/* error checking and returning an error message if error exists */
If @@error <> 0
Begin
Print 'An error has occured while updating the employee information. The employee information has not been updated'
Rollback Transaction
Return
End
commit transaction
/* show a message on successful update */
begin
print 'The employee information has been updated successfully'
end
end try
begin catch 
execute ShowErrorDetails
end catch  
end;


/* create procedure increase_employee_salary */
create procedure increase_employee_salary
  (@EmployeeID int, @Salary numeric(12,2))
as
begin
begin try
/* Make sure the EmployeeID exists */
if not exists (select 1 from Employee
where (EmployeeID) = (@EmployeeID))
begin
select 'You must enter an EmployeeID that exists'
return
end
/* Make sure salary is not a negative amount*/
if @Salary < 0
begin
select  'Salary amount cannot be below 0'
return
end
/* Make sure salary not lower than previous salary */
declare @OriginalSalary numeric(12,2)
select @OriginalSalary = (select Salary from Employee where EmployeeID = @EmployeeID)
if (@Salary < @OriginalSalary) 
begin
select  'Salary amount cannot be less than previous salary'
return
end
begin transaction
/* update statement to update the employee information */
update Employee set Salary = @Salary where EmployeeID = @EmployeeID
/* error checking and returning an error message if error exists */
If @@error <> 0
Begin
Print 'An error has occured while updating the employee information. The employee information has not been updated'
Rollback Transaction
Return
End
commit transaction
/* show a message on successful update of salary and salary amount */
begin
select Salary as "The employee salary has been successfully updated to" from Employee where EmployeeID = @EmployeeID  
end
end try
begin catch 
execute ShowErrorDetails
end catch  
end;


/* create procedure add_patient  */
create procedure add_patient 
(@FirstName varchar(50), @LastName varchar(50), @DateOfBirth date, @Address varchar(50), @City varchar(50), @State varchar(50), @ZIP int, @AccountBalance numeric(12,2))
as
begin
begin try
/* check to see if the patient already exists  */
If exists (select 1 from Patient where lower(FirstName) = lower(@FirstName) and lower(LastName) = lower(@LastName)
and DateOfBirth = @DateOfBirth)
begin
select 'There is already a patient that exists with the same name and date of birth'
return
end
begin transaction
/* Attempt to insert values passed in */
insert into Patient values (@FirstName, @LastName, @DateOfBirth, @Address, @City, @State, @ZIP, @AccountBalance)
/* Error checking to rollback transaction if an error has occurred */
If @@error <> 0
Begin
Print 'An error has occurred and the patient was not added'
Rollback Transaction
Return
End
commit transaction
begin
print 'The patient has been successfully added'
end
end try
begin catch  
/* If an error show the errors from procedure */
 execute ShowErrorDetails
end catch  
end;


/* create procedure update_patient_information */
create procedure update_patient_information
(@PatientID int, @FirstName varchar(50), @LastName varchar(50), @DateOfBirth date, @Address varchar(50), @City varchar(50),
@State varchar(50), @ZIP int, @AccountBalance numeric(12,2))
as
begin
begin try
/* Make sure the PatientID exists */
if not exists (select 1 from Patient
where (PatientID) = (@PatientID))
begin
select 'You must enter an PatientID that exists'
return
end
begin transaction
/* update statement to update the patient information */
update Patient set FirstName = @FirstName, LastName = @LastName, DateOfBirth = @DateOfBirth, Address = @Address, 
City = @City, State = @State, ZIP = @ZIP, AccountBalance = @AccountBalance where PatientID = @PatientID 
/* error checking and returning an error message if error exists */
If @@error <> 0
Begin
Print 'An error has occured while updating the patient information. The patient information has not been updated'
Rollback Transaction
Return
End
commit transaction
/* show a message on successful update */
begin
print 'The patient information has been updated successfully'
end
end try
begin catch 
execute ShowErrorDetails
end catch  
End;


/* create procedure add_diagnosis */
create procedure add_diagnosis (@DiagnosisName varchar(50))
as
begin
begin try
/* check to see if the diagnosis already exists in table  */
If exists (select 1 from ValidDiagnosisType where lower(DiagnosisName) = lower(@DiagnosisName))
begin
select 'Cannot add another diagnosis with the same diagnosis name'
return
end
begin transaction
/* Attempt to insert values passed in */
insert into ValidDiagnosisType values (@DiagnosisName)
/* Error checking to rollback transaction if an error has occurred */
If @@error <> 0
Begin
Print 'An error has occurred and the diagnosis was not added'
Rollback Transaction
Return
End
commit transaction
begin
print 'The diagnosis has been successfully added'
end
end try
begin catch  
/* If an error show the errors from procedure */
execute ShowErrorDetails
end catch  
End;


/* create procedure add_record_of_patient_appointment */
create procedure add_record_of_patient_appointment 
(@Date date, @AmountCharged numeric(12,2), @DiagnosisID int, @EmployeeID int, @PatientID int) 
as
begin
begin try
/* check to see if the employee exists  */
If not exists (select 1 from Employee where EmployeeID = @EmployeeID)
begin
select 'The EmployeeID entered does not exist'
return
end
/* Make sure amount charged has to be above 0*/
if @AmountCharged <= 0
begin
select  'The amount charged has to be more than 0'
return
end
/* check to see if the patient exists  */
If exists (select 1 from Patient where PatientID = @PatientID)
begin
select 'The PatientID entered does not exist'
return
end
If not exists (select 1 from ValidDiagnosisType where DiagnosisID = @DiagnosisID)
begin
select 'The DiagnosisID entered does not exist'
return
end 
begin transaction
/* Attempt to insert values passed in */
insert into Record values (@Date, @AmountCharged, @DiagnosisID, @EmployeeID, @PatientID)
/* Error checking to rollback transaction if an error has occurred */
If @@error <> 0
Begin
Print 'An error has occurred and the record was not added'
Rollback Transaction
Return
End 
commit transaction 
begin
print 'The record of the appointment has been added successfully'
end
end try 
begin catch  
/* If an error show the errors from procedure */
execute ShowErrorDetails
end catch  
End;


/* create trigger trigger_update_accountbalance */
create trigger trigger_update_accountbalance
on Record
for insert
as
begin
begin try
/* create variables to grab values from inserted */
declare @AmountCharged numeric(12,2)
select @AmountCharged = (select AmountCharged from inserted)
declare @PatientID int
select @PatientID = (select PatientID from inserted)
/* update patient account balance with amount charged */
update Patient set AccountBalance = AccountBalance + @AmountCharged
where (PatientID) = (@PatientId)
If @@error <> 0
begin
Print 'An error has occured while updating the patient account balance. The patient account balance has not been updated'
rollback transaction
end
end try
begin catch 
execute ShowErrorDetails
end catch 
End;


/* create procedure report_patient_information */
create procedure report_patient_information
(@FirstName varchar(50), @LastName varchar(50), @DateOfBirth date)
as
begin
begin try
/* Check to see if the patient exists */
If not exists (select 1 from Patient where lower(FirstName) = lower(@FirstName) and lower(LastName) = lower(@LastName)
and DateOfBirth = @DateOfBirth)
begin
select 'No patients with the name and date of birth entered exists'
return
end
/* Report all of the patient information from values passed in  */
select * from Patient where lower(FirstName) = lower(@FirstName) and lower(LastName) = lower(@LastName) and (DateOfBirth) = (@DateOfBirth)
/* error checking and returning an error message if error exists */
If @@error <> 0
Begin
Print 'An error has occurred while searching for patient information'
Return
End
end try
begin catch 
execute ShowErrorDetails
end catch  
end;


/* create procedure add_paymenttype */
create procedure add_paymenttype (@PaymentType varchar(50))
as
begin
begin try
/* check to see if the diagnosis already exists in table  */
If exists (select 1 from ValidPaymentType where lower(PaymentType) = lower(@PaymentType))
begin
select 'Cannot add another payment of the same type'
return
end
begin transaction
/* Attempt to insert values passed in */
insert into ValidPaymentType values (@PaymentType)
/* Error checking to rollback transaction if an error has occurred */
If @@error <> 0
Begin
Print 'An error has occurred and the payment type was not added'
Rollback Transaction
Return
End
commit transaction
begin
print 'The payment type has been successfully added'
end
end try
begin catch  
/* If an error show the errors from procedure */
execute ShowErrorDetails;=
end catch
End;


/* create procedure record_patient_payment */
create procedure record_patient_payment 
(@Date date, @PaymentAmount numeric(12,2), @PaymentTypeID int, @PatientID int)
as
begin
begin try
 /* Check if PatientID exists */
if not exists (select 1 from Patient
where  (PatientID) =  (@PatientID))
begin
select 'The PatientID entered does not exist'
return
end
 /* Check if PaymentTypeID exists */
if not exists (select 1 from ValidPaymentType
where  (PaymentTypeID) =  (@PaymentTypeID))
begin
select 'The PaymentTypeID entered does not exist'
return
end
/* Check to see if payment amount is greater than 0  */
if @PaymentAmount <= 0
begin
select 'The payment amount has to be greater than 0'
return
end
begin transaction
/* Attempt to insert values passed in */
insert into Payment values (@Date, @PaymentAmount, @PaymentTypeID, @PatientID)
/* Error checking to rollback transaction if an error has occurred */
If @@error <> 0
Begin
Print 'An error has occurred and the payment was not recorded'
Rollback Transaction
Return
End
commit transaction
begin
print 'The payment has been successfully recorded'
end
end try
begin catch  
/* If an error show the errors from procedure */
execute ShowErrorDetails
end catch  
End;


/* Trigger to reduce a patient's balance upon payment */
create trigger trigger_reduce_balance_from_payment
on Payment
for insert
as
begin
begin try
/* create variables to grab values from inserted */
declare @PaymentAmount numeric(12,2)
select @PaymentAmount = (select PaymentAmount from inserted)
declare @PatientID int
select @PatientID = (select PatientID from inserted)
/* reduce the balance with the amount charged */
update Patient set AccountBalance = AccountBalance - @PaymentAmount
where (PatientID) = (@PatientID)
If @@error <> 0
begin
print 'An error has occured while reducing the patient account balance from the payment inserted'
rollback transaction
end
end try
begin catch  
execute ShowErrorDetails
end catch
End;


/* procedure to report_total_diagnosis_cost_for_patients */
create procedure report_total_diagnosis_cost_for_patients
(@DiagnosisID int)
as
begin
begin try
/* Make sure the diagnosis exists */
if not exists (select 1 from Record
where (DiagnosisID) = (@DiagnosisID))
begin
select 'Please enter a diagnosis that a patient has been given'
return
end
/* Report the total cost of the diagnosis for every patient on record */
select SUM(AmountCharged) from Record where DiagnosisID = @DiagnosisID
/* error checking and returning an error message if error exists */
If @@error <> 0
Begin
Print 'An error has occurred while reporting the total diagnosis cost'
Return
End
end try
begin catch 
execute ShowErrorDetails
end catch  
End


/* procedure to report_salary_budget_of_department */
create procedure report_salary_budget_of_department
(@DepartmentID int)
as
begin
begin try
/* Make sure the gender exists in the table */
if not exists (select 1 from Employee
where (DepartmentID) = (@DepartmentID))
begin
select 'Please enter a Department that exists in the employee table'
return
end
/* Report all the salary total of the employees in that department */
select SUM(Salary) from Employee where DepartmentID = @DepartmentID
/* error checking and returning an error message if error exists */
If @@error <> 0
Begin
Print 'An error has occurred while reporting the salary budget'
Return
End
end try
begin catch 
execute ShowErrorDetails
end catch  
End;
