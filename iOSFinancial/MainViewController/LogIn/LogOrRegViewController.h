//
//  LogOrRegViewController.h
//  ZFModalTransitionDemo
//
//  Created by Mr.Yan on 15/4/19.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTBaseViewController.h"

/*!
 @header        LogOrRegViewController
 @abstract      用户名、用户密码
 @discussion    更多-- 登录、注册
 */

typedef NS_ENUM(NSInteger, LoginOrRegister)
{
    Login,
    Register
};
@protocol ModalViewControllerDelegate <NSObject>

//登录成功之后执行的代理方法
- (void)logInOrRegisterSuccess;

@end

@interface LogOrRegViewController : HTBaseViewController

// 按钮设置
- (void)addHeadBtnType:(LoginOrRegister)btnType;

@property (nonatomic ,weak) id<ModalViewControllerDelegate>modalDelegate;


@end
