//
//  Sundry.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/18.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+Colors.h"

@interface Sundry : NSObject

//  常用大按钮
+ (UIButton *)BigBtnWithHihtY:(double)Y withTitle:(NSString *)text;

//  tableViewCell常用textField
+ (UITextField *)CellTextFieldWithFrame:(CGRect)frame withPlaceholder:(NSString *)placeholderp;

// 底部大按钮
+ (UIButton *)BigBottomBtnWithTitle:(NSString *)text;

// 获取验证码按钮
+ (UIButton *)getVerifyNumberBtnWithFrame:(CGRect)frame;

// 常用图框
+ (UIView *)viewAddBackImgeAndlineNumber:(CGFloat)number withView:(UIView *)view;

// 在图框上德textField
+ (UITextField *)onBackimgeTextWith:(CGRect)frame withPlaceholder:(NSString *)placeholder;

//  一条线
+ (UIImageView *)rimLine;


//  颜色转image 设置按钮背景色使用
+ (UIImage *)createImageWithColor: (UIColor*) color;

//  自动隐藏换成星号

+ (NSString *)nameWithString:(NSString *)string;

@end
