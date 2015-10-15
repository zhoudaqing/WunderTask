//
//  SecondMarketController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/25.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "SecondMarketController11.h"
#import "P2CCell.h"
#import "P2CDataSource.h"


@interface SecondMarketController ()

@end

@implementation SecondMarketController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showRefreshHeaderView = YES;
    
    self.tableControl.shouldLoadMore = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *headerView = [[UIView alloc] init];
    headerView.height = 5.0f;
    self.tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] init];
    footerView.height = 5.0f;
    self.tableView.tableFooterView = footerView;
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 16; i++) {
        P2CDataSource *source = [[P2CDataSource alloc] init];
        [array addObject:source];
        source.p2cModel = [[P2CCellModel alloc] init];
    }

    self.tableControl.loadMoreCell.cellState = CellStateLoadingError;
    
    __weakSelf;
    [self.tableControl attachDetailAction:^(id object, id target, NSIndexPath *indexPath) {
        [weakSelf doNothing];
    } forCellClass:[P2CDataSource cellClass]];
    
    [self.tableControl attachHeaderAction:^(id object, id target, NSIndexPath *indexPath) {
        [weakSelf doNothing];
    } forCellClass:[P2CDataSource cellClass]];
    
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


@end
