//
//  NameCertificationTableViewController.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/17.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTBaseViewController.h"

/*!
 @header        NameCertificationTableViewController
 @abstract      用户真实姓名、用户身份证号
 @discussion    更多--实名认证
 */

@interface NameCertificationController : HTBaseViewController <UITextFieldDelegate>
{
    UITextField *_nameTextField , *_numberTextField;
    UIButton *_NextBtn;
}

@end
