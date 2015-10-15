//
//  InvestSelectionViewController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/25.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvestSelectionViewController.h"
#import "RedeemMarketController.h"
#import "P2CMarketController.h"


@interface InvestSelectionViewController ()


@end

@implementation InvestSelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.separateView.backgroundColor = [UIColor whiteColor];
}

- (NSArray *)functionTitles
{
    if (!_functionTitles) {
        _functionTitles = @[@"理财项目", @"债权转让"];
    }
    
    return _functionTitles;
}

- (NSArray *)selectionControllers
{
    if (!_selectionControllers) {
        P2CMarketController *controller = [[P2CMarketController alloc] init];
        
        RedeemMarketController *market = [[RedeemMarketController alloc] init];

        _selectionControllers = @[controller, market];
    }

    return _selectionControllers;
}

- (BOOL)separateViewShouldChangeMenuAtIndex:(NSInteger)index
{
    BOOL should = [super separateViewShouldChangeMenuAtIndex:index];
    
    if (should) {
        
        UIViewController * viewController = [self.selectionControllers objectAtIndex:index];
        if ([viewController isKindOfClass:[P2CMarketController class]]) {
            P2CMarketController *p2c = (P2CMarketController *)viewController;
            [p2c refreshInvestDataList];
        }
        
        return YES;
        
    }else {
        
        return NO;
    }
    
}

- (NSString *)title
{
    return @"理财";
}

@end
