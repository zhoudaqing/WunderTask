//
//  HTGesutreSignView.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/16.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  手势的顶部缩略的小图
 */

@interface HTGestureInditaor : UIView
{
    int *_signList;
}

//  设置选中的标记
- (void)refreshSignList:(int *)signArray;

//  清除所有的标记
- (void)resetSignViewState;

@end
