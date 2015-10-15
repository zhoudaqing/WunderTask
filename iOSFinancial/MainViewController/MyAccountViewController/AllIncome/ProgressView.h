//
//  ProgressView.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/6/1.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @header ProgressView
 @abstract
 @discussion    画圆辅助工具
 */

@interface ProgressView : UIView


/** 进度数值0~1.0，供外界访问 */
@property (nonatomic, assign) CGFloat progress;

/** 线的背景颜色 */
@property (nonatomic) UIColor *lineColor;

/** 进度数的颜色 */
@property (nonatomic, strong) UILabel *detailLable;


@end
