#import <UIKit/UIKit.h>

@interface ConfigParamView : UIViewController <UITextFieldDelegate> {
    
    UILabel *Label_serviceCode;
    UITextField *TextField_serviceCode;
    
    UILabel *Label_serviceLgtType;
    UITextField *TextField_serviceLgtType;
    
    UILabel *Label_serviceLoginType;
    UITextField *TextField_serviceLoginType;
    
    UILabel *Label_vtidUserYN;
    UITextField *TextField_vtidUserYN;
    
    UILabel *Label_serviceCI;
    UITextField *TextField_serviceCI;
    
    UILabel *Label_serviceEnterNumber;
    UITextField *TextField_EnterNumber;
    
    UILabel *Label_serviceUserId;
    UITextField *TextField_serviceUserId;
    
    UILabel *Label_serviceKey;
    UITextField *TextField_serviceKey;
    
    UILabel *Label_serviceAuthType;
    UITextField *TextField_serviceAuthType;
    
    UILabel *Label_servicePassword;
    UITextField *TextField_servicePassword;
    
    UILabel *Label_iosPinSetting;
    UITextField *TextField_iosPinSetting;
    
    UIButton *defaultButton;
    
    NSMutableDictionary *intent;
}

@property (nonatomic, strong) UILabel *Label_serviceCode;
@property (nonatomic, strong) UITextField *TextField_serviceCode;

@property (nonatomic, strong) UILabel *Label_serviceLgtType;
@property (nonatomic, strong) UITextField *TextField_serviceLgtType;

@property (nonatomic, strong) UILabel *Label_serviceLoginType;
@property (nonatomic, strong) UITextField *TextField_serviceLoginType;

@property (nonatomic, strong) UILabel *Label_vtidUserYN;
@property (nonatomic, strong) UITextField *TextField_vtidUserYN;

@property (nonatomic, strong) UILabel *Label_serviceCI;
@property (nonatomic, strong) UITextField *TextField_serviceCI;

@property (nonatomic, strong) UILabel *Label_serviceEnterNumber;
@property (nonatomic, strong) UITextField *TextField_EnterNumber;

@property (nonatomic, strong) UILabel *Label_serviceUserId;
@property (nonatomic, strong) UITextField *TextField_serviceUserId;

@property (nonatomic, strong) UILabel *Label_serviceKey;
@property (nonatomic, strong) UITextField *TextField_serviceKey;

@property (nonatomic, strong) UILabel *Label_serviceAuthType;
@property (nonatomic, strong) UITextField *TextField_serviceAuthType;

@property (nonatomic, strong) UILabel *Label_servicePassword;
@property (nonatomic, strong) UITextField *TextField_servicePassword;

@property (nonatomic, strong) UILabel *Label_iosPinSetting;
@property (nonatomic, strong) UITextField *TextField_iosPinSetting;

@property (nonatomic, strong) UIButton *defaultButton;

@property (nonatomic, strong) NSMutableDictionary *intent;

@end
