USE employees
GO

-- Create the table with `uuid` allowing NULL
CREATE TABLE employee_roles (
    uuid UNIQUEIDENTIFIER NULL DEFAULT NEWID(), -- Allow NULL and auto-generate UUID not if provided
    index_key INT IDENTITY(1,1) NOT NULL, -- Auto-incrementing identity column
    reference_key NVARCHAR(25) NULL,
    insert_date DATETIME NULL DEFAULT GETDATE(),
    update_date DATETIME NULL DEFAULT GETDATE(),
    update_by VARCHAR(50) NULL,
    change_log VARCHAR(255) NULL,
    first_name nvarchar(100) NULL,
	last_name nvarchar(100) NULL,
    email nvarchar(50) NOT NULL,
    role_id nvarchar(50) NOT NULL,
    active bit NULL,
    override_permissions NVARCHAR(MAX) NULL,
    [name] nvarchar(50) NOT NULL
)

USE employees
GO
CREATE TRIGGER [dbo].[trg_insert_employee]
ON [dbo].[employee_roles]
AFTER INSERT
AS
BEGIN
    -- Ensure UUID is generated for rows where it is NULL
    UPDATE emp
    SET emp.uuid = NEWID()
    FROM employee_roles emp
    INNER JOIN inserted i ON emp.index_key = i.index_key
    WHERE emp.uuid IS NULL;

    -- Populate reference_key and change_log for newly inserted rows
    UPDATE emp
    SET
        emp.reference_key = 'EMP-' + RIGHT('000000' + CAST(emp.index_key AS VARCHAR), 6),
        emp.change_log = ISNULL(emp.change_log, 'Created on ' + CONVERT(NVARCHAR, GETDATE(), 120)) -- Ensure change_log is not NULL
    FROM employee_roles emp
    INNER JOIN inserted i ON emp.index_key = i.index_key;

    -- Insert into activity_logs only if UUID is not NULL
    INSERT INTO logs.dbo.activity_logs (log_id, change_log, update_by, table_name)
    SELECT 
        i.uuid AS log_id, -- Use the UUID column
        ISNULL(i.change_log, 'Created on ' + CONVERT(NVARCHAR, GETDATE(), 120)) AS change_log, -- Ensure change_log is not NULL
        i.update_by AS update_by, -- Replace with appropriate value
        'employee_roles' AS table_name -- Corrected table name
    FROM inserted i
    WHERE i.uuid IS NOT NULL; -- Ensure UUID is not NULL
END
GO
