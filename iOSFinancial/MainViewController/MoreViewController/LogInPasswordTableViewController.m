//
//  LogInPasswordTableViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/17.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "LogInPasswordTableViewController.h"
#import "NSString+IsValidate.h"


@interface LogInPasswordTableViewController ()<UITextFieldDelegate>
{
    UITextField *_originalPassword, *_newPassword, *_confirmPassword;
}

@end

@implementation LogInPasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *back = [Sundry viewAddBackImgeAndlineNumber:3.0 withView:self.view];
    
    _originalPassword = [Sundry onBackimgeTextWith:CGRectMake(8, 0, back.width-8,44) withPlaceholder:@"原始密码"];
    _originalPassword.secureTextEntry = YES;
    _originalPassword.delegate = self;
    
    _newPassword = [Sundry onBackimgeTextWith:CGRectMake(8, 44, back.width-8, 44) withPlaceholder:@"新密码"];
    _newPassword.secureTextEntry = YES;
    _newPassword.delegate = self;
    
    _confirmPassword = [Sundry onBackimgeTextWith:CGRectMake(8, 88, back.width-8, 44) withPlaceholder:@"确认密码"];
    _confirmPassword.delegate = self;
    _confirmPassword.secureTextEntry = YES;
    _confirmPassword.returnKeyType = UIReturnKeyDone;
    
    [back addSubview:_originalPassword];
    [back addSubview:_newPassword];
    [back addSubview:_confirmPassword];
    
    [self.view addSubview:back];
    
    UIButton *btn = [Sundry BigBtnWithHihtY:back.bottom + 10 withTitle:@"确定"];
    [btn addTarget:self action:@selector(submitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self addKeyboardNotifaction];
}

- (void)submitButtonClicked:(UIButton *)button
{
    if (![_originalPassword.text isValidatePass]) {
        [self showHudErrorView:@"密码需要在6~16位之间"];
        [_originalPassword becomeFirstResponder];
        
    }else if (![_newPassword.text isValidatePass]) {
        [self showHudErrorView:@"密码需要在6~16位之间"];
        [_newPassword becomeFirstResponder];
        
    }else if (![_confirmPassword.text isValidatePass]) {
        [self showHudErrorView:@"密码需要在6~16位之间"];
        [_confirmPassword becomeFirstResponder];
        
    }else if ([_newPassword.text isEqualToString:_confirmPassword.text]) {
        //  提交
        [self doResetPassRequest];
        
    }else {
        [self showHudErrorView:@"两次输入的密码不相同"];
        [_newPassword becomeFirstResponder];
    }
}

- (void)doResetPassRequest
{
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString resetLoginPass]];
    
    [request addPostValue:[User sharedUser].userID forKey:@"uid"];
    [request addPostValue:_newPassword.text forKey:@"new"];
    [request addPostValue:_originalPassword.text forKey:@"old"];
    [request addPostValue:[NSString wideIpAddress] forKey:@"ip"];
    
    [self showHudWaitingView:PromptTypeWating];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
            
        }else {
            [self showHudSuccessView:@"修改密码成功"];
            [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:.8f];
            
        }
        
    } failure:^(YTKBaseRequest *request) {
        
        [self showHudErrorView:PromptTypeError];
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_originalPassword.isEditing == YES) {
        [_newPassword becomeFirstResponder];
        return YES;
    }
    if (_newPassword.isEditing == YES) {
        [_confirmPassword becomeFirstResponder];
        return YES;
    }
    if (_confirmPassword.isEditing == YES) {
        [self submitButtonClicked:nil];
        return YES;
    }
    return NO;
}



@end
