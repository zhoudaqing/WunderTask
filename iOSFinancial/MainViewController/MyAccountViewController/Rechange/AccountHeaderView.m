
//
//  AccountHeaderView.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/29.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "AccountHeaderView.h"

@interface AccountHeaderView ()


@end


@implementation AccountHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configView];
    
}

- (void)configView
{
    self.backgroundColor = [UIColor jd_accountBackColor];
    
    UIColor *whiteColor = [UIColor whiteColor];
    
    _totalLabel.textColor = whiteColor;
    _totalMoney.textColor = whiteColor;
    
    _lineView1.backgroundColor = [UIColor whiteColor];
    _lineView1.alpha = .3f;
    _lineView11.backgroundColor = [UIColor whiteColor];
    _lineView11.alpha = .3f;
    
    _inComeView.backgroundColor = [UIColor clearColor];
    _inComeLabel.textColor = whiteColor;
    _inComeMoney.textColor = whiteColor;
    
    _outView.backgroundColor = [UIColor clearColor];
    _outLabel.textColor = whiteColor;
    _outMoney.textColor = whiteColor;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self makeHighLight:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self makeHighLight:nil];
    [self makeTouched:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self makeHighLight:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self makeHighLight:nil];
}

- (void)makeHighLight:(NSSet *)touches
{
    int touchView = [self isContainsTouch:touches];
    
    if (touchView == __leftViewTouched) {
        _inComeView.backgroundColor = [UIColor colorWithHEX:0xec5300];
        _outView.backgroundColor = [UIColor clearColor];
        
    }else if (touchView == __rightViewTouched) {
        _outView.backgroundColor = [UIColor colorWithHEX:0xec5300];
        _inComeView.backgroundColor = [UIColor clearColor];
        
    }else {
        _inComeView.backgroundColor = [UIColor clearColor];
        _outView.backgroundColor = [UIColor clearColor];
    }
}

- (void)makeTouched:(NSSet *)touches
{
    int touchView = [self isContainsTouch:touches];
    if (touchView == __leftViewTouched) {
        if (_leftViewBlock) {
            _leftViewBlock(self);
        }
        
    }else if (touchView == __rightViewTouched) {
        if (_rightViewBlock) {
            _rightViewBlock (self);
        }
    }
}

static const int __leftViewTouched = 1;
static const int __rightViewTouched = 2;

- (int)isContainsTouch:(NSSet *)touches
{
    UITouch *touche = [touches anyObject];
    CGPoint location = [touche locationInView:self];
    
    if (CGRectContainsPoint(self.inComeView.frame, location)) {
        return __leftViewTouched;
    }else if (CGRectContainsPoint(self.outView.frame, location)) {
        return __rightViewTouched;
    }else {
        return 0;
    }
}

@end
