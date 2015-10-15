//
//  RedeemingViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/7/14.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "RedeemingViewController.h"
#import "RedeemingViewCell.h"

@interface RedeemingViewController ()<MJRefreshBaseViewDelegate>
{
    int _last_page, _current_page;
}

@property (nonatomic) MJRefreshFooterView *footer;

@property (nonatomic) NSMutableArray *mArray;

@end

@implementation RedeemingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weakSelf;
    [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state){
        [weakSelf setNetWork];
    }];
    
    [self showLoadingViewWithState:LoadingStateLoading];
    
    self.footer.scrollView =  self.tableView;
    _current_page  = 1;
    [self setNetWork];
}

- (void)setNetWork
{
    HTBaseRequest *request = [HTBaseRequest requestWithURL:[NSString redeemingRcord]];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self removeLoadingView];
        NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
        if (result) {
            _last_page = [result[@"last_page"] intValue]+1;
            NSArray *array  = result[@"data"];
            [self.mArray addObjectsFromArray:array];
            if (array.count == 0) {
                [self showLoadingViewWithState:LoadingStateNoneData];
            }
            array = nil;
            [self.tableView reloadData];
        }
        
    } failure:^(YTKBaseRequest *request) {
        
        [self showLoadingViewWithState:LoadingStateNetworkError];
        
        
    }];
    
}

// MARK: 上啦加载更多
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView;
{
    if (_current_page <  _last_page) {
        HTBaseRequest *request = [HTBaseRequest requestWithURL:[self loadMoreSurl]];
        [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            [self.footer endRefreshing];
            NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
            if (result) {
                _last_page = [result[@"last_page"] intValue] + 1;
                NSArray *array = result[@"data"];
                [self.mArray addObjectsFromArray:array];
                array   = nil;
                [self.tableView  reloadData];
            }
            
        } failure:^(YTKBaseRequest *request) {
            
            [self showHudErrorView:PromptTypeError];
            
        }];
    }else
    {
        [self.footer endRefreshing];
        [self showHudAuto:@"没有更多数据了"];
    }
}

- (void)willChangePromptView
{
    self.loadingStateView.promptStr = @"没有投资数据";
}

// MARK: 计算下拉Url
- (NSString  *)loadMoreSurl
{
    _current_page++;
    NSString *url = [NSString stringWithFormat:@"%@?&page=%d",[NSString redeemingRcord],_current_page];
    return url;
}
- (MJRefreshFooterView *)footer
{
    if (!_footer) {
        _footer = [[MJRefreshFooterView alloc]init];
        _footer.delegate = self;
    }
    return _footer;
}

- (NSMutableArray *)mArray
{
    if (!_mArray) {
        _mArray = [[NSMutableArray alloc]init];
    }
    return _mArray;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.footer removeFromSuperview];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return self.mArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    RedeemingViewCell *cell = [[RedeemingViewCell alloc] init];
    NSDictionary *dict = self.mArray[indexPath.section];
    cell.abstractLable.text = [NSString stringWithFormat:@"%@%@",[dict stringForKey:@"pro_type"],[dict stringIntForKey:@"pid"]];
    
    cell.timeLable.text = [NSString stringWithFormat:@"于%@认购",[dict stringForKey:@"invest_date"]];
    cell.moneyLable.text = [NSString stringWithFormat:@"待收本金：%@元 ",[dict stringFloatForKey:@"invest_fee"]];
    cell.interestLable.text = [NSString stringWithFormat:@"利息：%@元",[dict stringFloatForKey:@"interest"]];
    
    cell.divestMoneyLable.text = [NSString stringWithFormat:@"出让金额：%@元",[dict stringFloatForKey:@"transfer_fee"]];
    cell.yieldLable.text = [NSString stringWithFormat:@"%@%%",[dict stringFloatForKey:@"money_rate"]];
    
    cell.expectMoneyLable.text = [NSString  stringWithFormat:@"预期赎回:%@元", [dict stringFloatForKey:@"redeem_fee"]];
    
    cell.returnTimeLable.text = [NSString stringWithFormat:@"于%@成功赎回",[dict stringForKey:@"publish_time"]];
    
    cell.payOffLable.text = [NSString stringWithFormat:@"还款期数%@/%@",[dict stringIntForKey:@"repayment_finish_mon"],[dict stringIntForKey:@"repayment_deadline"]];
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 152.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *rimline = [Sundry rimLine];
    return rimline;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableView *)tableViewWithStyle:(UITableViewStyle)tableViewStyle
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStyleGrouped];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.frame = self.view.frame;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        //  去掉空白多余的行
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    return _tableView;
}


@end
