//
//  InvestHeaderView.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/28.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvestHeaderView.h"
#import "UIView+Animation.h"

@interface InvestHeaderView ()
 
@property (nonatomic, strong)   IBOutlet HeaderSubView *headerSubView1;
@property (nonatomic, strong)   IBOutlet HeaderSubView *headerSubView2;
@property (nonatomic, strong)   IBOutlet HeaderSubView *headerSubView3;

@property (nonatomic, strong)   IBOutlet UIView *line1;
@property (nonatomic, strong)   IBOutlet UIView *line11;
@property (nonatomic, strong)   IBOutlet UIView *line12;

@property (nonatomic, strong)   NSArray *headerViews;

@property (nonatomic, strong)   IBOutlet NSLayoutConstraint *headerSubViewWidth;

@end

@implementation InvestHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _titlLabel.font = HTFont(16.0f);
    _titlLabel.textColor = [UIColor jd_globleTextColor];
    
    self.line1.backgroundColor = [UIColor jd_lineColor];
    self.line11.backgroundColor = [UIColor jd_lineColor];
    self.line12.backgroundColor = [UIColor jd_lineColor];
    
    _titlLabel.backgroundColor = [UIColor clearColor];
    
    _headerViews = @[_headerSubView1,
                     _headerSubView2,
                     _headerSubView3
                     ];
    /*
    _headerSubView1.layer.borderColor = HTRedColor.CGColor;
    _headerSubView1.layer.borderWidth = 1.0f;
    
    _headerSubView2.layer.borderColor = HTRedColor.CGColor;
    _headerSubView2.layer.borderWidth = 1.0f;
    
    _headerSubView3.layer.borderColor = HTRedColor.CGColor;
    _headerSubView3.layer.borderWidth = 1.0f;
     */
    
    [self configTitleView];
}

#pragma mark - Setting

- (HeaderSubView *)setTitleViewDetailAtIndex:(NSInteger)index  withValue:(NSString *)value
{
    HeaderSubView *subView = _headerViews[index];
    if (subView) {
        subView.titleView.titleLabel.text = value;
    }
    
    return subView;
}

//  设置标题
- (void)setTitle:(NSString *)title
{
    _titlLabel.text = title;
}

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
    HeaderSubView *subView = [self setTitleViewDetailAtIndex:2 withValue:invest];
    
    if (![invest isEqualToString:subView.titleView.titleLabel.attributedText.string]) {
        [subView.titleView.titleLabel flashAnimation];
    }
    
}

//  设置剩余时间
- (void)setTimeLeft:(NSString *)timeLeft
{
    [self setTitleViewDetailAtIndex:3 withValue:timeLeft];
    
}

#pragma mark - 

- (void)configTitleView
{
    for (HeaderSubView *subView in _headerViews) {
        NSInteger index = [_headerViews indexOfObject:subView];
        subView.titleView.promptLabel.text = [self titlesAtIndex:index];
    }
}

- (NSString *)titlesAtIndex:(NSInteger)index
{
    return @[@"年化收益率", @"项目期限", @"可投金额(元)"][index];
}

@end
