//
//  ProgressView.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/6/1.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "ProgressView.h"

@interface ProgressView()

@property (nonatomic, strong) UILabel *label;


@end

@implementation ProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //        self.backgroundColor = [UIColor redColor];
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.detailLable];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    // 0~1
    if (progress != _progress) {
        _progress = progress;
        // 先设置label的数值
        self.label.text = [NSString stringWithFormat:@"%.2f%%", progress*100];
        [self setNeedsDisplay];
    }
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 36, self.width, 24)];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:24.0];
        _label.textColor = [UIColor jd_settingDetailColor];
        
        [self addSubview:_label];
    }
    return _label;
}

- (UILabel *)detailLable
{
    if (!_detailLable) {
        _detailLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, self.width, 15.0)];
        _detailLable.font = [UIFont systemFontOfSize:12.0];
        _detailLable.textAlignment = NSTextAlignmentCenter;
        _detailLable.textColor = [UIColor jd_globleTextColor];
    }
    return _detailLable;
    
}

- (void)drawRect:(CGRect)rect
{
    
    
    
    // 根据progress的数值绘制弧线
    CGContextRef contextB = UIGraphicsGetCurrentContext();
    CGContextRef context  = UIGraphicsGetCurrentContext();
    // 圆心坐标
    CGFloat x = self.bounds.size.width * 0.5;
    CGFloat y = self.bounds.size.height * 0.5;
    CGFloat r = (x > y) ? y : x;
    r -= 5;
    
    // self.progress 当前进度的%比
    
    
    CGContextAddArc(contextB, x, y, r, -M_PI_2, 2 * M_PI - M_PI_2, 0);
    
    CGContextSetLineWidth(contextB, 5.0);
    [[UIColor colorWithHEX:0xf5f5f5] set];
    
    
    // 绘制弧线
    CGContextDrawPath(context, kCGPathStroke);
    
    CGFloat endA = (self.progress * 2 * M_PI) - M_PI_2;
    
    CGContextAddArc(context, x, y, r, -M_PI_2, endA, 0);
    
    CGContextSetLineWidth(context, 5.0);
    [self.lineColor set];
    
    // 绘制弧线
    CGContextDrawPath(context, kCGPathStroke);
    
    
}


@end
