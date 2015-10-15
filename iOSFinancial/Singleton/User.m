//
//  User.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/3/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "User.h"
#import "HTGestureViewController.h"

static NSString * const kUserNameKey = @"kUserNameValue";
static NSString * const kUserNickKey = @"kUserNickValue";
static NSString * const kUserNameStatus = @"real_name_status";
static NSString * const kUserMobilePhoneKey = @"kUserMobilePhone";
static NSString * const kUserToken = @"kUserToken";
static NSString * const kLastUserLoginTime = @"kLastUserLoginTime";
static NSString * const kIsBalanceIncomeOpen = @"kIsBalanceIncomeOpen";


@implementation User

+ (User *)sharedUser
{
    static User *__sharedUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedUser = [[self alloc] init];
    });

    return __sharedUser;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self readUserData];
        
        //  用户解锁手势，或者用户输入手势成功后， 都需要重新设置登陆时间
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserLoginTime) name:__USER_SET_GESTURE_SUCCESS object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserLoginTime) name:__USER_INPUT_GESURE_SUCCESS object:nil];
    }

    return self;
}

- (void)setIsBalanceIncomeOpen:(BOOL)isBalanceIncomeOpen
{
    if (_isBalanceIncomeOpen != isBalanceIncomeOpen) {
        _isBalanceIncomeOpen = isBalanceIncomeOpen;
        [HTUserDefaults setValue:@(_isBalanceIncomeOpen) forKey:kIsBalanceIncomeOpen];
    }
}

- (void)refreshUserLoginTime
{
    _lastLoginTime = HTSTR(@"%f", [[NSDate date] timeIntervalSince1970]);
    [self saveUserData];
}

- (void)setUserTelPhone:(NSString *)userTelPhone
{
    if (![_userTelPhone isEqualToString:userTelPhone]) {
        _userTelPhone = userTelPhone;
        [self saveUserData];
    }
}

- (void)setUserRealName:(NSString *)userRealName
{
    if (![_userRealName isEqualToString:userRealName]) {
        _userRealName = userRealName;
        [self saveUserData];
    }
}

- (NSString *)real_name_status_description
{
    switch (_real_name_status) {
        case UserNameAuthStateOutTime:  return @"认证次数超限";
        case  UserNameAuthStateUnAuth:  return @"未认证";
        case  UserNameAuthStateAuthing: return @"认证中";
        case  UserNameAuthStateAuthed:  return [self userVirsulName];
        case  UserNameAuthStateFailed:  return @"认证失败";
    }

    return @"wrong state";
}

- (NSString *)userVirsulPhone
{
    //  手机号不为空 且手机号的长度是11
    if (!isEmpty(_userTelPhone) && _userTelPhone.length == 11 ) {
        _userVirsulPhone = HTSTR(@"%@****%@", [_userTelPhone substringToIndex:3], [_userTelPhone substringFromIndex:8]);
    }
    
    return _userVirsulPhone;
}

- (NSString *)userVirsulName
{
    if (!isEmpty(_userRealName) && _userRealName.length > 1) {
        _userVirsulName = HTSTR(@"*%@", [_userRealName substringFromIndex:1]);
    }
    
    return _userVirsulName;
}

- (BOOL)isLogin
{
    _isLogin = !isEmpty(_userNickName);
    
    return _isLogin;
}

// 登录写入数据
- (void)configWithDic:(NSDictionary *)dic
{
    _userNickName = [dic stringForKey:@"username"];
    
    _userID = [dic stringIntForKey:@"uid"];
    
    _userToken = [dic stringIntForKey:@"AK"];
    
    [self unionVerifyDic:dic];
    
    [self refreshUserLoginTime];
    
    [self saveUserData];
}

- (void)unionVerifyDic:(NSDictionary *)dic
{
    _userRealName = [dic stringForKey:@"real_name"];
    _real_name_status = [[dic stringForKey:@"real_name_status"] integerValue];
    _userTelPhone = [dic stringIntForKey:@"telephone"];
}

// 更多接口写入数据
- (void)moreConfigWithCertificatedDic:(NSDictionary *)dic
{
    [self unionVerifyDic:dic];
    
    [self saveUserData];
}

- (void)clearUserData
{
    _userNickName = nil;
    _userID = nil;
    _userTelPhone = nil;
    _userToken = nil;
    _userVirsulPhone = nil;
    _userRealName = nil;
    
    _isBalanceIncomeOpen = NO;
    
    [HTGestureViewController clearGesturePass];
    
    [self saveUserData];
}

- (BOOL)saveUserData
{
    NSUserDefaults *stantDefault = [NSUserDefaults standardUserDefaults];
    [stantDefault setValue:_userRealName forKey:kUserNameKey];
    [stantDefault setValue:_userNickName forKey:kUserNickKey];
    [stantDefault setValue:_userTelPhone forKey:kUserMobilePhoneKey];
    [stantDefault setValue:_userToken forKey:kUserToken];
    [stantDefault setValue:_lastLoginTime forKey:kLastUserLoginTime];
    [stantDefault setValue:@(_isBalanceIncomeOpen) forKey:kIsBalanceIncomeOpen];
    
    [stantDefault setObject:[NSString stringWithFormat:@"%ld",(long)_real_name_status] forKey:kUserNameStatus];
    return [stantDefault synchronize];
}

- (void)readUserData
{
    NSUserDefaults *stant = [NSUserDefaults standardUserDefaults];
    _userRealName = [stant valueForKey:kUserNameKey];
    _userNickName = [stant valueForKey:kUserNickKey];
    _userTelPhone = [stant valueForKey:kUserMobilePhoneKey];
    _userToken = [stant valueForKey:kUserToken];
    _isBalanceIncomeOpen = [[stant valueForKey:kIsBalanceIncomeOpen] boolValue];
    _lastLoginTime = [stant valueForKey:kLastUserLoginTime];
    
    _real_name_status = [[stant valueForKey:kUserNameStatus] intValue];
}

#pragma mark - Login Out

- (void)doLoginOut
{
    //  服务器端，清空用户登录状态
    [self sendLoginOutRequest];
    
    [self clearUserData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:__USER_LOGINOUT_SUCCESS object:nil];
}

- (void)sendLoginOutRequest
{
    HTBaseRequest *request = [HTBaseRequest requestWithURL:[NSString loginOut]];
    request.shouldShowErrorMsg = NO;
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        
    }];
}

- (BOOL)isUserLoginOutTime
{
    NSTimeInterval lastTime = [self.lastLoginTime doubleValue];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    
    if ((nowTime - lastTime) / 60 > __UserLoginOutTimeInterval) {
        //  session out
        return YES;
    }
    
    return NO;
}

@end
