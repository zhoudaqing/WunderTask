//
//  RedeemViewController.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/7/14.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseTableViewController.h"
#import "RedeenModel.h"

@protocol RedeemViewDelegate <NSObject>

- (void)selfDissMiss;

@end

@interface RedeemViewController : HTBaseTableViewController

@property (nonatomic,strong) RedeenModel *redeenModel;

@property (nonatomic, weak) id<RedeemViewDelegate>delegate;

@end
