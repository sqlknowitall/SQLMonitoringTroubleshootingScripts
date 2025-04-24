EXECUTE dbo.DatabaseBackup
@Databases = 'USER_DATABASES',
@URL = 'https://myaccount.blob.core.windows.net/mycontainer',
@Credential = 'MyCredential',
@BackupType = 'FULL',
@Compress = 'Y',
@Verify = 'Y'