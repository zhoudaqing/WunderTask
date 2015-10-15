//
//  User.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/3/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UserNameAuthState) {
    UserNameAuthStateUnAuth  = 0,   //  未认证
    UserNameAuthStateAuthing = 1,   //  认证中
    UserNameAuthStateAuthed  = 2,   //  认证通过
    UserNameAuthStateFailed  = 3,   //  认证失败
    UserNameAuthStateOutTime = -1   //  超过次数
};


@interface User : NSObject
{
    @private
    BOOL _isLogin;
    NSString *_userVirsulPhone;
    NSString *_userVirsulName;
}

//  昵称
@property (nonatomic, readonly, copy) NSString *userNickName;

//  用户ID
@property (nonatomic, readonly, copy) NSString *userID;

//  用户Token
@property (nonatomic, readonly, copy) NSString *userToken;

//  真实姓名
@property (nonatomic, copy) NSString *userRealName;
//  带星号的姓名
@property (nonatomic, readonly) NSString *userVirsulName;

@property (nonatomic ,assign) UserNameAuthState real_name_status;

//  中文描述
@property (nonatomic, readonly) NSString *real_name_status_description;

//  用户手机号
@property (nonatomic, copy) NSString *userTelPhone;

//  带星号的手机号
@property (nonatomic, readonly) NSString *userVirsulPhone;

//  是否登录
@property (nonatomic, assign, readonly) BOOL isLogin;

/*---------------- 注册时使用的临时数据 ------------------*/

@property (nonatomic, copy) NSString *regeditUserName;
@property (nonatomic, copy) NSString *regeditUserPass;

/*----------------------------------------------------*/


//  更多

//  是否允许充值
@property (nonatomic, assign, readonly) NSInteger shouldRecharge;
//
@property (nonatomic, assign) BOOL isInVestRecharge;
//  是否允许投资
@property (nonatomic, assign, readonly) NSInteger shouldInvest;

//  是否允许提现
@property (nonatomic, assign, readonly) NSInteger shouldWithDraw;

//  账户所用信息----账户余额
@property (nonatomic, copy) NSString *accountBalance;

//  余额生息是否打开的开关
@property (nonatomic, assign) BOOL isBalanceIncomeOpen;

//  上次登陆时间 /手势密码使用/
@property (nonatomic, copy, readonly) NSString *lastLoginTime;



+ (User *)sharedUser;

//  用户登录有没有超时
- (BOOL)isUserLoginOutTime;

//  保存用户数据
- (BOOL)saveUserData;

//  清除用户数据
- (void)clearUserData;

//  刷新用户登陆时间
- (void)refreshUserLoginTime;

//  用户登录
- (void)configWithDic:(NSDictionary *)dic;

//  刷新更多得到数据 赋值
- (void)moreConfigWithCertificatedDic:(NSDictionary *)dic;

- (void)doLoginOut;

@end
