//
//  NameCertificationTableViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/17.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "NameCertificationController.h"
#import "NSString+IsValidate.h"

@interface NameCertificationController ()<UITextFieldDelegate>

@end

@implementation NameCertificationController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIView *backView = [Sundry viewAddBackImgeAndlineNumber:2.0 withView:self.view];
    
    _nameTextField = [Sundry onBackimgeTextWith:CGRectMake(8, 0, backView.width-8, 44) withPlaceholder:@"真实姓名"];
    _numberTextField = [Sundry onBackimgeTextWith:CGRectMake(8, 44, backView.width-8, 44) withPlaceholder:@"身份证号码"];
    _numberTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _nameTextField.delegate = self;
    _numberTextField.delegate = self;
    [self.view addSubview:backView];
    
    [backView addSubview:_nameTextField];
    [backView addSubview:_numberTextField];

    _NextBtn= [Sundry BigBtnWithHihtY:backView.bottom + 10 withTitle:@"立即认证"];
    [_NextBtn addTarget:self action:@selector(bindButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_NextBtn];
    
    [self addKeyboardNotifaction];
}

- (void)bindButtonClicked
{
    if (isEmpty(_nameTextField.text)) {
        [self showHudErrorView:@"真实姓名不能为空"];
        [_nameTextField becomeFirstResponder];
        
    }else if (![_numberTextField.text isValidateCardId]) {
        [self showHudErrorView:@"身份证不合法"];
        [_numberTextField becomeFirstResponder];
    }else {
        [self doBindUserRealNameRequest];
    }
}

- (void)doBindUserRealNameRequest
{
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString bindUserRealName]];
    
    [request addPostValue:_numberTextField.text forKey:@"card_id"];
    [request addPostValue:_nameTextField.text forKey:@"real_name"];
    [request addPostValue:@"1" forKey:@"real_time"];
    
    [self showHudWaitingView:PromptTypeWating];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self removeHudInManaual];
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        if (error) {
          
            if ([[error stringForKey:@"code"] intValue] == 1015) {
                // 认证次数超限
                [self idcard_countMore];
            }else if ([[error stringForKey:@"code"] intValue] == 1009)
            {
                [User sharedUser].real_name_status = UserNameAuthStateAuthed;
                [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:.8f];
            }else
            {
                NSString *message = [error stringForKey:@"message"];
                [self showHudErrorView:message];
            }
            
        }else {
            NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
            [User sharedUser].real_name_status = [result[@"idcard_verify_status"] intValue];
            [User sharedUser].userRealName = _nameTextField.text;
            switch ([result[@"idcard_verify_status"] intValue]) {
                case  UserNameAuthStateAuthing:
                {
                    [self showHudSuccessView:@"认证信息已经提交"];
                    [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:.8f];

                }break;
                case  UserNameAuthStateAuthed:
                {
                    [self showHudSuccessView:@"实名认证成功"];
                    [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:.8f];
                }
                    break;
                case  UserNameAuthStateFailed:  {
                    if ([result[@"idcard_count"] intValue] == 2) {
                        [self idcard_countMore];
                    }else
                    {
                        [self showHudErrorView:@"实名认证失败，请核对信息后认证"];
                    }

                }break;
                default:
                {
                    if ([result[@"idcard_count"] intValue] == 2) {
                        [self idcard_countMore];
                    }else
                    {
                        [self showHudErrorView:@"实名认证失败，请核对信息后认证"];
                    }

                }
                    break;
            }

        }
        
    } failure:^(YTKBaseRequest *request) {
        [self showHudErrorView:PromptTypeError];
    }];
}

- (void)idcard_countMore
{
    NSString *prompt = HTSTR(@"认证次数超限，如有疑问请拨打客服电话:%@", kServicePhone_f);
    [self alertViewWithButtonsBlock:^NSArray *{
        return @[@"拨打"];
    } andHandleBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            // 拨打电话
            NSString *telphone = HTSTR(@"tel://%@",kServicePhone);
            [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:.8f];
            [[UIApplication sharedApplication] openURL:HTURL(telphone)];
        }
        else{
            [self dismissViewController];
            [User sharedUser].real_name_status = UserNameAuthStateOutTime;
        }
        
    } andMessage:prompt];

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_nameTextField.isEditing == YES) {
        [_numberTextField becomeFirstResponder];
    }else
    {
        [self bindButtonClicked];
    }
    return YES;
}


@end
