//
//  WithdrawingViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/30.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "WithdrawingViewController.h"
#import "WithdrawingTableViewCell.h"

@interface WithdrawingViewController ()<MJRefreshBaseViewDelegate>
{
    int _last_page, _current_page;
}
@property (nonatomic) MJRefreshFooterView *footer;

@property (nonatomic) NSMutableArray *array;

@end

@implementation WithdrawingViewController

- (void)dealloc
{
    [_footer free];
}

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
    
    self.tableView.tableFooterView = nil;
}

- (void)setNetWork
{
    HTBaseRequest *request = [HTBaseRequest requestWithURL:[NSString withdrawing]];
    
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self removeLoadingView];
        NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
        if (result) {
            
            NSArray *array = result[@"data"];
            
            if (array.count == 0) {
                [self showLoadingViewWithState:LoadingStateNoneData];
            }
            [self.array addObjectsFromArray:array];
            _last_page = [result[@"last_page"] intValue]+1;
            array = nil;
            [self.tableView reloadData];

        }
        
    } failure:^(YTKBaseRequest *request) {
        [self showLoadingViewWithState:LoadingStateNetworkError];
        [self showHudErrorView:PromptTypeError];

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
                NSArray *array = result[@"data"];
                [self.array addObjectsFromArray:array];
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

// MARK: 计算下拉Url
- (NSString  *)loadMoreSurl
{
    _current_page++;
    NSString *url = [NSString stringWithFormat:@"%@?&page=%d",[NSString withdrawing],_current_page];
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

- (NSMutableArray *)array
{
    if (!_array) {
        _array = [[NSMutableArray alloc]init];
    }
    return _array;
}

- (void)willChangePromptView
{
    self.loadingStateView.promptStr = @"没有提现数据";
}

- (void)handleResponseData:(NSMutableArray *)array
{
    self.array = array;
    
    if (array.count == 0) {
        [self showLoadingViewWithState:LoadingStateNoneData];
    }
    
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.footer removeFromSuperview];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return .01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WithdrawingTableViewCell *cell = [WithdrawingTableViewCell newCell];
    NSDictionary *dict = self.array[indexPath.row];
    cell.time.text = [dict stringForKey:@"apply_date"];
    cell.money.text = [dict stringForKey:@"money"];
    [cell.bankImage setImage:[UIImage imageNamed:[dict stringForKey:@"bank_code"]]];
    cell.userInteractionEnabled = NO;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end
