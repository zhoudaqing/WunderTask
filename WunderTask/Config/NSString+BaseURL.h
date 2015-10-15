//
//  NSString+BaseURL.h
//  ShiPanOnline
//
//  Created by Mr.Yang on 14-2-25.
//  Copyright (c) 2014年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerHostConfig.h"

/*
*  NOTE:接口文档地址
*  URL:https://github.com/jiandanlicai/earth/blob/master/dev_docs/app_api_v1.0.1.md
*/

@interface NSString (BaseURL)

//  硬件版本号
+ (NSString *)platform;

+ (NSString*)machineName;

+ (NSString *)wideIpAddress;
//  判断网络环境
+ (int)dataNetworkTypeFromStatusBar;

/*-------------------------  APP  --------------------------*/

//  升级
+ (NSString *)app_version_check;

//  注册
+ (NSString *)user_regedit;

//  登录
+ (NSString *)user_login;

//  验证用户密码
+ (NSString *)verificatifyUserPassword;

//  发送短信验证码--注册
+ (NSString *)getMessageAtRigist;

//  发送短信验证码--找回登录密码
+ (NSString *)getMessageAtFindPass;

//  发送短信验证码--绑定手机号
+ (NSString *)getMessgeAtBindPhone;

//  发送短信验证码--修改支付密码
+ (NSString *)getMessageAtModifyPayPass;

// 通用短信验证码验证接口
+ (NSString *)verificationMessageNumber;

/*-------------------------  项目列表  --------------------------*/

//  广告业列表
+ (NSString *)adveriseList;

//  投资项目列表
+ (NSString *)investList;

//  投资项目详情
+ (NSString *)investDetail:(NSString *)investID;

//  投资 （刷新个人账户）
+ (NSString *)investAccount:(NSString *)investID;

//  投资
+ (NSString *)invsetAction:(NSString *)investID;

//  候选项目
+ (NSString *)investWillInvestList;

// 普通项目投资列表
+ (NSString *)investRecord;

//-------------------------- 债券

//  债券列表
+ (NSString *)redeemList;

//  债券详情
+ (NSString *)redeemDetail:(NSString *)redeemID;

// 赎回投资列表
+ (NSString *)redeemsInvestRecord;

// 投资分享成功返现 ---
+ (NSString *)sharedAward;

// 投资成功后查询分享 ---
+ (NSString *)sharingValidation;

//  债券投资 (刷新个人账户)
+ (NSString *)redeemAccount:(NSString *)redeemID;

//  债券投资
+ (NSString *)redeemAction:(NSString *)redeemID;



/*-------------------------  我的账户  --------------------------*/

//  我的账户主页面
+ (NSString *)getMyAccount;

//  投资中
+ (NSString *)getProjectsInvestRecord;

// 查看投资中合同
+ (NSString *)agreement;

// 点击投资中----提前赎回
+ (NSString *)projectsRelationReback;

// 确认赎回------最新数据更新
+ (NSString *)loansRelationRedeemBase;

// 确认赎回----点击确认赎回按钮
+ (NSString *)loansRelationRedeem;

// 提现中
+ (NSString *)withdrawing;

// 账户余额
+ (NSString *)investorBill;

// 申请提现
+ (NSString *)secureWithdraw;

// 累计收益
+ (NSString *)allIncome;

//  红包头文件
+ (NSString *)getCashgiftInfo;

//   红包记录
+ (NSString *)getRecorder;

//  剩余回款
+ (NSString *)investorReback;

// 赎回项目
+ (NSString *)redeemingRcord;

// 赎回项目---已经赎回
+ (NSString *)redeemedRcord;

//  提现银行卡
+ (NSString *)bankCard;

//  添加提现银行卡
+  (NSString *)addBankCard;

// 编辑银行卡
+ (NSString *)editBankCard;

// 余额生息
+ (NSString *)balanceAccout;

// 邀请好友
+ (NSString *)inviteInfo;

// 充值拉卡信息
+ (NSString *)safeCard;

// 首次充值下单
+ (NSString *)firstRecharge;
// 首次绑卡
+ (NSString *)lianlianAddCard;


/*-------------------------  重置密码  --------------------------*/

//  修改登陆密码
+ (NSString *)resetLoginPass;

//  修改支付密码
+ (NSString *)resetPayPass;

//  找回登录密码
+ (NSString *)findBackPass;

//
//  发布项目
//

//  发布项目倒计时
+ (NSString *)projectReleaseDate;

//  版本号
+ (NSString *)version;

//  关于我们
+ (NSString *)aboutUs;

//  退出
+ (NSString *)loginOut;

//  用户反馈
+ (NSString *)userFeedBack;

/*------------------------- 更多  --------------------------*/

//  查询个人中心的相关信息
+ (NSString *)more;

//  绑定身份证号
+ (NSString *)bindIDCard;

//  绑定手机号
+ (NSString *)bindPhone;

//  绑定用户名
+ (NSString *)bindUserRealName;

/*-----------------------------------------*/

//  绑定银行卡
+ (NSString *)bindBankCard;

//  资产管理
+ (NSString *)assetManage;

//  交易记录
+ (NSString *)tradeRecoderList;

//  投资记录
+ (NSString *)investRecordList;

//  申请提现
+ (NSString *)applyCash;

//  提现
+ (NSString *)withDraw;

//  消息
+ (NSString *)message;

//  最新账户数据
+ (NSString *)investAccountInfo;

//  投资
+ (NSString *)invest;

//  充值历史列表
+ (NSString *)rechargeMoney;

//  下单接口
+ (NSString *)payInterface;

//  协议支付--调用U付下发验证码
+ (NSString *)upaySmsMessage;

//  协议支付--确认支付
+ (NSString *)confirmPay;

//  联动支付--解除绑定关系
+ (NSString *)termateBankCard;


@end
