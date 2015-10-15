//
//  SetPassWordViewContoller.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/22.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "SetPassWordViewContoller.h"
#import "NSString+IsValidate.h"

@implementation SetPassWordViewContoller

- (void)viewDidLoad
{
    [super viewDidLoad];
    _nameTextField.placeholder = @"请设置登录密码";
    _nameTextField.secureTextEntry = YES;
    _numberTextField.placeholder = @"请再次输入登录密码";
    _numberTextField.secureTextEntry = YES;
    _numberTextField.keyboardType = UIKeyboardTypeASCIICapable;
    [_NextBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_NextBtn addTarget:self action:@selector(bindButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self addKeyboardNotifaction];
}

- (void)bindButtonClicked
{
    if (![_nameTextField.text isValidatePass]) {
        [self showHudErrorView:@"密码需要在6~16位之间"];
        [_nameTextField becomeFirstResponder];
    }else if (![_numberTextField.text isValidatePass]){
        [self showHudErrorView:@"密码需要在6~16位之间"];
        [_numberTextField becomeFirstResponder];
    }else if(![_nameTextField.text isEqualToString:_numberTextField.text]){
        [self showHudErrorView:@"两次输入的密码不一致"];
        [_nameTextField becomeFirstResponder];
    }else{
        
        [self showHudWaitingView:PromptTypeWating];
        
        HTBaseRequest *revertPass = [[HTBaseRequest alloc] initWithURL:[NSString findBackPass]];
        
        [revertPass addPostValue:_nameTextField.text forKey:@"password"];
        [revertPass addPostValue:[NSString wideIpAddress] forKey:@"ip"];
        [revertPass addPostValue:self.authCode forKey:@"captcha"];
        [revertPass addPostValue:self.phoneNmber forKey:@"phone"];
        
        [revertPass startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            NSDictionary *error = [request.responseJSONObject valueForKey:@"error"];
            
            if (error) {
                NSString *msg = [error valueForKey:@"message"];
                [self showHudErrorView:msg];
            }else {
                [self showHudSuccessView:@"修改成功"];
                [self performSelector:@selector(popToRootViewController) withObject:nil afterDelay:1.0f];
            }
            
        } failure:^(YTKBaseRequest *request) {
            [self showHudErrorView:PromptTypeError];
            
        }];
    }
}

- (void)popToRootViewController
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ((![string isEqualToString:@""]) && textField.text.length < 16) {
            return YES;
        }
    
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    return NO;

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_numberTextField.editing == YES) {
        [self bindButtonClicked];
    }else if (_nameTextField.editing == YES)
    {
        [_numberTextField becomeFirstResponder];
    }
    return YES;
}
@end
