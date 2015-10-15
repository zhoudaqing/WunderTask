//
//  SetPassWordViewContoller.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/22.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "NameCertificationController.h"

/*!
 @header        SetPassWordViewContoller
 @abstract      新密码、旧密码
 @discussion    更多-- 登录-- 忘记密码--设置密码
 */


@interface SetPassWordViewContoller : NameCertificationController

@property (nonatomic , copy) NSString *authCode;

@property (nonatomic , copy) NSString *phoneNmber;

@end
