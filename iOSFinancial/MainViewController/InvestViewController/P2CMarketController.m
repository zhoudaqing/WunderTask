//
//  P2CMarketController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/25.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "P2CMarketController.h"
#import "P2CCell.h"
#import "P2CDataSource.h"
#import "InvestMarketDetailController.h"
#import "InvestViewController.h"
#import "HTNavigationController.h"
#import "HTCircleView.h"
#import "MobClick.h"

@interface P2CMarketController ()

@end

@implementation P2CMarketController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.isRedeem = NO;
    }
    
    return self;
}

- (NSString *)projectListRequestURL
{
    return [NSString investList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableControl.loadMoreCell.backgroundColor = [UIColor clearColor];
    
    __weakSelf;
    [self.tableControl attachDetailAction:^(id object, id target, NSIndexPath *indexPath) {
        HTBaseTableControl *control = target;
        P2CDataSource *source = [control.sources objectAtIndex:indexPath.row];
        [weakSelf showInvestDetailViewController:source.p2cModel];
        
    } forCellClass:[P2CDataSource cellClass]];
    
    //  MARK:立即投资
    
    [self.tableControl attachTailAction:^(id object, id target, NSIndexPath *indexPath) {
        User *user = [User sharedUser];
        
        NSIndexPath *path = [weakSelf.tableView indexPathForCell:(UITableViewCell *)object];
        
        HTCircleView *circleView = (HTCircleView *)target;
        
        if (1 == circleView.persent) {
            
            P2CDataSource *source = [weakSelf.tableControl.sources objectAtIndex:path.row];
            [weakSelf showInvestDetailViewController:source.p2cModel];
            
        }else {
            
            //  已经登录
            if (user.isLogin) {

                if ([user isUserLoginOutTime]){
                    //  显示手势界面
                    [weakSelf presentGestureViewController];
                }else {
                    [weakSelf showInvestViewController:path];
                    // 友盟点击 立即投资  成功进入页面数量统计
                    [weakSelf clickPromptInVestNumber];
                }
                
            }else {
                //  打开投资界面
                [weakSelf presentUserLoginViewController];
            }
            
        }
        
        
    } forCellClass:[P2CDataSource cellClass]];
    
    [self.tableControl setLoadMoreActionBlock:^(id obj, id target, NSIndexPath *indexPath ) {
        [weakSelf requestInvestList];
        
    }];
    
    //  网络请求失败后，单击重新加载
    [self.loadingStateView setTouchBlock:^(LoadingStateView *stateView, LoadingState state){
        [weakSelf requestInvestList];
    }];
    
    //  刷新网络状态
    [self showLoadingViewWithState:LoadingStateLoading];
    //  请求数据
    [self requestInvestList];
    
    //  登录请求跟用户相关的数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(investDataListRefresh) name:__USER_LOGIN_SUCCESS object:nil];
    
    //  不登陆请求跟用户不相关的数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(investDataListRefresh) name:__USER_LOGINOUT_SUCCESS object:nil];
}

//  如果数据为空，则用户切换视图的时候重新加载
- (void)refreshInvestDataList
{
    //  数据为空，且没有正在加载
    if (self.tableControl.sources.count == 0 &&
        !(self.loadingStateView.loadingState == LoadingStateLoading)) {
        //  刷新网络状态
        if (self.loadingStateView.loadingState != LoadingStateNetworkError) {
            [self showLoadingViewWithState:LoadingStateLoading];
            
            [self requestInvestList];
        }
    }
}

// MARK:友盟点击 立即投资  成功进入页面数量统计
- (void)clickPromptInVestNumber
{
   [MobClick event:@"promptInvest"];
}

/* 
    因为理财列表页包含用户相关的专享项目，
    所以理财列表页在用户登陆后，
    会对每次请求做一个ak校验 ,
    一旦校验失败需要用户重新登录
 */

- (void)investDataListRefresh
{
    if (self.tableControl.sources.count == 0) {
        [self showLoadingViewWithState:LoadingStateLoading];
    }
    
    [self requestNewestData];
}

- (void)viewDidLayoutSubviews
{
    self.showRefreshHeaderView = YES;
    
    // add footerView and Header View
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *headerView = [[UIView alloc] init];
    headerView.height = 5.0f;
    self.tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] init];
    footerView.height = 54.0f;
    self.tableView.tableFooterView = footerView;
}

- (void)refreshViewBeginRefresh:(MJRefreshBaseView *)baseView
{
    [self requestNewestData];
}

- (void)willChangePromptView
{
    self.loadingStateView.promptStr = @"暂无理财项目";
}

- (void)requestNewestData
{
    self.tableControl.pageNum = 1;
    self.tableControl.loadMoreCell.cellState = CellStateReadyLoad;
    self.tableControl.shouldLoadMore = YES;
    [self requestInvestList];
}

- (void)requestInvestList
{
    HTBaseRequest *request = [HTBaseRequest requestWithURL:[self projectListRequestURL]];
    
    [request addGetValue:@(-1) forKey:@"type"];
    [request addGetValue:@(self.tableControl.pageSize) forKey:@"page_size"];
    [request addGetValue:@(self.tableControl.pageNum) forKey:@"page"];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self endRefresh];
        [self removeLoadingView];
        
        NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
        
        if (result) {
            [self handleResponseData:result];
        }
        
    } failure:^(YTKBaseRequest *request) {
        if (self.tableControl.sources.count == 0) {
            [self.view bringSubviewToFront:self.loadingStateView];
            [self showLoadingViewWithState:LoadingStateNetworkError];
        }else {
            //  加载更多
            self.tableControl.loadMoreCell.cellState = CellStateLoadingError;
            
        }
        
        [self endRefresh];
    }];

}

- (NSString *)datasKey
{
    return @"loans";
}

- (void)handleResponseData:(NSDictionary *)dic
{
    self.tableControl.pageNum++;
    
    NSArray *loans = [dic arrayForKey:[self datasKey]];
    if (loans.count == 0 && self.tableControl.sources.count == 0) {
        //  没有数据的情况
        [self showLoadingViewWithState:LoadingStateNoneData];
        return;
    }
    
    if (loans.count < self.tableControl.pageSize) {
        self.tableControl.shouldLoadMore = NO;
        self.tableControl.loadMoreCell.cellState = CellStateHaveNoMore;
    }else {
        
        self.tableControl.loadMoreCell.cellState = CellStateReadyLoad;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.tableControl.sources];
    if (self.tableControl.pageNum == 2) {
        array = [NSMutableArray array];
    }
    
    for (int i = 0; i < loans.count; i++) {
        NSDictionary *loan = [loans objectAtIndex:i];
        P2CDataSource *source = [[P2CDataSource alloc] init];
        source.isRedeem = self.isRedeem;
        source.cellSelectionStyle = UITableViewCellSelectionStyleNone;
        source.p2cModel = [[P2CCellModel alloc] init];

        [self parseProjectDic:loan andPaseModel:source.p2cModel];
        
        [array addObject:source];
    }
    
    self.tableControl.sources = array;
    
    [self.tableView reloadData];
}

- (void)parseProjectDic:(NSDictionary *)dic  andPaseModel:(P2CCellModel *)model
{
    [model parseWithDictionary:dic];
}

- (NSString *)investAccount:(NSString *)investID
{
    return [NSString investAccount:investID];
}

- (void)showInvestViewController:(NSIndexPath *)indexPath
{
    P2CDataSource *source = [self.tableControl.sources objectAtIndex:indexPath.row];
    InvestViewController *invest = [[InvestViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    invest.detailModel = source.p2cModel;
    invest.isRedeem = self.isRedeem;
    
    HTNavigationController *nav = [[HTNavigationController alloc] initWithRootViewController:invest];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showInvestDetailViewController:(P2CCellModel *)model
{
    InvestMarketDetailController *invest = [[InvestMarketDetailController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    invest.detailModel = model;
    invest.isRedeem = self.isRedeem;
    invest.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:invest animated:YES];
}

@end
