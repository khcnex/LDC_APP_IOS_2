#import "AccountUtil.h"





@implementation AccountUtil

+(NSString *) AUTO_ACCOUNT{return @"AUTO_ACCOUNT";}
+(NSString *) SNS_AUTO_ACCOUNT{return @"SNS_AUTO_ACCOUNT";}
+(NSString *) EASY_ACCOUNT{return @"EASY_ACCOUNT";}
+(NSString *) NORMAL_ACCOUNT{return @"NORMAL_ACCOUNT";}
+(NSString *) DAS_LIBRARY{return @"DAS_LIBRARY";}
+(NSString *) SERVICE_CD{return @"A69";}

+(Boolean) setAutoAccount:(NSString *) USER_ID SSO_KEY:(NSString *)SSO_KEY
{
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];

    @try
    {
    
        [dictionary setObject:[TelUtil AES256Encode:USER_ID key:@"secretKey1234567"] forKey:@"USER_ID"];
        [dictionary setObject:[TelUtil AES256Encode:SSO_KEY key:@"secretKey1234567"] forKey:@"SSO_KEY"];
        [defaults setObject:dictionary forKey:AccountUtil.AUTO_ACCOUNT];
    
        if ( ![defaults synchronize] ) {
            return false;
        }
    
    }
    @catch (NSException *exception)
    {
        NSLog(@"Caught %@%@", exception.name, exception.reason);
        return false;
    }

    return true;
}

+(NSDictionary *) getAutoAccount
{
    NSMutableDictionary* map = [NSMutableDictionary dictionary];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    @try
    {
    
        NSDictionary* dictionary = [defaults dictionaryForKey:AccountUtil.AUTO_ACCOUNT];
        
        NSString *user_id = dictionary[@"USER_ID"];
        NSString *sso_key = dictionary[@"SSO_KEY"];
        
        NSLog(@"%@", user_id);
        NSLog(@"%@", sso_key);
        
        [map setObject:(dictionary == nil || dictionary[@"USER_ID"] == nil)?[NSNull null]:[TelUtil AES256Decode:dictionary[@"USER_ID"] key:@"secretKey1234567"] forKey:@"USER_ID"];
        [map setObject:(dictionary == nil || dictionary[@"SSO_KEY"] == nil)?[NSNull null]:[TelUtil AES256Decode:dictionary[@"SSO_KEY"] key:@"secretKey1234567"] forKey:@"SSO_KEY"];
    
    }
    @catch (NSException *exception)
    {
        NSLog(@"Caught %@%@", exception.name, exception.reason);
    }
    
    return map;
}

+(Boolean) setSNSAutoAccount:(NSString *) SNSID_KEY SNS_CD:(NSString *)SNS_CD SNS_USER_ID:(NSString *)SNS_USER_ID
{
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    
    @try
    {
    
        [dictionary setObject:[TelUtil AES256Encode:SNSID_KEY key:@"secretKey1234567"] forKey:@"SNSID_KEY"];
        [dictionary setObject:[TelUtil AES256Encode:SNS_CD key:@"secretKey1234567"] forKey:@"SNS_CD"];
        [dictionary setObject:[TelUtil AES256Encode:SNS_USER_ID key:@"secretKey1234567"] forKey:@"SNS_USER_ID"];
        [defaults setObject:dictionary forKey:AccountUtil.SNS_AUTO_ACCOUNT];
    
        if ( ![defaults synchronize] ) {
            return false;
        }
    
    }
    @catch (NSException *exception)
    {
        NSLog(@"Caught %@%@", exception.name, exception.reason);
        return false;
    }
    
    return true;
}

+(NSDictionary *) getSNSAutoAccount
{
    NSMutableDictionary* map = [NSMutableDictionary dictionary];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    @try
    {
    
        NSDictionary* dictionary = [defaults dictionaryForKey:AccountUtil.SNS_AUTO_ACCOUNT];
        
        [map setObject:(dictionary == nil || dictionary[@"SNSID_KEY"] == nil)?[NSNull null]:[TelUtil AES256Decode:dictionary[@"SNSID_KEY"] key:@"secretKey1234567"] forKey:@"SNSID_KEY"];
        [map setObject:(dictionary == nil || dictionary[@"SNS_CD"] == nil)?[NSNull null]:[TelUtil AES256Decode:dictionary[@"SNS_CD"] key:@"secretKey1234567"] forKey:@"SNS_CD"];
        [map setObject:(dictionary == nil || dictionary[@"SNS_USER_ID"] == nil)?[NSNull null]:[TelUtil AES256Decode:dictionary[@"SNS_USER_ID"] key:@"secretKey1234567"] forKey:@"SNS_USER_ID"];
        
    }
    @catch (NSException *exception)
    {
        NSLog(@"Caught %@%@", exception.name, exception.reason);
    }
    
    return map;
}

+(Boolean) deleteAutoAccount
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    @try
    {
    
        [defaults removeObjectForKey:AccountUtil.AUTO_ACCOUNT];
    
        if ( ![defaults synchronize] ) {
            return false;
        }
    
    }
    @catch (NSException *exception)
    {
        NSLog(@"Caught %@%@", exception.name, exception.reason);
        return false;
    }
    
    return true;
}

+(Boolean) deleteSNSAutoAccount
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    @try
    {
    
        [defaults removeObjectForKey:AccountUtil.SNS_AUTO_ACCOUNT];
    
        if ( ![defaults synchronize] ) {
            return false;
        }
    
    }
    @catch (NSException *exception)
    {
        NSLog(@"Caught %@%@", exception.name, exception.reason);
        return false;
    }
    
    return true;
}

+(Boolean) setEasyAccount:(NSString *) USER_ID
{
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    
    @try
    {
    
        [dictionary setObject:[Util getBase64encode:[TelUtil AES256Encode:USER_ID key:@"secretKey1234567"]] forKey:@"USER_ID"];
        [defaults setObject:dictionary forKey:AccountUtil.EASY_ACCOUNT];
    
        if ( ![defaults synchronize] ) {
            return false;
        }
    
    }
    @catch (NSException *exception)
    {
        NSLog(@"Caught %@%@", exception.name, exception.reason);
        return false;
    }
    
    return true;
}

+(NSString *) getEasyAccount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *resultStr;
    
    @try
    {
    
        NSDictionary *dictionary = [defaults dictionaryForKey:AccountUtil.EASY_ACCOUNT];
        
        resultStr = (dictionary == nil || dictionary[@"USER_ID"] == nil)?nil:[TelUtil AES256Decode:dictionary[@"USER_ID"] key:@"secretKey1234567"];
    
    }
    @catch (NSException *exception)
    {
        NSLog(@"Caught %@%@", exception.name, exception.reason);
    }
    
    return resultStr;
}

+(Boolean) deleteEasyAccount
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    @try
    {
    
        [defaults removeObjectForKey:AccountUtil.EASY_ACCOUNT];
        
        if ( ![defaults synchronize] ) {
            return false;
        }
    
    }
    @catch (NSException *exception)
    {
        NSLog(@"Caught %@%@", exception.name, exception.reason);
        return false;
    }
    
    return true;
}

+(Boolean) setNormalAccount:(NSString *) USER_ID ONEID_KEY:(NSString *)ONEID_KEY
{
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    
    @try
    {
    
        [dictionary setObject:[TelUtil AES256Encode:USER_ID key:@"secretKey1234567"] forKey:@"USER_ID"];
        [dictionary setObject:[TelUtil AES256Encode:ONEID_KEY key:@"secretKey1234567"] forKey:@"ONEID_KEY"];
        
        
//        [dictionary setObject:[Util getBase64encode:[TelUtil AES256Encode:USER_ID key:@"secretKey1234567"]] forKey:@"USER_ID"];
//        [dictionary setObject:ONEID_KEY == nil?@"":[Util getBase64encode:[TelUtil AES256Encode:ONEID_KEY key:@"secretKey1234567"]] forKey:@"ONEID_KEY"];
        [defaults setObject:dictionary forKey:AccountUtil.NORMAL_ACCOUNT];
        
        if ( ![defaults synchronize] ) {
            return false;
        }
    
    }
    @catch (NSException *exception)
    {
        NSLog(@"Caught %@%@", exception.name, exception.reason);
        return false;
    }
    
    return true;
}


+(NSDictionary *) getNormalAccount
{
    NSMutableDictionary* map = [NSMutableDictionary dictionary];
    
    @try
    {
    
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSDictionary* dictionary = [defaults dictionaryForKey:AccountUtil.NORMAL_ACCOUNT];
        
        
        NSString *userId = [TelUtil AES256Decode:dictionary[@"USER_ID"] key:@"secretKey1234567"];
        NSString *oneidKey = [TelUtil AES256Decode:dictionary[@"ONEID_KEY"] key:@"secretKey1234567"];
        
        [map setObject:(dictionary == nil || dictionary[@"USER_ID"] == nil)?[NSNull null]:userId forKey:@"USER_ID"];
        [map setObject:(dictionary == nil || dictionary[@"USER_ID"] == nil)?[NSNull null]:oneidKey forKey:@"ONEID_KEY"];
        
//        [map setObject:(dictionary == nil || dictionary[@"USER_ID"] == nil)?[NSNull null]:[TelUtil AES256Decode:dictionary[@"USER_ID"] key:@"secretKey1234567"] forKey:@"USER_ID"];
//        [map setObject:(dictionary == nil || dictionary[@"ONEID_KEY"] == nil)?[NSNull null]:[TelUtil AES256Decode:dictionary[@"ONEID_KEY"] key:@"secretKey1234567"] forKey:@"ONEID_KEY"];
    
    }
    @catch (NSException *exception)
    {
        NSLog(@"Caught %@%@", exception.name, exception.reason);
    }
        
    return map;
}


+(Boolean) deleteNormalAccount
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    @try
    {
        
        [defaults removeObjectForKey:AccountUtil.NORMAL_ACCOUNT];
    
        if ( ![defaults synchronize] ) {
            return false;
        }
        
    }
    @catch (NSException *exception)
    {
        NSLog(@"Caught %@%@", exception.name, exception.reason);
        return false;
    }
    
    return true;
}

+(Boolean) setDasLibraryConfig:(NSString *) key value:(NSString *)value
{
    NSLog(@"%@ : %@", key, value);
    
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    
    @try
    {
    
        if([defaults dictionaryForKey:AccountUtil.DAS_LIBRARY] != nil) {
            dictionary = [[defaults dictionaryForKey:AccountUtil.DAS_LIBRARY] mutableCopy];
        }
        
        [dictionary setObject:value forKey:key];
        
        [defaults setObject:dictionary forKey:AccountUtil.DAS_LIBRARY];
        
        if ( ![defaults synchronize] ) {
            return false;
        }
    
    }
    @catch (NSException *exception)
    {
        NSLog(@"Caught %@%@", exception.name, exception.reason);
        return false;
    }
    
    return true;
}

@end
