//
//  AuthCodeViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/22.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "AuthCodeViewController.h"
#import "InviterViewController.h"
#import "NSString+IsValidate.h"

@interface AuthCodeViewController () 
{
    UIView *back;
    UILabel *_detailTextLabel;
    int _second;
    NSTimer *_timeLock;
}

@end


@implementation AuthCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title =  @"验证码验证";
    
    [self addNotice];
    [self addTextField];
    [self addNextBtn];
    
    [self addKeyboardNotifaction];
    [self startOn];
}

- (void)addNotice
{
    _notice = [[AttributedLabel alloc]initWithFrame:CGRectMake(10,TransparentTopHeight + 10, APPScreenWidth, 18)];

    NSString *prompt = [_userPhoneNum substringToIndex:3];
    prompt = [prompt stringByAppendingFormat:@"****%@收到的验证码", [_userPhoneNum substringFromIndex:7]];
    prompt = [@"请输入" stringByAppendingString:prompt];
    _notice.text = prompt;
    //设置lable文字的属性
    [_notice setFont:[UIFont systemFontOfSize:14.0] fromIndex:0 length:prompt.length];
    [_notice setColor:[UIColor jd_globleTextColor] fromIndex:0 length:prompt.length];
    [_notice setColor:[UIColor orangeColor] fromIndex:3 length:11];
    [self.view addSubview:_notice];
}

- (void)addTextField
{
    back = [Sundry viewAddBackImgeAndlineNumber:1 withView:self.view];
    back.frame = CGRectMake(back.origin.x, _notice.bottom + 10, back.width, back.height);
    _authCode = [Sundry onBackimgeTextWith:CGRectMake(8, 0, back.width-8, 44) withPlaceholder:@"请输入验证码"];
    _authCode.delegate = self;
    _authCode.keyboardType = UIKeyboardTypeNumberPad;
    _getVerifyNumberBtn = [Sundry getVerifyNumberBtnWithFrame:CGRectMake(back.width*.65, 0, back.width*.35, 44)];
    [_getVerifyNumberBtn addTarget:self action:@selector(NgainCode) forControlEvents:UIControlEventTouchUpInside];
    [back addSubview:_authCode];
    [back addSubview:_getVerifyNumberBtn];
    [self.view addSubview:back];
}

- (void)addNextBtn
{
    _nextBtn = [Sundry BigBtnWithHihtY:back.bottom +10 withTitle:@"下一步"];
    [_nextBtn addTarget:self action:@selector(clickNextBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextBtn];
}

//  MARK:下一步，填写邀请人
- (void)clickNextBtn
{

    if (_authCode.text.length == 0) {
        [self showHudAuto:@"验证码不能为空"];
        [_authCode becomeFirstResponder];
    }else{
        
        HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString verificationMessageNumber]];
        [request addPostValue:self.userPhoneNum forKey:@"phone"];
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
    InviterViewController *findVC = [[InviterViewController alloc]init];
    findVC.userPhoneNum = self.userPhoneNum;
    findVC.userPass = self.userPass;
    findVC.captcha = _authCode.text;
    [self.navigationController pushViewController:findVC animated:YES];
}

//  MARK:点击获取验证码按钮
- (void)NgainCode
{
    //  发送验证码
    
    [self showHudWaitingView:PromptTypeWating];
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString getMessageAtRigist]];
    [request addPostValue:_userPhoneNum forKey:@"phone"];
    [request addPostValue:@(__SMS_CHANNEL) forKey:@"type"];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
        }else {
            [self showHudSuccessView:@"发送成功"];
            [self startOn];
        }
    } failure:^(YTKBaseRequest *request) {
        [self showHudErrorView:PromptTypeError];
        
    }];
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
    
    [_getVerifyNumberBtn setTitle:text forState:UIControlStateDisabled];
    
    if (_second <= 0) {
        [_timeLock invalidate];
        _timeLock = nil;
        
        _getVerifyNumberBtn.enabled = YES;
        [_getVerifyNumberBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //验证码只允许输入6位及6位以内的数字
    
    if ([string isNumber] ) {
        
        if (![string isEqualToString:@""] && _authCode.text.length < 6 ) {
            return YES;
        }
    }
    
    if([string isEqualToString:@""]){
        return YES;
    }
    
    return NO;
}

@end
