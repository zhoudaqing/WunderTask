//
//  JRJBaseViewController
//  ShiPanOnline
//
//  Created by Mr.Yang on 14-2-22.
//  Copyright (c) 2014年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTViewControllerDelegate.h"
#import "UIColor+Colors.h"
#import "LoadingStateView.h"


@interface HTBaseViewController : UIViewController <ViewControllerPromptingDelegate,
                                                    ViewControllerKeyboardNotificationDelegate,
                                                    ViewControllerDismissDelegate>


//  键盘是否打开了
@property (nonatomic, assign, readonly)   BOOL isKeyboardAppear;
//  是否第一次load此视图
@property (nonatomic, assign, readonly)   BOOL isFirstLoadView;
//  等待视图
@property (nonatomic, strong)   LoadingStateView *loadingStateView;

//  显示网络连接状态的视图
- (void)showLoadingViewWithState:(LoadingState)loadingState;
- (void)removeLoadingView;
//  （子类实现）
- (void)willChangePromptView;

/*
    MARK:重新登录
 */
- (void)presentUserLoginViewController;
- (void)presentUserLoginViewController:(UIViewController *)viewController;
/*
 *  MARK:显示手势解锁
 */
- (void)presentGestureViewController;
- (void)presentGestureViewController:(UIViewController *)viewController;

/**
 *  重置statesBarStyle
 *
 *  @param Yes is light  no is Default
 */
- (void)changeStateBarStyleLight:(BOOL)light;

//  显示引导图
- (void)showGuideView;

//  需要显示的引导图
- (NSArray *)guideImages;

//  显示引导图
- (void)showGuideViewCheck;

//  获取键盘视图
- (UIView *)keyboardView;

//  左右侧的navigationItem
- (NSString *)leftNavigationImageStr;
- (NSString *)rightNavigationImageStr;

- (void)leftBarItemClicked:(UIButton *)button;
- (void)rightBarItemClicked:(UIButton *)button;

- (void)changeTabbarIndex;

//  添加左上角的关闭按钮
- (void)addCloseBarbutton;

@end
