//
//  HTPromptCircle.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/6/1.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTPromptCircle.h"

#define __PreProgressValue  .01f
#define __IndicateViewSize  5.0f

@interface HTPromptCircle ()

@property (nonatomic, strong)   CAShapeLayer *progressLayer;
@property (nonatomic, strong)   CAShapeLayer *backLayer;
@property (nonatomic, strong)   UILabel *textLabel;

@property (nonatomic, assign)   CGFloat lastPercent;
@property (nonatomic, assign)   BOOL isAnimating;

@end

@implementation HTPromptCircle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self createSubViews];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self createSubViews];
    }
    
    return self;
}

- (void)createSubViews
{
    self.backgroundColor = [UIColor clearColor];
    _tintColor = [UIColor redColor];
    _percent = .0f;
    
    [self.layer addSublayer:self.backLayer];
    self.backLayer.path = [self drawPathWithArcCenter:1.0f];
    
    [self.layer addSublayer:self.progressLayer];
    
    [self addSubview:self.textLabel];
}

- (void)setTextLabelString:(CGFloat)percent
{
    NSString *percentStr = HTSTR(@"%.0f", percent * 100);
    NSString *percentFormat = HTSTR(@"%@%%", percentStr);
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:percentFormat];
    [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:44.0f] range:NSMakeRange(0, percentStr.length)];
    //
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(percentStr.length, 1)];
    
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor jd_settingDetailColor] range:NSMakeRange(0, percentFormat.length)];
    
    _textLabel.attributedText = string;
}

- (void)setPercent:(CGFloat)percent
{
    [self setpercent:percent animated:NO];
}

- (void)setpercent:(CGFloat)percent animated:(BOOL)animate
{
    _percent = percent;
    
    if (percent < 0) {
        percent = .0f;
    }
    
    if (percent > 1) {
        percent = 1.0f;
    }
    
    self.progressLayer.path = [self drawPathWithArcCenter:_percent];
    
    if (animate && !_isAnimating) {
        _isAnimating = YES;
        [self removeAnimation];
        [self startAnimation];
    }
    
    [self setTextLabelString:percent];
}

- (void)setTintColor:(UIColor *)tintColor
{
    if (_tintColor != tintColor) {
        _tintColor = tintColor;
        _progressLayer.strokeColor = tintColor.CGColor;
    }
}

- (CGPathRef)drawPathWithArcCenter:(CGFloat)percent
{
    CGFloat position_y = self.frame.size.height/2;
    CGFloat position_x = self.frame.size.width/2;
    
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(position_x, position_y)
                                          radius:position_y
                                      startAngle:(-M_PI/2)
                                        endAngle:(-M_PI / 2.0f) + percent * M_PI * 2
                                       clockwise:YES].CGPath;
}

- (void)startAnimation
{
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.25;
    pathAnimation.fromValue = @(_lastPercent / _percent);
    pathAnimation.toValue = @(1);
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    pathAnimation.removedOnCompletion = YES;
    pathAnimation.delegate = self;
    
    [self.progressLayer addAnimation:pathAnimation forKey:@"strokeAnimation"];
}

- (void)removeAnimation
{
    [self.progressLayer removeAnimationForKey:@"strokeAnimation"];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    _isAnimating = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    _isAnimating = NO;
//    _lastPercent = _percent;
}

- (void)setShowPromptlabel:(BOOL)show
{
    if (show) {
        [self addSubview:self.promptLabel];
        
        self.textLabel.height = self.height / 2.0f - 20;
        self.textLabel.bottom = self.height / 2.0f + 5;

        self.promptLabel.width = self.width;
        self.promptLabel.top = self.height / 2.0f + 10;
    }
}

- (CAShapeLayer *)backLayer
{
    if (!_backLayer) {
        _backLayer = [CAShapeLayer layer];
        _backLayer.fillColor = [UIColor clearColor].CGColor;
        _backLayer.strokeColor = [UIColor colorWithHEX:0xf5f5f5].CGColor;
        _backLayer.lineWidth = 6.0f;
    }
    
    return _backLayer;
}

- (CAShapeLayer *)progressLayer
{
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.strokeColor = _tintColor.CGColor;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.lineJoin = kCALineJoinRound;
        _progressLayer.lineWidth = 6.0f;
    }
    
    return _progressLayer;
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _textLabel;
}

- (UILabel *)promptLabel
{
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.textColor = [UIColor jd_globleTextColor];
        _promptLabel.height = 20.0f;
        _promptLabel.font = HTFont(12.0f);
    }
    
    return _promptLabel;
}

@end
