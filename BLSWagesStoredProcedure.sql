USE [bls_emp_wages] --Use bls_emp_wages database
GO

-- Check if table object exists, if it does drop the object, if not create it below
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_01_load_wages]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_01_load_wages]
GO

-- Use bls_emp_wages database
USE [bls_emp_wages]
GO

-- Create the procedure
CREATE PROCEDURE [dbo].[usp_01_load_wages]

AS
BEGIN 

			-- Declare variables for looping through a table variable.
			-- I like the table variable approach instead of using a cursor. 
			DECLARE @BulkInsert Varchar(500)
			DECLARE @NumberState Varchar(10)
			DECLARE @TableIndex INT
			DECLARE @TableRecordCnt INT

			-- Declare table variable
			DECLARE @LoadTableNames TABLE
			(
				 vNo INT IDENTITY(1,1)
				,vName VARCHAR(10)
			)

			-- Set index to 1. This will be use to compare record count value while looping through data
			SELECT @TableIndex = 1

			-- Truncate the table. Empty it out
			TRUNCATE TABLE [bls_emp_wages].dbo.employment_wages_extract

			-- Populate table variable with table names from the LoadTableNames table in bls_emp_wages
			INSERT INTO @LoadTableNames(vName)
			SELECT [TableName]
			FROM [bls_emp_wages].[dbo].[LoadTableNames]

			-- Count the number of records in table variable and set it equal to TableRecordCnt
			SELECT @TableRecordCnt = COUNT(vNo) FROM @LoadTableNames

			-- Begin Loop
			WHILE @TableIndex <= @TableRecordCnt
					BEGIN

						   SELECT @NumberState = vName
						   FROM @LoadTableNames
						   WHERE vNo = @TableIndex -- Start with the first record and loop through add 1 to it below and start again

							-- Create string to Bulk insert into the employment_wages_extract table using a FORMATFILE	   
							Set @BulkInsert = 'BULK INSERT [bls_emp_wages].dbo.employment_wages_extract
							FROM ''/*insert path to enb files*/\cn'+@NumberState+'16.enb''
							WITH (FORMATFILE=''/*insert path to enb files*/bulk_format.txt'')'

							-- Execute string 
							exec(@BulkInsert)

							-- Add 1 to table index and start loop again getting the next record
							SELECT @TableIndex = @TableIndex + 1


					END

-- Once loop is done, insert data into the employment wages fact table
truncate table[bls_emp_wages].[dbo].[employment_wages_f]
insert into [bls_emp_wages].[dbo].[employment_wages_f]
SELECT 
       FipsCode+'-'+OwnershipCode+'-'+convert(varchar(6),NAICS)+'-'+convert(varchar(4),[Year]) as EmpWageKey
      ,FipsCode+'-'+OwnershipCode+'-'+convert(varchar(6),NAICS) as FipsNaicsKey
      ,FipsCode+'-'+convert(varchar(6),NAICS)+'-'+convert(varchar(4),[Year]) FipsNaicsYearKey
      ,FipsCode+'-'+convert(varchar(6),NAICS) as FipsNaicsCbpKey
      ,[SurveyPrefix]
      ,[FipsCode]
      ,[DataTypeCode]
      ,[SizeCode]
      ,[OwnershipCode]
      ,[NAICS]
      ,[Year]
      ,[AggLevel]
      ,[1stQtrDisclosure]
      ,[FQEst]
      ,[JanEmp]
      ,[FebEmp]
      ,[MarEmp]
      ,[1stQtrTotalWages]
      ,[1stQtrTaxableWages]
      ,[1stQtrContributions]
      ,[1stQtrAvgWeeklyWage]
      ,[2ndQtrDisclosure]
      ,[2ndQtrEst]
      ,[AprEmp]
      ,[MayEmp]
      ,[JunEmp]
      ,[2ndQtrTotalWages]
      ,[2ndQtrTaxableWages]
      ,[2ndQtrContributions]
      ,[2ndQtrAvgWeeklyWage]
      ,[3rdQtrDisclosure]
      ,[3rdQtrEst]
      ,[JulEmp]
      ,[AugEmp]
      ,[SepEmp]
      ,[3rdQtrTotalWages]
      ,[3rdQtrTaxableWages]
      ,[3rdQtrContributions]
      ,[3rdQtrAvgWeeklyWage]
      ,[4thQtrDisclosure]
      ,[4thQtrEst]
      ,[OctEmp]
      ,[NovEmp]
      ,[DecEmp]
      ,[4thQtrTotalWages]
      ,[4thQtrTaxableWages]
      ,[4thQtrContributions]
      ,[4thQtrAvgWeeklyWage]
      ,[FYDisclosure]
      ,[FYAvgEst]
      ,[FYAvgEmp]
      ,[FYTotalWages]
      ,[FYTaxableWages]
      ,[FYContributions]
      ,[FYAvgWeeklyWage]
      ,[FYAvgPay]
      ,[Open] 
  FROM [bls_emp_wages].[dbo].[employment_wages_extract]
WHERE AggLevel = '78' -- 6 digit NAICS code 
AND OwnershipCode = '5' -- Private companies only

END


