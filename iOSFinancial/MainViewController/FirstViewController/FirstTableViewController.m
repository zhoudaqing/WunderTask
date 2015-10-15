//
//  FirstTableViewController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/1.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "FirstTableViewController.h"

#import "HTTableViewCell.h"
#import "CustomerCell.h"

@interface FirstTableViewController ()

@end

@implementation FirstTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showRefreshHeaderView = YES;
    
    self.tableControl.shouldLoadMore = YES;

    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 16; i++) {
        
        if (i % 2 == 0) {
            CustomerCellSource *source = [[CustomerCellSource alloc] init];
            source.title = @"hello";
            [array addObject:source];
            
        }else {
            TableViewSource *source = [TableViewSource new];
            source.title = HTSTR(@"%d", i);
            source.subTitle = HTSTR(@"subTitle:%d", i);
            [array addObject:source];
        }
    }
    self.tableControl.loadMoreCell.cellState = CellStateLoadingError;
    
    __weakSelf;
    [self.tableControl attachDetailAction:^(id object, id target, NSIndexPath *indexPath) {
        [weakSelf doNothing];
    } forCellClass:[TableViewSource cellClass]];
    
    [self.tableControl attachHeaderAction:^(id object, id target, NSIndexPath *indexPath) {
        [weakSelf doNothing];
    } forCellClass:[TableViewSource cellClass]];
    
    [self.tableControl attachDetailAction:^(id object, id target, NSIndexPath *indexPath) {
        [weakSelf doCustomNothing];
    } forCellClass:[CustomerCellSource cellClass]];
    
    [self.tableControl setLoadMoreActionBlock:^(id obj, id target, NSIndexPath *indexPath ) {
        [weakSelf loadMore];
    }];
    
    self.tableControl.sources = array;
    
    [self.tableView reloadData];
}

- (void)loadMore
{
    
    NSLog(@"loadMore");
}

- (void)doCustomNothing
{
    NSLog(@"customBinding");
    
    [self showHudAuto:@"customBinding"];
}

- (void)doNothing
{
    [self showHudSuccessView:@"GOOGOGO"];
    
    NSLog(@"BindSuccess");
}

/*
- (Class)tableControlClass
{
    return [PersonalTableControl class];
}
*/

@end
