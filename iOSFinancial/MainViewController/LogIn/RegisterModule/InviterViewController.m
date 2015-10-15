//
//  InviterViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/22.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InviterViewController.h"
#import "NSString+IsValidate.h"
#import "HTGestureViewController.h"

@implementation InviterViewController 


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"填写邀请人";
    [_getVerifyNumberBtn removeFromSuperview];
    
    _notice.text = @"请填写邀请人手机号,没有可以直接点击跳过";
    
    [_notice setColor:[UIColor jd_globleTextColor] fromIndex:0 length:20];
    [_notice setFont:[UIFont systemFontOfSize:14.0] fromIndex:0 length:20];
    _authCode.placeholder = @"请输入邀请人的手机号码";
    
    [self.nextBtn setTitle:@"完成" forState:UIControlStateNormal];
    
    [self addJumpBtn];
}


- (void)addJumpBtn
{
    UIBarButtonItem *jumpBtn = [[UIBarButtonItem alloc]initWithTitle:@"跳过" style:UIBarButtonItemStyleDone target:self action:@selector(sendRegeditRequest)];
    jumpBtn.tintColor = HTWhiteColor;
    [self.navigationItem setRightBarButtonItem:jumpBtn];
}

- (void)clickNextBtn
{
    if (_authCode.text.length < 11) {
        
        [self showHudAuto:@"请您输入正确的手机号"];
        return;
    }
    [self sendRegeditRequest];
}

- (void)sendRegeditRequest
{
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString user_regedit]];
    [request addPostValue:self.userPhoneNum forKey:@"username"];
    [request addPostValue:self.userPass forKey:@"password"];
    [request addPostValue:self.captcha forKey:@"captcha"];

    if (!isEmpty(_authCode.text)) {
        [request addPostValue:_authCode.text forKey:@"invitor_phone"];
        
        //  邀请码
        [request addPostValue:@"" forKey:@"invitor_code"];
        //  验证码
    }
    [request addPostValue:[NSString wideIpAddress] forKey:@"ip"];
    
    [self showHudWaitingView:PromptTypeWating];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
            
        }else {
            [self showHudSuccessView:@"注册成功"];
            [[User sharedUser] configWithDic:[request.responseJSONObject dictionaryForKey:@"result"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:__USER_LOGIN_SUCCESS object:nil];
            [self performSelector:@selector(showGestureViewController) withObject:nil afterDelay:1.0f];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self showHudErrorView:PromptTypeError];
    }];
}

- (void)showGestureViewController
{
    HTGestureViewController *gesture = [[HTGestureViewController alloc] init];
    [self.navigationController pushViewController:gesture animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (![string isNumber]&&![string isEqualToString:@""]) {
        return NO;
    }
    
    if ((![string isEqualToString:@""]) && textField.text.length <= 10) {
        return YES;
    }else if([string isEqualToString:@""]){
        return YES;
    }
    
    return NO;

}
@end
