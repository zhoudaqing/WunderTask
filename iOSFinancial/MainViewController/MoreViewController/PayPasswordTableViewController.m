//
//  PayPasswordTableViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/17.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "PayPasswordTableViewController.h"
#import "NSString+IsValidate.h"
#import "AttributedLabel.h"

@interface PayPasswordTableViewController ()<UITextFieldDelegate>
{
    UITextField *_payPassword, *_verifyNumber;
    UIButton *_getVerifyNumberBtn;
    UILabel *_timeLable, *_detailTextLabel;
    int _second;
    NSTimer *_timeLock;
    NSString *_validateCode;
}

@property (nonatomic) NSArray *cellTitle;

@end

@implementation PayPasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AttributedLabel *noticeLable = [[AttributedLabel alloc]initWithFrame:CGRectMake(11, TransparentTopHeight + 10, APPScreenWidth - 11, 16)];
    User *user = [User sharedUser];
    noticeLable.text = [NSString stringWithFormat:@"请输入手机号%@收到的短信验证码",user.userVirsulPhone];
    noticeLable.textColor = [UIColor jd_globleTextColor];
    
    [noticeLable setFont:[UIFont systemFontOfSize:14.0f] fromIndex:0 length:noticeLable.text.length];
    [noticeLable setTextColor:[UIColor jd_globleTextColor]];
    [noticeLable setColor:[UIColor jd_settingDetailColor] fromIndex:6 length:10];
    noticeLable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:noticeLable];
    
    UIView *back = [Sundry viewAddBackImgeAndlineNumber:2.0 withView:self.view];
    back.frame = CGRectMake(back.origin.x, noticeLable.bottom + 10, back.width, back.height);
    
    _payPassword = [Sundry onBackimgeTextWith:CGRectMake(8, 44, back.width-8, 44) withPlaceholder:@"支付密码"];
    _payPassword.secureTextEntry = YES;
    _payPassword.clearsOnBeginEditing = YES;
    _payPassword.delegate = self;
    _verifyNumber = [Sundry onBackimgeTextWith:CGRectMake(8, 0, back.width-8 * .65, 44) withPlaceholder:@"验证码"];
    _verifyNumber.delegate = self;
    _verifyNumber.keyboardType = UIKeyboardTypeNumberPad;
    
    _getVerifyNumberBtn = [Sundry getVerifyNumberBtnWithFrame:CGRectMake(back.width*.65, 0, back.width*.35, 44)];
    [_getVerifyNumberBtn addTarget:self action:@selector(requesteValidateCode) forControlEvents:UIControlEventTouchUpInside];
    
    [back addSubview:_verifyNumber];
    [back addSubview:_payPassword];
    [back addSubview:_getVerifyNumberBtn];
    [self.view addSubview:back];
    
    UIButton *btn = [Sundry BigBtnWithHihtY:back.bottom + 10 withTitle:@"确定"];
    [btn addTarget:self action:@selector(bindButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self addKeyboardNotifaction];
}

- (void)bindButtonClicked:(UIButton *)button
{
    if (isEmpty(_payPassword.text)) {
        [self showHudErrorView:@"支付密码不能为空"];
        [_payPassword becomeFirstResponder];
        
    }else if (![_payPassword.text isValidatePass32]) {
        [self showHudErrorView:@"密码在6~32位之间"];
        [_payPassword becomeFirstResponder];
        
    }else if (isEmpty(_verifyNumber.text)) {
        [self showHudErrorView:@"验证码不能为空"];
        [_verifyNumber becomeFirstResponder];
    }else {
        
        [self doResetPassRequest];
    }
}

- (void)doResetPassRequest
{
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString resetPayPass]];
    [request addPostValue:[User sharedUser].userID forKey:@"uid"];
    [request addPostValue:_payPassword.text forKey:@"password"];
    [request addPostValue:[NSString wideIpAddress] forKey:@"ip"];
    [request addPostValue:_verifyNumber.text forKey:@"captcha"];
    [self showHudWaitingView:PromptTypeWating];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
            
        }else {
            [self showHudSuccessView:@"修改支付密码成功"];
            [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:.8f];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self showHudErrorView:PromptTypeError];
    }];

}

//  点击获取验证码按钮
- (void)requesteValidateCode
{
    
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString getMessageAtModifyPayPass]];
    
    [request addPostValue:@(__SMS_CHANNEL) forKey:@"type"];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *error = [request.responseJSONObject objectForKey:@"error"];
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
        }else {
            [self showHudSuccessView:@"短信发送成功"];
            [self startOn];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self showHudErrorView:PromptTypeError];
    }];
}

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
    
    [_getVerifyNumberBtn setTitle:text forState:UIControlStateDisabled];
    
    if (_second <= 0) {
        [_timeLock invalidate];
        _timeLock = nil;
        
        _getVerifyNumberBtn.enabled = YES;
        [_getVerifyNumberBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_payPassword.isEditing) {
        [self bindButtonClicked:nil];
        return YES;
    }
    return NO;
}

@end