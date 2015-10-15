//
//  HTGestureViewController.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/17.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTBaseViewController.h"

typedef NS_ENUM(NSInteger, GestureType) {
    GestureTypeSetPass = 1,
    GestureTypeInputPass = 2
};

@interface HTGestureViewController : HTBaseViewController

@property (nonatomic, assign) BOOL shouldCancel;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, strong) UIImage *userImage;

+ (BOOL)isHaveSetGesturePass;
+ (BOOL)clearGesturePass;

@end
