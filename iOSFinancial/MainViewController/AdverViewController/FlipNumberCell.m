//
//  FlipNumberCell.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/6/9.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "FlipNumberCell.h"
#import "FlickerView.h"
#import "UIView+Animation.h"
#import "UILabel+FlickerNumber.h"
#import "NSString+Size.h"
#import "UIView+Layer.h"

@interface FlipTitleView ()

@property (nonatomic, strong)   FlickerView *flickerView;


@end

@implementation FlipTitleView


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self addSubview:self.flickerView];
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.flickerView.frame = self.bounds;
    
}

- (FlickerView *)flickerView
{
    if (!_flickerView) {
        _flickerView = [FlickerView xibView];
    }
    
    return _flickerView;
}

@end


@interface FlipNumberCell ()

@property (nonatomic, assign)   NSInteger animationIndex;
@property (nonatomic, strong)   NSArray *flickViews;
@property (nonatomic, assign)   BOOL isAnimating;

@end

@implementation FlipNumberCell

+ (CGFloat)fixedHeight
{
    if (is55Inch) {
        return 198.0f;
    }
    
    return 148.0f;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor jd_accountBackColor];
    _flickViews = @[_titleView1.flickerView, _titleView2.flickerView, _titleView3.flickerView];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleView2.top = 16.0f;
    _titleView2.centerX = self.centerX;
    
    if (is55Inch) {
        _titleView2.top = 10.0f;
        
        _titleView1.bottom = self.height - 16.0f;
        _titleView1.width = 150.0f;

        _titleView3.width = 140.0f;
        _titleView3.bottom = self.height - 30.0f;

    }else if (is47Inch) {
        
        _titleView1.bottom = self.height - 16.0f;
        _titleView1.width = 140.0f;
        
        _titleView3.width = 128.0f;
        _titleView3.bottom = self.height - 30.0f;
        
    }else {
        _titleView1.bottom = self.height - 16.0f;
        _titleView1.width = 138.0f;
        
        _titleView3.width = 116.0f;
        _titleView3.bottom = self.height - 30.0f;
    }

    _titleView1.left = 0.0f;
    _titleView3.right = self.width;
}


- (void)setTitles
{
    [self setTitleAtIndex:0];
    [self setTitleAtIndex:1];
    [self setTitleAtIndex:2];
}

- (void)startAnimation
{
    if (_isAnimating || [_investoreFree integerValue] == 0) {
        return;
    }
    
    [self setTitleAtIndex:0];
    [self.titleView1 popOutWithDelegate:self];
    _isAnimating = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    _animationIndex++;

    if (1 == _animationIndex) {
        [self setTitleAtIndex:1];
        [self.titleView2 popOutWithDelegate:self];
        
    }else if (2 == _animationIndex) {
        [self setTitleAtIndex:2];
        [self.titleView3 popOutWithDelegate:self];
        
    }else {
        _animationIndex = 0;
        _isAnimating = NO;
    }

}

- (void)setTitleAtIndex:(NSInteger)index
{
    FlickerView *flickView = [_flickViews objectAtIndex:index];
    
    flickView.titleLabel.text = [self titleAtIndex:index];
    
    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
    format.numberStyle = NSNumberFormatterDecimalStyle;
    
    [flickView.numberLabel dd_setNumber:[self numberAtIndex:index] duration:1.0f formatter:format];
    
}

//  数字
- (NSNumber *)numberAtIndex:(NSInteger)index
{
    switch (index) {
        case 0:return @([self.investoreFree integerValue]);
        case 1:return @([self.totalIncome integerValue]);
        case 2:return @([self.registerNumb integerValue]);
    }

    return @(0);
}

//  标题
- (NSString *)titleAtIndex:(NSInteger)index
{
    switch (index) {
        case 0: return @"累计投资(元)";
        case 1: return @"累计收益(元)";
        case 2: return @"累计注册人数(人)";
    }
    
    return @"";
}


@end
