--Server Audit Specifications Actions and Groups
SELECT *
FROM sys.dm_audit_actions
WHERE class_desc = 'server'

--Database Audit Specification Actions and Groups
SELECT *
FROM sys.dm_audit_actions
WHERE class_desc = 'database' OR parent_class_desc = 'database'

--Server and Database Action Groups
SELECT name, class_desc
FROM sys.dm_audit_actions
WHERE name IN (
SELECT containing_group_name
FROM sys.dm_audit_actions
)
ORDER BY class_desc, name

--Information for a specific group
SELECT *
FROM sys.dm_audit_actions
WHERE containing_group_name = 'USER_CHANGE_PASSWORD_GROUP'