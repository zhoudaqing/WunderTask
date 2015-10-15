//
//  HTPromptCircle.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/6/1.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTPromptCircle : UIView

//  带提示

@property (nonatomic, strong)   UILabel *promptLabel;

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, assign) CGFloat percent;

- (void)setShowPromptlabel:(BOOL)show;

- (void)setpercent:(CGFloat)percent animated:(BOOL)animate;


@end
