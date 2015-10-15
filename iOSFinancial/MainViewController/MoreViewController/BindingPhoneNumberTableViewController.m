//
//  BindingPhoneNumberTableViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/17.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "BindingPhoneNumberTableViewController.h"
#import "NSString+IsValidate.h"

@interface BindingPhoneNumberTableViewController ()<UITextFieldDelegate>
{
    UITextField *_phoneNumber , *_verifyNumber;
    UIButton *_getVerifyNumberBtn;
    UILabel *_timeLable;
    UIView *_backView;
    int _second;
    NSTimer *_timeLock;
}

@end

@implementation BindingPhoneNumberTableViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [_phoneNumber becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addBackImage];
    
    [self addKeyboardNotifaction];
}

- (void)addBackImage
{
    UIView *back = [Sundry viewAddBackImgeAndlineNumber:2.0 withView:self.view];
    _phoneNumber = [Sundry onBackimgeTextWith:CGRectMake(8, 0, back.width*.65, 44) withPlaceholder:@"手机号码"];
    _phoneNumber.keyboardType = UIKeyboardTypeNumberPad;
    _phoneNumber.delegate = self;
    _verifyNumber = [Sundry onBackimgeTextWith:CGRectMake(8, 44, back.width-8,44) withPlaceholder:@"手机验证码"];
    _verifyNumber.keyboardType = UIKeyboardTypeNumberPad;
    _verifyNumber.delegate = self;
    _backView = [Sundry viewAddBackImgeAndlineNumber:2.0 withView:self.view];
    [self.view addSubview:_backView];
    
    _getVerifyNumberBtn = [Sundry getVerifyNumberBtnWithFrame:CGRectMake(_backView.width*.65, 0, _backView.width*.35, 44)];
    [_getVerifyNumberBtn addTarget:self action:@selector(requesteValidateCode) forControlEvents:UIControlEventTouchUpInside];
    
    [_backView addSubview:_verifyNumber];
    [_backView addSubview:_phoneNumber];
    [_backView addSubview:_getVerifyNumberBtn];

    UIButton *btn = [Sundry BigBtnWithHihtY:_backView.bottom + 10 withTitle:@"立即绑定"];
    [btn addTarget:self action:@selector(bindButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)bindButtonClicked:(UIButton *)button
{
    if (![_phoneNumber.text isValidatePhone]) {
        [self showHudErrorView:@"您输入的手机号码不合法"];
        [_phoneNumber becomeFirstResponder];
        return;
    }else if (_verifyNumber.text.length == 0 ) {
        [self showHudErrorView:@"请输入验证码"];
        
    }else {
        [self doBindUserPhoneRequest];
    }
}

- (void)doBindUserPhoneRequest
{
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString bindPhone]];
    
    [request addPostValue:_phoneNumber.text forKey:@"phone"];
    [request addPostValue:[NSString wideIpAddress] forKey:@"ip"];
    [request addPostValue:_verifyNumber.text forKey:@"captcha"];
    [self showHudWaitingView:PromptTypeWating];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
            
        }else {
            [User sharedUser].userTelPhone = _phoneNumber.text;
            [self showHudSuccessView:@"绑定手机成功"];
            [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:.8f];
        }
        
    }];

}

//  点击获取验证码按钮
- (void)requesteValidateCode
{
    if (![_phoneNumber.text isValidatePhone]) {
        [self showHudErrorView:@"手机号码不合法"];
        [_phoneNumber becomeFirstResponder];
    }else{
    
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString getMessgeAtBindPhone]];
    [request addPostValue:_phoneNumber.text forKey:@"phone"];
    [request addPostValue:@(__SMS_CHANNEL) forKey:@"type"];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *error = [request.responseJSONObject objectForKey:@"error"];
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
        }else {
            [self showHudSuccessView:@"获取验证码成功"];
            [self startOn];
            [_verifyNumber becomeFirstResponder];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self showHudErrorView:PromptTypeError];
    }];
    }
}


//  点击获取验证码按钮
- (void)startOn
{
    //验证码请求成功执行以下代码
    _second = 60;
    _timeLock = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(secondSubtract) userInfo:nil repeats:YES];
    
    [_getVerifyNumberBtn setTitle:HTSTR(@"%d s", _second) forState:UIControlStateNormal];
    _getVerifyNumberBtn.enabled = NO;
}

//  倒计时每秒所调用方法
- (void)secondSubtract
{
    NSString *text = HTSTR(@"%d s", --_second);
    
    [_getVerifyNumberBtn setTitle:text forState:UIControlStateNormal];
    
    if (_second <= 0) {
        [_timeLock invalidate];
        _timeLock = nil;
        
        _getVerifyNumberBtn.enabled = YES;
        [_getVerifyNumberBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
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

- (NSString *)title
{
    return @"绑定手机号码";
}

@end
