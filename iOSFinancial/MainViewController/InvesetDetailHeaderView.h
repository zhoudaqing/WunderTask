//
//  InvesetDetailHeaderView.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseView.h"
#import "TitleView.h"


@interface HeaderSubView : UIView

@property (nonatomic, strong)   TitleView *titleView;

@end

@interface InvesetDetailHeaderView : HTBaseView

//  设置标题
- (void)setTitleStr:(NSString *)title;
//  设置进度条
- (void)setPersent:(CGFloat)persent;
//  设置年化收益率
- (void)setAnnualize:(NSString *)string;
//  设置项目期限
- (void)setReturnCycle:(NSString *)month;
//  设置可投金额
- (void)setInvesetMoney:(NSString *)invest;
//  设置剩余时间
- (void)setTimeLeft:(NSString *)timeLeft;

@end

