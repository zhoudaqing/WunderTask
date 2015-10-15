//
//  InvesetDetailHeaderView.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvesetDetailHeaderView.h"
#import "HTPercentView.h"
#import "UIView+Animation.h"

@implementation HeaderSubView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _titleView = [[[NSBundle mainBundle] loadNibNamed:@"TitleView" owner:self options:nil] lastObject];
        [self addSubview:_titleView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleView.frame = self.bounds;
}

@end

@interface InvesetDetailHeaderView ()

@property (nonatomic, strong)   HTPercentView *persentView;

@property (nonatomic, strong)   IBOutlet UILabel *titleLabel;

@property (nonatomic, strong)  IBOutlet HeaderSubView *headerSubView1;
@property (nonatomic, strong)  IBOutlet HeaderSubView *headerSubView2;
@property (nonatomic, strong)  IBOutlet HeaderSubView *headerSubView3;
@property (nonatomic, strong)  IBOutlet HeaderSubView *headerSubView4;

@property (nonatomic, strong)   IBOutlet UIView *lineView1;
@property (nonatomic, strong)   IBOutlet UIView *lineView2;
@property (nonatomic, strong)   IBOutlet UIView *lineView11;
@property (nonatomic, strong)   IBOutlet UIView *lineView12;

@property (nonatomic, strong)   NSArray *headerViews;

@end

@implementation InvesetDetailHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _titleLabel.textColor = [UIColor jd_settingDetailColor];
    _titleLabel.font = HTFont(16.0f);
    
    self.lineView1.backgroundColor = [UIColor jd_lineColor];
    self.lineView2.backgroundColor = [UIColor jd_lineColor];
    self.lineView11.backgroundColor = [UIColor jd_lineColor];
    self.lineView12.backgroundColor = [UIColor jd_lineColor];
    
    _headerViews = @[_headerSubView1,
                     _headerSubView2,
                     _headerSubView3,
                     _headerSubView4];
    
    //  persentView
    [self addSubview:self.persentView];

//    [self.persentView setpercent:.0f animated:NO];
    
    [self configTitleView];
    
    [self setTimeLeft:@"--"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.persentView.left = (self.width - self.persentView.width) / 2.0f;
    self.persentView.top = 26.0f;
    
    self.lineView2.height = __Globle_line_width;
    self.lineView1.height = __Globle_line_width;
    self.lineView11.width = __Globle_line_width;
    self.lineView12.width = __Globle_line_width;
}

#pragma mark - Setting

- (void)setTitleStr:(NSString *)title
{
    self.titleLabel.text = title;
}

//  设置进度条
- (void)setPersent:(CGFloat)persent
{
    [self.persentView setpercent:persent animated:YES];
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
        
        if (3 == index) {
            [subView.titleView.titleLabel flashAnimation];
        }
        
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
    return @[@"年化收益率", @"项目期限", @"可投金额(元)", @"剩余时间"][index];
}

- (HTPercentView *)persentView
{
    if (!_persentView) {
        _persentView = [[HTPercentView alloc] initWithFrame:CGRectMake(0, 0, 110, 110)];
        _persentView.tintColor = [UIColor jd_settingDetailColor];
    }

    return _persentView;
}

@end
