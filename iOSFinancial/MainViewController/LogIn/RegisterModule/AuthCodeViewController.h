//
//  AuthCodeViewController.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/22.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseViewController.h"
#import "AttributedLabel.h"


/*!
 @header        AuthCodeViewController
 @abstract      手机号、验证码
 @discussion    更多-- 注册--验证码验证
 */

@interface AuthCodeViewController : HTBaseViewController<UITextFieldDelegate>
{
    UIButton *_getVerifyNumberBtn;
    AttributedLabel *_notice;
    UITextField *_authCode;
}

@property (nonatomic, strong, readonly) UIButton *nextBtn;

@property (nonatomic, copy) NSString *userPhoneNum;
@property (nonatomic, copy) NSString *userPass;
@property (nonatomic, copy) NSString *captcha;

- (void)clickNextBtn;

@end
