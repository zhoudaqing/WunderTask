//
//  NSString+BaseURL.m
//  ShiPanOnline
//
//  Created by Mr.Yang on 14-2-25.
//  Copyright (c) 2014年 Mr.Yang. All rights reserved.
//

#import "NSString+BaseURL.h"
#import "NSString+URLEncoding.h"
#import "NSString+BFExtension.h"
#include <sys/sysctl.h>
#import <sys/utsname.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>
#import <SystemConfiguration/SystemConfiguration.h>

typedef enum {
    NETWORK_TYPE_NONE= 0,
    NETWORK_TYPE_WIFI= 1,
    NETWORK_TYPE_3G= 2,
    NETWORK_TYPE_2G= 3,
    
}NETWORK_TYPE;

@implementation NSString (BaseURL)

//  平台 ios硬件版本号
+ (NSString *)platform
{
    size_t size;
    sysctlbyname("hw.machine",NULL, &size, NULL,0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size,NULL, 0);
    NSString*platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return platform;
}

+ (NSString*)machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)wideIpAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

//  判断网络环境
+ (int)dataNetworkTypeFromStatusBar
{
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSNumber *dataNetworkItemView = nil;
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }

    int netType = NETWORK_TYPE_NONE;
    NSNumber * num = [dataNetworkItemView valueForKey:@"dataNetworkType"];
    if (num == nil) {
        netType = NETWORK_TYPE_NONE;
        
    }else{

        int n = [num intValue];
        if (n == 0) {
            netType = NETWORK_TYPE_NONE;
            
        }else if (n == 1){
            netType = NETWORK_TYPE_2G;
            
        }else if (n == 2){
            netType = NETWORK_TYPE_3G;
            
        }else{
            netType = NETWORK_TYPE_WIFI;
        }
    }

    return netType;
}

+ (NSString *)functionName:(NSString *)function paramDic:(NSDictionary *)dic
{
    NSArray *keys = [dic allKeys];
    
    NSString *param = @"";
    for (NSString *key in keys){
        
        NSString *value = HTSTR(@"%@", [dic objectForKey:key]);
        param = [param stringByAppendingString:HTSTR(@"%@=%@", key, value)];
        
        NSInteger index = [keys indexOfObject:key];
        if (index != (keys.count -1)) {
            param = [param stringByAppendingString:@"&"];
        }
    }
    
    return HTSTR(@"%@?%@", function, param);
}

//php 后缀参数拼接
+ (NSString *)functionName:(NSString *)function, ...
{
    va_list args;
    va_start(args, function);
    id tmp;
    id values;
    
    while (TRUE) {
        values = va_arg(args, id);
        if (!values) break;
        
        if ([values isKindOfClass:[NSDictionary class]]) {
            NSArray *keys = [values allKeys];
            for (NSString *key in keys) {
                id value = [values valueForKey:key];
                tmp = HTSTR(@"%@/%@/%@",tmp, key, value);
            }
        }else{
            tmp = HTSTR(@"%@/%@", tmp, values);
        }
    }
    
    va_end(args);
    return tmp;
}

//  拼参数的函数
+ (NSString *)appendFunctionName:(NSString *)function, ...
{
    va_list args;
    va_start(args, function);
    id tmp = function;
    id values;
    
    while (TRUE) {
        values = va_arg(args, id);
        if (!values) break;
        
        if ([values isKindOfClass:[NSDictionary class]]) {
            NSArray *keys = [values allKeys];
            for (NSString *key in keys) {
                id value = [values valueForKey:key];
                tmp = HTSTR(@"%@/%@/%@",tmp, key, value);
            }
        }else{
            tmp = HTSTR(@"%@/%@", tmp, values);
        }
    }
    
    va_end(args);
    return tmp;
}




#pragma mark - Host

#define  ___baseHTTPSHost   [self baseHTTPSHost]
+ (NSString *)baseHTTPSHost
{
    return HTSTR(@"https://%@", jianDanInvestServer);
}

#define ___baseHTTPHost     [self baseHTTPHost]
+ (NSString *)baseHTTPHost
{
    return HTSTR(@"http://%@", jianDanInvestServer);
}


#define ___getUserInfoHost   [self userInfoHost]
+ (NSString *)userInfoHost
{
    return HTSTR(@"%@/userinfo", ___baseHTTPHost);
}

#define ___getMessageHost [self getMessageHost]
+ (NSString *)getMessageHost
{
    return HTSTR(@"/user/sendCaptcha");
}

#define ___getUserHost [self getUserHost]
+ (NSString *)getUserHost
{
    return HTSTR(@"%@/user", ___baseHTTPSHost);
}

#define ___getSecurityHost  [self getSecurityHost]
+ (NSString *)getSecurityHost
{
    return HTSTR(@"%@/secure", ___baseHTTPSHost);
}

#pragma mark - 短信发送

+ (NSString *)app_version_check
{
    return @"/mobile/version/ios";
}

//  注册
+ (NSString *)user_regedit
{
    return @"/user/register";
}

//  登录
+ (NSString *)user_login
{
    return @"/user/login";
}

+ (NSString *)verificatifyUserPassword
{
    return @"/user/verification/paypwd";
}

//  发送短信验证码--注册
+ (NSString *)getMessageAtRigist
{
    return @"/sms-code/register";
}

//  发送短信验证码--找回登录密码
+ (NSString *)getMessageAtFindPass
{
    return @"/sms-code/login-back";
}

//  发送短信验证码--绑定手机号
+ (NSString *)getMessgeAtBindPhone
{
    return @"/sms-code/bind-phone";
}

//  发送短信验证码--修改支付密码
+ (NSString *)getMessageAtModifyPayPass
{
    return @"/sms-code/modify-pay-pwd";
}

// 通用短信验证码验证接口
+ (NSString *)verificationMessageNumber
{
    return @"/sms-validate";
}


/*-------------------------  项目列表  --------------------------*/
//  投资项目列表
+ (NSString *)investList
{
    return @"/loans";
}

+ (NSString *)investDetail:(NSString *)investID
{
    return HTSTR(@"/loans/%@", investID);
}

+ (NSString *)investAccount:(NSString *)investID
{
    return HTSTR(@"/loans/invest/base/p2c/%@", investID);
}

+ (NSString *)invsetAction:(NSString *)investID
{
    return HTSTR(@"/loans/vote/%@", investID);
}

+ (NSString *)investWillInvestList
{
    return @"/loans/anxin";
}
// 普通项目投资列表
+ (NSString *)investRecord
{
    return @"/loans/invest-record";
}

//------------------------ 债券

+ (NSString *)redeemList
{
    return @"/redeems";
}

+ (NSString *)redeemAccount:(NSString *)redeemID
{
    return HTSTR(@"/loans/invest/base/redeem/%@", redeemID);
}

+ (NSString *)redeemAction:(NSString *)redeemID
{
    return HTSTR(@"/redeems/vote/%@", redeemID);
}

+ (NSString *)redeemDetail:(NSString *)redeemID
{
    return HTSTR(@"/redeems/%@", redeemID);
}

// 赎回项目投资列表
+ (NSString *)redeemsInvestRecord
{
    return @"/redeems/invest-record";
}

// 投资成功后查询分享 ---
+ (NSString *)sharingValidation
{
    return @"/loans/sharing/validation?";
}

// 投资分享成功返现 ---
+ (NSString *)sharedAward
{
    return @"/loans/shared-award";
}



/*-----------------------  我的账户  ----------------------------*/

//  我的账户主页面
+ (NSString *)getMyAccount
{
    return @"/account";
}

//  投资中
+ (NSString *)getProjectsInvestRecord
{
    return @"/projects-relation/invest-record";
}

// 查看投资中合同
+ (NSString *)agreement
{
    return @"/agreement?type=";
}

// 点击投资中----提前赎回
+ (NSString *)projectsRelationReback
{
    return @"/projects-relation/reback/";
}

// 确认赎回------最新数据更新
+ (NSString *)loansRelationRedeemBase
{
    return @"/loans-relation/redeem/base?ipid=";
}

// 确认赎回----点击确认赎回按钮
+ (NSString *)loansRelationRedeem
{
    return  @"/loans-relation/redeem/";
}
// 提现中
+ (NSString *)withdrawing
{
    return @"/secure/withdrawing";
}

// 账户余额
+ (NSString *)investorBill
{
    return @"/investor-bill";
}

// 申请提现
+ (NSString *)secureWithdraw
{
    return @"/secure/withdraw";
}

// 累计收益
+ (NSString *)allIncome
{
    return @"/account/detail-funds";
}

//  红包头文件
+ (NSString *)getCashgiftInfo
{
    return @"/cashgift/info";
}

//   红包记录
+ (NSString *)getRecorder
{
    return @"/cashgift/recorder";
}

//  剩余回款
+ (NSString *)investorReback
{
    return @"/investor-reback";
}

// 赎回项目---正在赎回
+ (NSString *)redeemingRcord
{
    return @"/account/redeem-record?status=1";
}

// 赎回项目---已经赎回
+ (NSString *)redeemedRcord
{
    return @"/account/redeem-record?status=2";
}


//  提现银行卡
+ (NSString *)bankCard
{
    return @"/bankcards";
}
//  添加提现银行卡
+  (NSString *)addBankCard
{
    return @"/bankcards/add";
}
// 编辑银行卡
+ (NSString *)editBankCard
{
    return @"/bankcards/edit";
}

// 余额生息
+ (NSString *)balanceAccout
{
    return HTSTR(@"/%@", [@"balance-accounts" URLEncodedString]);
}

// 邀请好友
+ (NSString *)inviteInfo
{
    return @"/invite-info/summary";
}

// 充值拉卡信息
+ (NSString *)safeCard
{
    return @"/mobile/fetch-safe-card";
}
// 首次充值下单
+ (NSString *)firstRecharge
{
    return @"/mobile/create-order";
}
// 首次绑卡
+ (NSString *)lianlianAddCard
{
    return @"/mobile/create-orde";
}


#pragma mark - 密

//  修改登陆密码
+ (NSString *)resetLoginPass
{
    return @"/user/reset-password";
}

//  修改支付密码
+ (NSString *)resetPayPass
{
    return @"/user/reset-payment-password";
}

//  找回登录密码
+ (NSString *)findBackPass
{
    return HTSTR(@"/user/recover-password");
}

#pragma mark - 项目发布倒计时

+ (NSString *)projectReleaseDate
{
    return HTSTR(@"%@/projects/countdown", ___baseHTTPHost);
}

#pragma mark - 设置

//  关于我们
+ (NSString *)aboutUs
{
    return HTSTR(@"%@/aboutus?ak=", ___baseHTTPHost);
}

//  版本号
+ (NSString *)version
{
    return HTSTR(@"%@/version/ios", ___baseHTTPHost);
}

//  退出
+ (NSString *)loginOut
{
    return HTSTR(@"/user/logout");
}

//  用户反馈
+ (NSString *)userFeedBack
{
    return @"/mobile/feedback";
}

//  广告业列表
+ (NSString *)adveriseList
{
    return @"/discover";
}

#pragma mark - 个人中心

/*
-1 认证超限
0 未认证
1 审核中
2 已认证
3 认证失败
*/

+ (NSString *)more
{
    return @"/more";
}
 
//  绑定身份证号
+ (NSString *)bindIDCard
{
    return HTSTR(@"%@/bindIdCard?ak=", ___getUserInfoHost);
}

//  绑定手机号
+ (NSString *)bindPhone
{
    return @"/user/bind-phone";
}

+ (NSString *)bindUserRealName
{
    return @"/user/authenticate";
}

//  绑定银行卡
+ (NSString *)bindBankCard
{
    return HTSTR(@"%@bindBankCard?ak=", ___getUserInfoHost);
}

//  资产管理
+ (NSString *)assetManage
{
    return HTSTR(@"%@/assetsOverview?ak=", ___getUserInfoHost);
}

//  交易记录
+ (NSString *)tradeRecoderList
{     return HTSTR(@"%@/transactionRecord?page=&ak=", ___getUserInfoHost);
}



//  投资记录
+ (NSString *)investRecordList
{
    return HTSTR(@"%@/investRecord?ak=", ___getUserInfoHost);
}

//  申请提现
+ (NSString *)applyCash
{
    return HTSTR(@"%@/applyCash?ak=", ___getUserInfoHost);
}


#pragma mark -

//  提现
+ (NSString *)withDraw
{
    return HTSTR(@"%@/withdraw?ak=", ___getSecurityHost);
}

//  消息
+ (NSString *)message
{
    return HTSTR(@"%@/messages?ak=", ___baseHTTPHost);
}

#pragma mark - 投资

//  最新账户数据
+ (NSString *)investAccountInfo
{
    return HTSTR(@"%@/invest/base?type=&id=&ak=", ___baseHTTPHost);
}

//  投资
+ (NSString *)invest
{
    return HTSTR(@"%@/invest?ak=", ___baseHTTPHost);
}

#pragma mark - 充值
//  充值历史列表
+ (NSString *)rechargeMoney
{
    return HTSTR(@"%@/secure/query_mercust_bank_shortcut?ak=", ___baseHTTPHost);
}

//  下单接口
+ (NSString *)payInterface
{
    return HTSTR(@"%@/secure/query_mercust_bank_shortcut?ak=", ___baseHTTPHost);
}

//  协议支付--调用U付下发验证码
+ (NSString *)upaySmsMessage
{
    return HTSTR(@"%@/secure/req_smsverify_shortcut?ak=", ___baseHTTPHost);
}

//  协议支付--确认支付
+ (NSString *)confirmPay
{
    return HTSTR(@"%@/secure/agreement_pay_confirm_shortcut?ak=",___baseHTTPHost);
}

//  联动支付--解除绑定关系
+ (NSString *)termateBankCard
{
    return HTSTR(@"%@/secure/unbind_mercust_protocol_shortcut?ak=", ___baseHTTPHost);
}

//  实名认证



@end
