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
