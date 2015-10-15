//
//  ModalViewController.m
//  ZFModalTransitionDemo
//
//  Created by Amornchai Kanokpullwad on 6/4/14.
//  Copyright (c) 2014 zoonref. All rights reserved.
//

#import "LogOrRegViewController.h"
#import "AttributedLabel.h"
#import "FindPassWordController.h"
#import "AuthCodeViewController.h"
#import "HTWebViewController.h"
#import "NSString+IsValidate.h"
#import "LoginRequest.h"
#import "AppDelegate.h"
#import "UIBarButtonExtern.h"



@interface LogOrRegViewController ()<UITextFieldDelegate>
{
    UIBarButtonItem *_rightButton;
    UITextField *_phoneNumber, *_password;
    UIView *back;
}

@property (nonatomic) UIButton *logInBtn;

@property (nonatomic) UIButton *registerBtn;

@property (nonatomic) UIButton *forgetBtn;

@property (nonatomic) AttributedLabel *JDprotocol;

@property (nonatomic) UITapGestureRecognizer *tap;

@property (nonatomic, copy) NSString *lastInputUser;

@property (nonatomic) LoginOrRegister rightBtnType;
@end

#define __LASTUSER_INPUT    @"__lastInputUser"

@implementation LogOrRegViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _lastInputUser = [HTUserDefaults valueForKey:__LASTUSER_INPUT];
    
    [self addKeyboardNotifaction];
    
}

- (void)addHeadBtnType:(LoginOrRegister)btnType;
{
    [self addTextFieldByBtnType:btnType];
}

- (void)addTextFieldByBtnType:(LoginOrRegister)btnType
{
    back = [Sundry viewAddBackImgeAndlineNumber:2.0 withView:self.view];
    [self.view addSubview:back];
    
    _phoneNumber = [Sundry onBackimgeTextWith:CGRectMake(8, 0, back.width-16, 44) withPlaceholder:@"请输入您的手机号"];
    _phoneNumber.delegate = self;
    _phoneNumber.text = _lastInputUser;
    
    _password = [Sundry onBackimgeTextWith:CGRectMake(8, 44, back.width-16, 44) withPlaceholder:@"请输入您的密码"];
    _password.keyboardType = UIKeyboardTypeASCIICapable;
    _password.secureTextEntry = YES;
    _password.delegate = self;
    _password.returnKeyType = UIReturnKeyDone;
    [back addSubview:_password];
    [back addSubview:_phoneNumber];
    
    _rightButton = [UIBarButtonExtern buttonWithTitle:@"注册" target:self andSelector:@selector(clickRightBtn)];
    
    if (btnType == Login) {
        [self setRightBtnLogin];
        
    }else {
        [self setRightBtnRegister];
    }
    
    [self.navigationItem setRightBarButtonItem:_rightButton animated:YES];
}

- (void)setRightBtnLogin
{
    [self setTitle:@"登录"];
    UIButton *button = (UIButton *)[_rightButton customView];
    if (button) {
        [button setTitle:@"注册" forState:UIControlStateNormal];
    }
    
    [self.registerBtn removeFromSuperview];
    [self.JDprotocol removeFromSuperview];
    [self.view addSubview:self.logInBtn];
    [self.view addSubview:self.forgetBtn];
    _phoneNumber.placeholder = @"请输入您的手机号/邮箱";
    _phoneNumber.keyboardType = UIKeyboardTypeASCIICapable;
    self.rightBtnType = Register;
}

- (void)setRightBtnRegister
{
    [self setTitle:@"注册"];
    UIButton *button = (UIButton *)[_rightButton customView];
    if (button) {
        [button setTitle:@"登录" forState:UIControlStateNormal];
    }
    [self.logInBtn removeFromSuperview];
    [self.forgetBtn removeFromSuperview];
    [self.view addSubview:self.registerBtn];
    [self.view addSubview:self.JDprotocol];
    _phoneNumber.placeholder = @"请输入您的手机号";
    _phoneNumber.keyboardType = UIKeyboardTypeNumberPad;
    self.rightBtnType = Login;
    
}

- (UIButton *)btnWithFrame:(CGRect)frame btnWithAction:(SEL)action
{
    UIButton *btn = [[UIButton alloc]initWithFrame:frame];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    return btn;
}

- (void)clickRightBtn
{
    CATransition *anim = [[CATransition alloc]init];
    anim.type = @"oglFlip";
    anim.duration = 0.8;
    if (self.rightBtnType == Login) {
        anim.subtype = kCATransitionFromLeft;
        [self setRightBtnLogin];
    }else
    {
        anim.subtype = kCATransitionFromRight;
        [self setRightBtnRegister];
    }
    _phoneNumber.text = @"";
    _password.text = @"";
    [self.view.layer addAnimation:anim forKey:nil];
    [self.view endEditing:YES];
}

- (void)clickLoginBtn
{
    if (_phoneNumber.text.length == 0) {
        [self showHudErrorView:@"用户名不能为空"];
        [_phoneNumber becomeFirstResponder];
    }else if (![_password.text isValidatePass]){
        [self showHudErrorView:@"密码需要在6~16位之间"];
        [_password becomeFirstResponder];
        
    }else{
        
        [HTUserDefaults setObject:_phoneNumber.text forKey:__LASTUSER_INPUT];
        
        [self.view endEditing:YES];
        [self doLoginRequest];
    }
}

//  MARK:发送登陆请求
- (void)doLoginRequest
{
    [self showHudWaitingView:PromptTypeWating];
    LoginRequest *request = [[LoginRequest alloc] initWithUserName:_phoneNumber.text andUserPass:_password.text];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *dic = request.responseJSONObject;
        
        NSDictionary *error = [dic dictionaryForKey:@"error"];
        if (error) {
            NSString *message = [error objectForKey:@"message"];
            [self showHudErrorView:message];
            
        }else {
            NSDictionary *result = [dic dictionaryForKey:@"result"];
            [[User sharedUser] configWithDic:result];
            //  success
            [self showHudSuccessView:@"登录成功"];
            [self performSelector:@selector(userLoginSuccess) withObject:nil afterDelay:1.0f];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self showHudErrorView:PromptTypeError];
    }];
}

- (void)userLoginSuccess
{
    [self changeTabbarIndex];
    [self dismissViewControllerAnimated:NO complainBlock:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:__USER_LOGIN_SUCCESS object:nil];
}

//  MARK:注册按钮事件
- (void)clickRegisterBtn
{
    if (![_phoneNumber.text isValidatePhone]) {
        [self showHudErrorView:@"手机号码输入有误"];
        [_phoneNumber becomeFirstResponder];
        
    }else if (![_password.text isValidatePass]){
        [self showHudAuto:@"密码需要在6~16位之间"];
        [_password becomeFirstResponder];
        
    }else{
        //  发送验证码
        [self requestValidateMessage];
    }
}

- (void)requestValidateMessage
{
    [self showHudWaitingView:PromptTypeWating];
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString getMessageAtRigist]];
    [request addPostValue:_phoneNumber.text forKey:@"phone"];
    [request addPostValue:@(__SMS_CHANNEL) forKey:@"type"];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
        }else {
            [self showHudSuccessView:@"发送成功"];
            [self performSelector:@selector(showAuthCodeViewController) withObject:nil afterDelay:1.0f];
        }
    } failure:^(YTKBaseRequest *request) {
        [self showHudErrorView:PromptTypeError];
        
    }];
}

- (void)showAuthCodeViewController
{
    AuthCodeViewController *findVC = [[AuthCodeViewController alloc]init];
    [self.navigationController pushViewController:findVC animated:YES];
    findVC.userPhoneNum = _phoneNumber.text;
    findVC.userPass = _password.text;
}

//  MARK:忘记密码
- (void)clickForgetBtn
{
    FindPassWordController *findVC = [[FindPassWordController alloc]init];
    [self.navigationController pushViewController:findVC animated:YES];
}

// 登录成功或者注册成功执行代理方法
- (void)dismissViewCtrAndRefresh
{
    if ([self.modalDelegate respondsToSelector:@selector(logInOrRegisterSuccess)]) {
        [self.modalDelegate logInOrRegisterSuccess];
    }
}

- (UIButton *)logInBtn
{
    if (!_logInBtn) {
        _logInBtn = [Sundry BigBtnWithHihtY:back.bottom +10 withTitle:@"登录"];
        [_logInBtn addTarget:self action:@selector(clickLoginBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _logInBtn;
}

- (UIButton *)registerBtn
{
    if (!_registerBtn) {
        _registerBtn = [Sundry BigBtnWithHihtY:self.JDprotocol.bottom + 10 withTitle:@"下一步"];
        [_registerBtn addTarget:self action:@selector(clickRegisterBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerBtn;
}

- (UIButton *)forgetBtn
{
    if (!_forgetBtn) {
        _forgetBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.width-120, self.logInBtn.bottom + 10, 120, 14)];
        [_forgetBtn setTitle:@"忘记密码?" forState:UIControlStateNormal];
        _forgetBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_forgetBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_forgetBtn setTitleColor:[UIColor jd_settingDetailColor] forState:UIControlStateHighlighted];
        [_forgetBtn addTarget:self action:@selector(clickForgetBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forgetBtn;
}

- (UILabel *)JDprotocol
{
    if (!_JDprotocol) {
        _JDprotocol = [[AttributedLabel alloc]initWithFrame:CGRectMake(10,back.bottom+10, back.width, 18)];
        _JDprotocol.text = @"点击“注册”代表您同意简单理财网服务协议";
        //设置lable文字的属性
        [_JDprotocol setFont:[UIFont systemFontOfSize:13.0] fromIndex:0 length:20];
        [_JDprotocol setTextColor:[UIColor jd_globleTextColor]];
        [_JDprotocol setColor:[UIColor jd_settingDetailColor] fromIndex:11 length:9];
        [_JDprotocol setColor:[UIColor jd_globleTextColor] fromIndex:0 length:11];
        [_JDprotocol setStyle:kCTUnderlineStyleSingle fromIndex:11 length:9];
        _JDprotocol.backgroundColor = [UIColor clearColor];
        _JDprotocol.userInteractionEnabled = YES;
        [self.JDprotocol addGestureRecognizer:self.tap];
        
    }
    return _JDprotocol;
}

- (UITapGestureRecognizer *)tap
{
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushJDprotocolCtr)];
    }
    return _tap;
}

- (void)pushJDprotocolCtr
{
    HTWebViewController *vc = [[HTWebViewController alloc] init];
    vc.titleStr = @"简单理财网服务协议";
    vc.url = HTURL(kRegeitProtocal1);
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (self.rightBtnType == Login && _phoneNumber.isFirstResponder) {
        
        if (![string isNumber]&&![string isEqualToString:@""]) {
            return NO;
        }
        
        if ((![string isEqualToString:@""]) && textField.text.length <= 10) {
            return YES;
        }else if([string isEqualToString:@""]){
            return YES;
        }
        
        return NO;
        
    }else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_phoneNumber.isFirstResponder) {
        [_password becomeFirstResponder];
        
        return YES;
        
    }else if (_password.isFirstResponder) {
        _password.returnKeyType = UIReturnKeyGo;
        if (self.rightBtnType == Login) {
            
            [self clickRegisterBtn];
            
        }else{
            
            [self clickLoginBtn];
        }
        return YES;
    }
    
    return NO;
}

@end
