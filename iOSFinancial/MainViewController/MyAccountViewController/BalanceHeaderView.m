//
//  BalanceHeaderView.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/30.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "BalanceHeaderView.h"
#import "InvestHeaderView.h"


@interface BalanceHeaderView ()

@property (nonatomic, strong)  IBOutlet HeaderSubView *headerSubView1;
@property (nonatomic, strong)  IBOutlet HeaderSubView *headerSubView2;
@property (nonatomic, strong)  IBOutlet HeaderSubView *headerSubView3;
@property (nonatomic, strong)  IBOutlet HeaderSubView *headerSubView4;

@property (nonatomic, strong)   IBOutlet UIView *lineView1;
@property (nonatomic, strong)   IBOutlet UIView *lineView11;
@property (nonatomic, strong)   IBOutlet UIView *lineView12;

@property (nonatomic, strong)   NSArray *headerViews;

@end

@implementation BalanceHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.lineView1.backgroundColor = [UIColor jd_lineColor];
    self.lineView11.backgroundColor = [UIColor jd_lineColor];
    self.lineView12.backgroundColor = [UIColor jd_lineColor];
    
    self.lineView1.height = __Globle_line_width;
    self.lineView11.width = __Globle_line_width;
    self.lineView12.width = __Globle_line_width;
    
    _headerViews = @[_headerSubView1,
                     _headerSubView2,
                     _headerSubView3,
                     _headerSubView4];
    
    [self configTitleView];
}


#pragma mark - Setting

//  设置年化收益率
- (void)setAnnualize:(NSString *)string
{
    [self setTitleViewDetailAtIndex:0 withValue:string];
}

//  设置项目期限
- (void)setReturnCycle:(NSString *)month
{
    [self setTitleViewDetailAtIndex:1 withValue:month];
}

//  设置可投金额
- (void)setInvesetMoney:(NSString *)invest
{
    [self setTitleViewDetailAtIndex:2 withValue:invest];
}

//  设置剩余时间
- (void)setTimeLeft:(NSString *)timeLeft
{
    [self setTitleViewDetailAtIndex:3 withValue:timeLeft];
    
}

#pragma mark - Config

- (void)setTitleViewDetailAtIndex:(NSInteger)index  withValue:(NSString *)value
{
    HeaderSubView *subView = _headerViews[index];
    if (subView) {
        subView.titleView.titleLabel.text = value;
    }
}

- (void)configTitleView
{
    for (HeaderSubView *subView in _headerViews) {
        NSInteger index = [_headerViews indexOfObject:subView];
        subView.titleView.promptLabel.text = [self titlesAtIndex:index];
    }
}

- (NSString *)titlesAtIndex:(NSInteger)index
{
    return @[@"昨日到账收益(元)", @"累计余额收益(元)", @"7日年化收益率(%)", @"万份收益(元)"][index];
}

@end
