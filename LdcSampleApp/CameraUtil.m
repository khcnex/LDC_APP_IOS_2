#import "CameraUtil.h"

@implementation CameraUtil

-(void)callCamera:(UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate> *)target
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(authStatus == AVAuthorizationStatusAuthorized)
    {
        [self openCamera:target];
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
         {
             if(granted)
             {
                 [self openCamera:target];
             }
         }];
    }
    else if (authStatus == AVAuthorizationStatusRestricted)
    {
        [self moveGeneralScreen];
    }
    else if (authStatus == AVAuthorizationStatusDenied)
    {
        [self movePermissionScreen];
    }
    else
    {
        
    }
}

-(void)callPhotoAlbum:(UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate> *)target
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = target;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [target presentViewController:picker animated:YES completion:NULL];
}

-(void)movePermissionScreen
{
    UIAlertController *alert = [UIAlertController
                                  alertControllerWithTitle:@"카메라 접근 요청"
                                  message:@"카메라 접근 권한이 허용되지 않았습니다.\n'확인' 버튼을 누르시면 접근권한 설정 화면으로 이동합니다."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        [[UIApplication sharedApplication]  openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                            options:@{}
                                  completionHandler:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    UIViewController *rootView = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    while (rootView.presentedViewController) {
        
        rootView = rootView.presentedViewController;
        
    }
    
    [rootView presentViewController:alert animated:YES completion:nil];
}

-(void)moveGeneralScreen
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"카메라 차단 해제 요청"
                                message:@"이 기기에서 카메라 사용이 제한되었습니다. [일반] -> [차단] 에서 카메라 사용제한을 해제해주세요."
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                               {
                                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{}                                                      completionHandler:nil];

                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    UIViewController *rootView = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    while (rootView.presentedViewController) {
        
        rootView = rootView.presentedViewController;
        
    }
    
    [rootView presentViewController:alert animated:YES completion:nil];
}

- (void)openCamera:(UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate> *)target
{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = target;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [target presentViewController:picker animated:YES completion:NULL];
}

//2018.09.06 hmwoo 카메라를 통하여 사진을 찍었을경우 아래 메소드를 호출한 Activity에 붙여넣어서 handle을 취득함 @START
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    //UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //self.imageView.image = chosenImage;

    //[picker dismissViewControllerAnimated:YES completion:NULL];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    //[picker dismissViewControllerAnimated:YES completion:NULL];

}
//2018.09.06 hmwoo 카메라를 통하여 사진을 찍었을경우 아래 메소드를 호출한 Activity에 붙여넣어서 handle을 취득함 @END

@end
