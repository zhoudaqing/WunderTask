//
//  HTGestureView.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/16.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HTGestureViewProtocal <NSObject>

//  手势在移动过程中触发
- (void)gestureViewChanging:(int *)list;
//  手势输入完成
- (void)gestureViewDidFinish:(int *)list andPass:(NSString *)pass;

@end

@interface HTGestureView : UIView

@property (nonatomic, assign)   id <HTGestureViewProtocal>delegate;
//  手势密码字符串
@property (nonatomic, copy, readonly) NSString *gesturePass;
@property (nonatomic, assign, readonly) CGFloat edgeMargin;

//  手势错误的情况
- (void)showErrorGestureView;

//  状态重置
- (void)resetState;

@end


