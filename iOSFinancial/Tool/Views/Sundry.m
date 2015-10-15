//
//  Sundry.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/18.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "Sundry.h"

@implementation Sundry

+ (UIButton *)BigBtnWithHihtY:(double)Y withTitle:(NSString *)text
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, TransparentTopHeight + Y, APPScreenWidth - 20, 49);
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:18.0];
    button.layer.cornerRadius = 3.0;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor clearColor].CGColor;
    button.layer.masksToBounds = YES;
    
    [button setBackgroundImage:[self createImageWithColor:[UIColor jd_BigButtonNormalColor]] forState:UIControlStateNormal];
    [button setBackgroundImage:[self createImageWithColor:[UIColor jd_BigButtonHightedColor]] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[self createImageWithColor:[UIColor jd_BigButtonDisabledColor]] forState:UIControlStateDisabled];
    
    return button;
}

+ (UIButton *)BigBottomBtnWithTitle:(NSString *)text
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:text forState:UIControlStateNormal];
    button.frame = CGRectMake(0, APPScreenHeight - TransparentTopHeight - 92, APPScreenWidth, 49);
    button.alpha = 0.8;
    button.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [button setBackgroundImage:[self createImageWithColor:[UIColor jd_BigButtonNormalColor]] forState:UIControlStateNormal];
    [button setBackgroundImage:[self createImageWithColor:[UIColor jd_BigButtonHightedColor]] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[self createImageWithColor:[UIColor jd_BigButtonDisabledColor]] forState:UIControlStateDisabled];
    
    return button;
}

+ (UITextField *)CellTextFieldWithFrame :(CGRect)frame withPlaceholder:(NSString *)placeholder;
{
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.placeholder = placeholder;
    textField.font = [UIFont systemFontOfSize:13.0];
    textField.textAlignment = NSTextAlignmentRight;
    return textField;
}

+ (UIButton *)getVerifyNumberBtnWithFrame:(CGRect)frame
{
    UIButton *btn = [[UIButton alloc]initWithFrame:frame];
    [btn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [btn setBackgroundColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1]];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    return btn;
//    UIButton *btn = [[UIButton alloc]init];
//    
//    btn.frame = CGRectMake((frame.size.width - 100)*.5 + frame.origin.x , (frame.size.height - 34)*.5, 100, 34);
//    
//    btn.layer.cornerRadius = 5.0;
//    btn.layer.borderWidth = 1;
//    btn.layer.borderColor = [UIColor orangeColor].CGColor;
//    btn.layer.masksToBounds = YES;
//    [btn setTitle:@"获取验证码" forState:UIControlStateNormal];
//    [btn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
//    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
}

+ (UIView *)viewAddBackImgeAndlineNumber:(CGFloat)number withView:(UIView *)view
{
//    CGFloat heightH;
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
//    {
//        heightH = 64.0;
//    }else
//    {
//        heightH = 0;
//    }
    
    UIImageView *BackImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, TransparentTopHeight + 10, APPScreenWidth - 20, 44*number)];
    BackImageView.backgroundColor = [UIColor whiteColor];
    BackImageView.layer.cornerRadius = 3.0;
    BackImageView.layer.borderWidth = .3;
    BackImageView.userInteractionEnabled = YES;
    BackImageView.layer.masksToBounds = YES;
    BackImageView.layer.borderColor = [[UIColor jd_lineColor] CGColor];
    
    for (int i=1; i<number; i++) {
        UIImageView *rimLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, BackImageView.height/number*i, BackImageView.width, .5)];
        rimLine.backgroundColor = [UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:222.0/255.0 alpha:1];
        [BackImageView addSubview:rimLine];
    }
    
    return BackImageView;
}

+ (UITextField *)onBackimgeTextWith:(CGRect)frame withPlaceholder:(NSString *)placeholder
{
    UITextField *textFied = [[UITextField alloc]initWithFrame:frame];
    textFied.placeholder = placeholder;
    textFied.frame = CGRectInset(frame, 6, 3);
    textFied.clearButtonMode = UITextFieldViewModeWhileEditing;
    textFied.font = [UIFont systemFontOfSize:15.0];
    textFied.textColor = [UIColor jd_globleTextColor];
    
    return textFied;
}

+ (UIImageView *)rimLine
{
    UIImageView *rimLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,APPScreenWidth,0.5)];
    rimLine.backgroundColor = [UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:222.0/255.0 alpha:1];
    return rimLine;
}

+ (UIImage *)createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


+ (NSString *)nameWithString:(NSString *)string
{
    
    if ([self validateMobile:string]) {
        string = [string stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }else if ([self validateEmail:string]){
        string = [string stringByReplacingCharactersInRange:NSMakeRange(2, 2) withString:@"**"];
    }else
    {
        string = [string stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"*"];
    }
    return string;
}

//** Email验证
+ (BOOL) validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


//** 手机号码验证
+ (BOOL) validateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9])|(17[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}
//** 昵称
+ (BOOL) validateNickname:(NSString *)nickname
{
    NSString *nicknameRegex = @"^[\u4e00-\u9fa5]{4,8}$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nicknameRegex];
    return [passWordPredicate evaluateWithObject:nickname];
}


@end
