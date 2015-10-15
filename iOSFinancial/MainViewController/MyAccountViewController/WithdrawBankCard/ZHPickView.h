//
//  ZHPickView.h
//  ZHpickView
//
//  Created by liudianling on 14-11-18.
//  Copyright (c) 2014年 赵恒志. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZHPickView;

@protocol ZHPickViewDelegate <NSObject>

@optional
-(void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString;

@end

@interface ZHPickView : UIView

@property(nonatomic,weak) id<ZHPickViewDelegate> delegate;

/**
 *  通过plistName添加一个pickView
 *
 *  @param plistName          plist文件的名字

 *  @param isHaveNavControler 是否在NavControler之内
 *
 *  @return 带有toolbar的pickview
 */
-(instancetype)initPickviewWithPlistName:(UIView *)selfView isHaveNavControler:(BOOL)isHaveNavControler withArray:(NSArray *)array;
/**
 *   移除本控件
 */
-(void)remove;
/**
 *  显示本控件
 */
-(void)show;
/**
 *  设置PickView的颜色
 */
-(void)setPickViewColer:(UIColor *)color;
/**
 *  设置toobar的文字颜色
 */
-(void)setTintColor:(UIColor *)color;
/**
 *  设置toobar的背景颜色
 */
-(void)setToolbarTintColor:(UIColor *)color;
@end

