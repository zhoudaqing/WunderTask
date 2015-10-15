
//
//  HTGestureConfig.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/5/4.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#ifndef iOSFinancial_HTGestureConfig_h
#define iOSFinancial_HTGestureConfig_h


#define __ScreenHeight    [UIScreen mainScreen].bounds.size.height
#define __is35Inch   ((NSInteger)__ScreenHeight == 480 ? YES : NO)
#define __is4Inch   ((NSInteger)__ScreenHeight == 568 ? YES : NO)
#define __is47Inch  ((NSInteger)__ScreenHeight == 667 ? YES : NO)
#define __is55Inch  ((NSInteger)__ScreenHeight == 736 ? YES : NO)

//  允许的重试次数
#define __RetryCount    4

static NSString *const kUserInputGesturePass    =   @"kUserInputGesturePass";
static NSInteger const kRetryCount  = 5;

static int margin = 15;
static int cirleSize = 66;

static int kLineWith = 2.0f;

#endif
