//
//  RedemptionViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/7/14.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "RedemptionViewController.h"
#import "RedeemingViewController.h"
#import "RedeemedViewController.h"

@interface RedemptionViewController ()

@end

@implementation RedemptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"赎回项目";
    self.separateView.backgroundColor = [UIColor whiteColor];
}

- (NSArray *)functionTitles
{
    if (!_functionTitles) {
        _functionTitles = @[@"正在赎回", @"已经赎回"];
    }
    
    return _functionTitles;
}

- (NSArray *)selectionControllers
{
    NSMutableArray *array = [@[]mutableCopy];
    
    if (!_selectionControllers) {
        RedeemingViewController *redeeming = [[RedeemingViewController alloc] init];
        [array addObject:redeeming];
        
        RedeemedViewController *redeemed = [[RedeemedViewController alloc] init];
        [array addObject:redeemed];
        _selectionControllers = array;
    }
    
    return _selectionControllers;
}


@end
