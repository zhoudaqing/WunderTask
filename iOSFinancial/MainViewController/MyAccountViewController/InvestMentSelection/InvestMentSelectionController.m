//
//  InvestMentSelectionController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/26.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvestMentSelectionController.h"
#import "InvestingTableViewController.h"

@interface InvestMentSelectionController ()

@end

@implementation InvestMentSelectionController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"投资中";
    
    self.separateView.backgroundColor = [UIColor whiteColor];
    
}

- (NSArray *)functionTitles
{
    if (!_functionTitles) {
         _functionTitles = @[@"正在回款", @"正在投标", @"已还清"];
    }
    
    return _functionTitles;
}

- (NSArray *)selectionControllers
{
    NSMutableArray *array = [@[]mutableCopy];

    if (!_selectionControllers) {
        InvestingTableViewController *investController = [[InvestingTableViewController alloc] init];
        investController.url = [NSString  stringWithFormat:@"%@?status=2",[NSString getProjectsInvestRecord]];
        investController.i = 0;
        [array addObject:investController];
        
        InvestingTableViewController *toInvest = [[InvestingTableViewController alloc] init];
        toInvest.url = [NSString  stringWithFormat:@"%@?status=1",[NSString getProjectsInvestRecord]];
        toInvest.i = 1;
        [array addObject:toInvest];
        
        InvestingTableViewController *finish = [[InvestingTableViewController alloc] init];
        finish.url = [NSString  stringWithFormat:@"%@?status=3",[NSString getProjectsInvestRecord]];
        finish.i = 2;
        [array addObject:finish];
        
        _selectionControllers = array;
    }
    
    return _selectionControllers;
}

@end
