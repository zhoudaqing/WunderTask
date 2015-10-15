//
//  HTBaseRequest.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/5/4.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseRequest.h"
#import "HTVersionManager.h"
#import "AppDelegate.h"
#import "HTBaseViewController.h"

@interface HTBaseRequest () <YTKRequestDelegate>

@end

@implementation HTBaseRequest

+ (instancetype)requestWithURL:(NSString *)detailURL
{
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:detailURL];
    
    return request;
}

- (instancetype)initWithURL:(NSString *)detailURL
{
    self = [super init];
    
    if (self) {
        
        _shouldShowErrorMsg = YES;
        
        self.delegate = self;
        _detailUrl = [detailURL copy];
    }
    
    return self;
}

//  15s超时
- (NSTimeInterval)requestTimeoutInterval {
    return 15;
}

#pragma mark - RequestDelegate

- (void)requestFinished:(YTKBaseRequest *)request
{
    NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
    
    if (error) {
        
        NSLog(@"requestError:%@%@", request.baseUrl, request.requestUrl);
        
        NSInteger code = [[error stringIntForKey:@"code"] integerValue];
        HTBaseViewController *viewController = [self viewControllerOnScreen];
        NSString *message = [error stringForKey:@"message"];
        
        if (viewController) {
            
            /*
             -5 是别人顶了这个号
             -2 是用户token过期
             */
            if (__UserAccoutIsLoginByOther == code ||
                __UserAccessTokenOutDate == code) {
                
                //  用户已经退出登录的时候就不要再发通知和注销用户了
                if ([User sharedUser].isLogin) {
                    //  用户AccessToken过期通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:__USER_ACCESSTOKEN_OUTDATE object:error];
                    //  退出登录
                    [[User sharedUser] doLoginOut];
                }
                
            }else {
                
                if (_shouldShowErrorMsg) {
                    [viewController showHudErrorView:message];
                }
            }
        }
    }
}

- (void)requestFailed:(YTKBaseRequest *)request
{
    NSLog(@"requestFalied:%@%@", request.baseUrl, request.requestUrl);
    
    HTBaseViewController *viewController = [self viewControllerOnScreen];
    
    if (viewController && _shouldShowErrorMsg) {
        [viewController showHudErrorView:PromptTypeError];
    }
}

- (HTBaseViewController *)viewControllerOnScreen
{
    AppDelegate *sharedApplication = [UIApplication sharedApplication].delegate;
    UIViewController *rootViewController = sharedApplication.showedViewController.visibleViewController;
    
    if ([rootViewController isKindOfClass:[HTNavigationController class]]) {
        rootViewController = ((HTNavigationController *)rootViewController).visibleViewController;
    }
    
    if ([rootViewController isKindOfClass:[HTBaseViewController class]]) {
        return (HTBaseViewController *)rootViewController;
    }
    
    return nil;
}

#pragma mark - RequestEnd

- (YTKRequestMethod)requestMethod
{
    if (!_requestMethod) {
        _requestMethod = YTKRequestMethodGet;
    }
    
    return _requestMethod;
}

/// 请求的BaseURL
- (NSString *)baseUrl
{
    return jianDanInvestServer;
}

/// 在HTTP报头添加的自定义参数
- (NSDictionary *)requestHeaderFieldValueDictionary
{
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    
    [mutDic setValue:@"paltid" forKey:@"iOS"];
    HTVersionManager *manager = [HTVersionManager sharedManager];
    [mutDic setValue:@"appver" forKey:manager.localVersion];
    UIDevice *device = [UIDevice currentDevice];
    
    //  硬件版本
    [mutDic setValue:@"model" forKey:device.model];
    
    [mutDic setValue:@"localizedModel" forKey:device.localizedModel];
    //  系统名称
    [mutDic setValue:@"systemName" forKey:device.systemName];
    //  系统版本号
    [mutDic setValue:@"systemVersion" forKey:device.systemVersion];
    
    if ([User sharedUser].isLogin) {
        NSString *userToken = [User sharedUser].userToken;
        [mutDic setValue:userToken forKey:@"AK"];
        NSLog(@"userToken:%@", userToken);
    }
    
    return mutDic;
}

//  返回具体的url
- (NSString *)requestUrl
{
    return _detailUrl;
}

- (id)requestArgument
{
    return _requestParam;
}

- (NSMutableDictionary *)requestParam
{
    if (!_requestParam) {
        _requestParam = [NSMutableDictionary dictionary];
    }
    
    return _requestParam;
}

#pragma mark - addRequestMethod

- (void)addGetValue:(id)value forKey:(NSString *)key
{
    [self addRequestValue:value forKey:key byMethod:YTKRequestMethodGet];
}

- (void)addPostValue:(id)value forKey:(NSString *)key
{
    [self addRequestValue:value forKey:key byMethod:YTKRequestMethodPost];
}

- (void)addPutValue:(id)value forKey:(NSString *)key
{
    [self addRequestValue:value forKey:key byMethod:YTKRequestMethodPut];
}

- (void)addRequestValue:(id)value forKey:(NSString *)key byMethod:(YTKRequestMethod)method
{
    if (value && key) {
        _requestMethod = method;
        [self.requestParam setValue:value forKey:key];
    }
}

#pragma mark - SetDictionary

- (void)setGetRequestParam:(NSDictionary *)paramDic
{
   [self setRequestMethod:YTKRequestMethodGet ParamDic:paramDic];
}

- (void)setPostRequestParam:(NSDictionary *)paramDic
{
    [self setRequestMethod:YTKRequestMethodPost ParamDic:paramDic];
}

- (void)setPutRequestParam:(NSDictionary *)paramDic
{
    [self setRequestMethod:YTKRequestMethodPut ParamDic:paramDic];
}

- (void)setRequestMethod:(YTKRequestMethod)requestMethod ParamDic:(NSDictionary *)paramDic
{
    if (paramDic && [paramDic isKindOfClass:[NSDictionary class]]) {
        _requestMethod = requestMethod;
        _requestParam = [paramDic mutableCopy];
    }
}

- (void)startWithCompletionBlockWithSuccess:(void (^)(YTKBaseRequest *request))success
{
    [self setCompletionBlockWithSuccess:success failure:nil];
    [self start];
}


@end
