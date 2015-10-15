//
//  FindPassWordController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/22.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "FindPassWordController.h"
#import "SetPassWordViewContoller.h"
#import "NSString+IsValidate.h"


@interface FindPassWordController ()<UITextFieldDelegate>
{
    UITextField *_authCode, *_phoneNumber;
    UIButton *_getVerifyNumberBtn;
    UILabel *_timeLable, *_detailTextLabel;
    int _second;
    NSTimer *_timeLock;
    UIView *back;
    
    //  服务器返回的验证码
    NSString *_validateCode;
}
@end

@implementation FindPassWordController

- (void)dealloc
{
    [_timeLock invalidate];
    _timeLock = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"找回密码";
    
    [self addBackImage];
    [self addAffirmBtn];
    
    [self addKeyboardNotifaction];
}

- (void)addBackImage
{
    back = [Sundry viewAddBackImgeAndlineNumber:2.0 withView:self.view];
    _authCode = [Sundry onBackimgeTextWith:CGRectMake(8, 44, back.width-8, 44) withPlaceholder:@"请输入验证码"];
    _authCode.width *= .65;
    _phoneNumber = [Sundry onBackimgeTextWith:CGRectMake(8, 0, back.width-8, 44) withPlaceholder:@"请输入手机号"];
    _phoneNumber.keyboardType = UIKeyboardTypeNumberPad;
    _authCode.keyboardType = UIKeyboardTypeNumberPad;
    _phoneNumber.delegate = self;
    _authCode.delegate = self;
    _getVerifyNumberBtn = [Sundry getVerifyNumberBtnWithFrame:CGRectMake(back.width*.65, 44, back.width*.35, 44)];
    [_getVerifyNumberBtn addTarget:self action:@selector(NgainCode) forControlEvents:UIControlEventTouchUpInside];
    
    [back addSubview:_phoneNumber];
    [back addSubview:_authCode];
    [back addSubview:_getVerifyNumberBtn];
    [self.view addSubview:back];
    
}

- (void)addAffirmBtn
{
    UIButton *btn = [Sundry BigBtnWithHihtY:back.bottom + 10 withTitle:@"下一步"];
    [btn addTarget:self action:@selector(clickNextBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

//  点击获取验证码按钮
- (void)NgainCode
{
    if (![_phoneNumber.text isValidatePhone]) {
        
        [self showHudAuto:@"输入的手机号码有误"];
        [_phoneNumber becomeFirstResponder];
        
    }else{
        //  MARK:请求验证码
        HTBaseRequest *requestCode = [[HTBaseRequest alloc] init];
        requestCode.detailUrl = [NSString getMessageAtFindPass];
        [requestCode addPostValue:_phoneNumber.text forKey:@"phone"];
        [requestCode addPostValue:@(__SMS_CHANNEL) forKey:@"type"];
        
        [self showHudWaitingView:PromptTypeWating];
        [requestCode startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            NSDictionary *error = [request.responseJSONObject valueForKey:@"error"];
            if (error) {
                NSString *message = [error valueForKey:@"message"];
                [self showHudErrorView:message];
                
            }else {
                
                [self removeHudInManaual];
                [self showHudSuccessView:@"验证码发送成功"];
                [self startOn];
            }
            
        } failure:^(YTKBaseRequest *request) {
            [self showHudErrorView:PromptTypeError];
            
        }];
    }
}

//  MARK:开始计时
- (void)startOn
{
    //验证码请求成功执行以下代码
    _second = 60;
    _timeLock = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(secondSubtract) userInfo:nil repeats:YES];
    
    [_getVerifyNumberBtn setTitle:HTSTR(@"%d秒后重试", _second) forState:UIControlStateNormal];
    _getVerifyNumberBtn.enabled = NO;
}

//  倒计时每秒所调用方法
- (void)secondSubtract
{
    NSString *text = HTSTR(@"%d秒后重试", --_second);
    
    [_getVerifyNumberBtn setTitle:text forState:UIControlStateNormal];
    
    if (_second <= 0) {
        [_timeLock invalidate];
        _timeLock = nil;
        
        _getVerifyNumberBtn.enabled = YES;
        [_getVerifyNumberBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
}

//  MARK:下一步
- (void)clickNextBtn
{
    if (![_phoneNumber.text isValidatePhone]) {
        [self showHudErrorView:@"输入的手机号码有误"];
        [_phoneNumber becomeFirstResponder];
        return;
    }
    
    if (_authCode.text.length ==0)
    {
        [self showHudErrorView:@"验证码不能为空"];
        [_authCode becomeFirstResponder];
        return;
    }
    
    if (_authCode.text.length == 0) {
        [self showHudAuto:@"验证码不能为空"];
        [_authCode becomeFirstResponder];
    }else{
        
        HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString verificationMessageNumber]];
        [request addPostValue:_phoneNumber.text forKey:@"phone"];
        [request addPostValue:_authCode.text forKey:@"captcha"];
        
        [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
            if (error) {
                NSString *message = [error stringForKey:@"message"];
                [self showHudErrorView:message];
            }else {
                [self showHudSuccessView:@"验证码确认成功"];
                [self performSelector:@selector(showInviterViewController) withObject:nil afterDelay:0.8f];
                
            }
        } failure:^(YTKBaseRequest *request) {
            [self showHudErrorView:PromptTypeError];
            
        }];
        
    }
   
}


- (void)showInviterViewController
{
    //点击下一步 网络请求操作通过之后 执行的代码
    SetPassWordViewContoller *findVC = [[SetPassWordViewContoller alloc]init];
    findVC.title = @"找回登录密码";
    findVC.authCode = _authCode.text;
    findVC.phoneNmber = _phoneNumber.text;
    [findVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:findVC animated:YES];

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //  电话号码 只允许输入11位数字
    if (_phoneNumber.isFirstResponder) {
        
        if ((![string isEqualToString:@""]) && textField.text.length < 11 && [string isNumber]) {
            return YES;
        }
    }
    
    //验证码只允许输入6位及6位以内的数字
    
    if (_authCode.isFirstResponder) {
        
        if (![string isEqualToString:@""] && _authCode.text.length < 6 ) {
            return YES;
        }
    }
    
    if([string isEqualToString:@""]){
        return YES;
    }
    
    return NO;
}

//  你妹的你又成功的把搜狗给搞崩溃了。。。

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    if (_phoneNumber.isFirstResponder) {
//        
//        if (![textField.text isValidatePhone]) {
//            [self showHudAuto:@"输入的手机号码有误"];
//            return NO;
//        }
//        
//    }
//    return YES;
//}

@end
