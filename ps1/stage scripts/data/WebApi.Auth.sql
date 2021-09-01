                                                                                 
IF EXISTS (SELECT * FROM [WebApi.Auth].Settings.Options
    WHERE Name = 'Auth.AccessTokenExpire')
UPDATE [WebApi.Auth].Settings.Options SET Value = '1.0:00:00.0'
    WHERE Name = 'Auth.AccessTokenExpire'
-- ELSE
--     INSERT INTO [WebApi.Auth].Settings.Options (GroupId, Name, Value, IsInherited)
--     VALUES (1, 'Auth.AccessTokenExpire', '1.0:00:00.0', 0);  
--------------------------------------------------------------------------------          
                                                                                         
IF EXISTS (SELECT * FROM [WebApi.Auth].Settings.Options
    WHERE Name = 'Auth.AuthorizePath')
UPDATE [WebApi.Auth].Settings.Options SET Value = '/oauth/authorization'
    WHERE Name = 'Auth.AuthorizePath'
-- ELSE
--     INSERT INTO [WebApi.Auth].Settings.Options (GroupId, Name, Value, IsInherited)
--     VALUES (1, 'Auth.AuthorizePath', '/oauth/authorization', 0);  
--------------------------------------------------------------------------------          
                                                                                         
IF EXISTS (SELECT * FROM [WebApi.Auth].Settings.Options
    WHERE Name = 'Auth.RefreshTokenExpire')
UPDATE [WebApi.Auth].Settings.Options SET Value = '4.0:00:00.0'
    WHERE Name = 'Auth.RefreshTokenExpire'
-- ELSE
--     INSERT INTO [WebApi.Auth].Settings.Options (GroupId, Name, Value, IsInherited)
--     VALUES (1, 'Auth.RefreshTokenExpire', '4.0:00:00.0', 0);  
--------------------------------------------------------------------------------          
                                                                                         
IF EXISTS (SELECT * FROM [WebApi.Auth].Settings.Options
    WHERE Name = 'Auth.TokenPath')
UPDATE [WebApi.Auth].Settings.Options SET Value = '/oauth/token'
    WHERE Name = 'Auth.TokenPath'
-- ELSE
--     INSERT INTO [WebApi.Auth].Settings.Options (GroupId, Name, Value, IsInherited)
--     VALUES (1, 'Auth.TokenPath', '/oauth/token', 0);  
--------------------------------------------------------------------------------          
                                                                                         
IF EXISTS (SELECT * FROM [WebApi.Auth].Settings.Options
    WHERE Name = 'Bus.ConnectionString')
UPDATE [WebApi.Auth].Settings.Options SET Value = 'host=localhost:5672'
    WHERE Name = 'Bus.ConnectionString'
-- ELSE
--     INSERT INTO [WebApi.Auth].Settings.Options (GroupId, Name, Value, IsInherited)
--     VALUES (1, 'Bus.ConnectionString', 'host=localhost:5672', 0);  
--------------------------------------------------------------------------------          
                                                                                         
IF EXISTS (SELECT * FROM [WebApi.Auth].Settings.Options
    WHERE Name = 'Bus.IsEnabled')
UPDATE [WebApi.Auth].Settings.Options SET Value = 'true'
    WHERE Name = 'Bus.IsEnabled'
-- ELSE
--     INSERT INTO [WebApi.Auth].Settings.Options (GroupId, Name, Value, IsInherited)
--     VALUES (1, 'Bus.IsEnabled', 'true', 0);  
--------------------------------------------------------------------------------          
                                                                                         
IF EXISTS (SELECT * FROM [WebApi.Auth].Settings.Options
    WHERE Name = 'Global.IsCaptchaEnabled')
UPDATE [WebApi.Auth].Settings.Options SET Value = 'false'
    WHERE Name = 'Global.IsCaptchaEnabled'
-- ELSE
--     INSERT INTO [WebApi.Auth].Settings.Options (GroupId, Name, Value, IsInherited)
--     VALUES (1, 'Global.IsCaptchaEnabled', 'false', 0);  
--------------------------------------------------------------------------------          
                                                                                         
IF EXISTS (SELECT * FROM [WebApi.Auth].Settings.Options
    WHERE Name = 'Global.WcfClient.PpsClientId')
UPDATE [WebApi.Auth].Settings.Options SET Value = 7773
    WHERE Name = 'Global.WcfClient.PpsClientId'
-- ELSE
--     INSERT INTO [WebApi.Auth].Settings.Options (GroupId, Name, Value, IsInherited)
--     VALUES (1, 'Global.WcfClient.PpsClientId', 7773, 0);  
--------------------------------------------------------------------------------          
                                                                                         
IF EXISTS (SELECT * FROM [WebApi.Auth].Settings.Options
    WHERE Name = 'Global.WcfClient.WcfServicesHostAddress')
UPDATE [WebApi.Auth].Settings.Options SET Value = '172.16.1.217'
    WHERE Name = 'Global.WcfClient.WcfServicesHostAddress'
-- ELSE
--     INSERT INTO [WebApi.Auth].Settings.Options (GroupId, Name, Value, IsInherited)
--     VALUES (1, 'Global.WcfClient.WcfServicesHostAddress', '172.16.1.217', 0);  
--------------------------------------------------------------------------------          
                                                                                         
IF EXISTS (SELECT * FROM [WebApi.Auth].Settings.Options
    WHERE Name = 'Global.WcfClient.WcfServicesHostIdentityDns')
UPDATE [WebApi.Auth].Settings.Options SET Value = 'test.wcf.host'
    WHERE Name = 'Global.WcfClient.WcfServicesHostIdentityDns'
-- ELSE
--     INSERT INTO [WebApi.Auth].Settings.Options (GroupId, Name, Value, IsInherited)
--     VALUES (1, 'Global.WcfClient.WcfServicesHostIdentityDns', 'test.wcf.host', 0);  
--------------------------------------------------------------------------------          
                                                                                         
IF EXISTS (SELECT * FROM [WebApi.Auth].Settings.Options
    WHERE Name = 'Global.WcfClient.WorkerId')
UPDATE [WebApi.Auth].Settings.Options SET Value = 57
    WHERE Name = 'Global.WcfClient.WorkerId'
-- ELSE
--     INSERT INTO [WebApi.Auth].Settings.Options (GroupId, Name, Value, IsInherited)
--     VALUES (1, 'Global.WcfClient.WorkerId', 57, 0);  
--------------------------------------------------------------------------------          
                                                                                         
IF EXISTS (SELECT * FROM [WebApi.Auth].Settings.Options
    WHERE Name = 'ReCaptcha.PrivateKey')
UPDATE [WebApi.Auth].Settings.Options SET Value = '6LdDGRYUAAAAAPy8qadCmdaiHEgrpwgBlmka7SnE'
    WHERE Name = 'ReCaptcha.PrivateKey'
-- ELSE
--     INSERT INTO [WebApi.Auth].Settings.Options (GroupId, Name, Value, IsInherited)
--     VALUES (1, 'ReCaptcha.PrivateKey', '6LdDGRYUAAAAAPy8qadCmdaiHEgrpwgBlmka7SnE', 0);  
--------------------------------------------------------------------------------          
                                                                                         
IF EXISTS (SELECT * FROM [WebApi.Auth].Settings.Options
    WHERE Name = 'ReCaptcha.PublicKey')
UPDATE [WebApi.Auth].Settings.Options SET Value = 'NUL6LdDGRYUAAAAAM43b7Z-v56zVhagJ5oDzYV02GkEL'
    WHERE Name = 'ReCaptcha.PublicKey'
-- ELSE
--     INSERT INTO [WebApi.Auth].Settings.Options (GroupId, Name, Value, IsInherited)
--     VALUES (1, 'ReCaptcha.PublicKey', 'NUL6LdDGRYUAAAAAM43b7Z-v56zVhagJ5oDzYV02GkEL', 0);  
--------------------------------------------------------------------------------          
                                                                                         
IF EXISTS (SELECT * FROM [WebApi.Auth].Settings.Options
    WHERE Name = 'ReCaptcha.VerifyUrl')
UPDATE [WebApi.Auth].Settings.Options SET Value = 'https://www.google.com/recaptcha/api/siteverify'
    WHERE Name = 'ReCaptcha.VerifyUrl'
-- ELSE
--     INSERT INTO [WebApi.Auth].Settings.Options (GroupId, Name, Value, IsInherited)
--     VALUES (1, 'ReCaptcha.VerifyUrl', 'https://www.google.com/recaptcha/api/siteverify', 0);  
--------------------------------------------------------------------------------          
        
