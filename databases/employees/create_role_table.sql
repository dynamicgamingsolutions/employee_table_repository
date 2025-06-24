USE employees
GO
-- Create the table with `uuid` allowing NULL
CREATE TABLE roles (
    uuid UNIQUEIDENTIFIER NULL DEFAULT NEWID(), -- Allow NULL and auto-generate UUID not if provided
    index_key INT IDENTITY(1,1) NOT NULL, -- Auto-incrementing identity column
    reference_key NVARCHAR(25) NULL,
    insert_date DATETIME NULL DEFAULT GETDATE(),
    update_date DATETIME NULL DEFAULT GETDATE(),
    update_by VARCHAR(50) NULL,
    change_log VARCHAR(255) NULL,
    [role] NVARCHAR(50) NOT NULL,
    [permissions] NVARCHAR(MAX) NULL
)

USE employees
GO
CREATE TRIGGER [dbo].[trg_insert_role]
ON [dbo].[roles]
AFTER INSERT
AS
BEGIN
    -- Ensure UUID is generated for rows where it is NULL
    UPDATE ro
    SET ro.uuid = NEWID()
    FROM roles ro
    INNER JOIN inserted i ON ro.index_key = i.index_key
    WHERE ro.uuid IS NULL;

    -- Populate reference_key and change_log for newly inserted rows
    UPDATE ro
    SET
        ro.reference_key = 'RT-' + RIGHT('000' + CAST(ro.index_key AS VARCHAR), 3),
        ro.change_log = 'Created on ' + CONVERT(NVARCHAR, GETDATE(), 120)
    FROM roles ro
    INNER JOIN inserted i ON ro.index_key = i.index_key;

    -- Insert into activity_logs only if UUID is not NULL
    INSERT INTO logs.dbo.activity_logs (log_id, change_log, update_by, table_name)
    SELECT 
        i.uuid AS log_id, -- Use the UUID column
        i.change_log + CONVERT(NVARCHAR, GETDATE(), 120) AS change_log,
        i.update_by AS update_by, -- Replace with appropriate value
        'roles' AS table_name
    FROM inserted i
    WHERE i.uuid IS NOT NULL; -- Ensure UUID is not NULL
END
