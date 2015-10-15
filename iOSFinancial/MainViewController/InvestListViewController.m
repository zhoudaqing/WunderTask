//
//  InvestListViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/7/15.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvestListViewController.h"
#import "InvestListViewCell.h"

@interface InvestListViewController ()
{
    int _pageNumber, _lastPageNumber;
}

@property (nonatomic) NSMutableArray *investListArray;

@property (nonatomic,copy)NSString *ridOrPid;

@end

@implementation InvestListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"投资列表";
    self.tableView.backgroundColor = [UIColor jd_backgroudColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 判断是否是赎回项目
    if ([self.detailModel.rid isEqual:@""]) {
        
        self.baseUrl = [NSString investRecord];
        self.ridOrPid = self.detailModel.projectPid;
        
    }else
    {
        self.baseUrl = [NSString redeemsInvestRecord];
        self.ridOrPid = self.detailModel.rid;
    }

    
    __weakSelf;
    [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state){
     
            [weakSelf refreshViewBeginRefresh:nil];
    }];
    
    [self showLoadingViewWithState:LoadingStateLoading];
    self.loadingStateView.backgroundColor = [UIColor jd_backgroudColor];
    
    self.showRefreshFooterView = YES;
    
    _pageNumber = 1;
    _lastPageNumber = 2;
    self.tableView.tableFooterView = nil;
    [self refreshViewBeginRefresh:nil];
}

// MARK: 上啦加载更多
- (void)refreshViewBeginRefresh:(MJRefreshBaseView *)baseView
{
    
    //-----------------------投资记录
    if (_pageNumber <  _lastPageNumber) {
        
        HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString stringWithFormat:@"%@/%@?page=%d&page_size=50", self.baseUrl,self.ridOrPid, _pageNumber]];
        request.shouldShowErrorMsg = NO;
        
        __weakSelf;
        [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            [weakSelf endRefresh];
            [self removeLoadingView];
            NSDictionary *dict = [request.responseJSONObject dictionaryForKey:@"result"];
            if (dict) {
                [weakSelf removeLoadingView];
                [weakSelf handleResponseData:dict];
                [baseView endRefreshing];
            }
            
        } failure:^(YTKBaseRequest *request) {
            [weakSelf showLoadingViewWithState:LoadingStateNetworkError];
            [baseView endRefreshing];
        }];
        
    }else{
        [baseView endRefreshing];
        //        [self showHudAuto:@"没有更多数据了"];
    }
    
}

- (void)handleResponseData:(NSDictionary *)dict
{
    NSArray *array = dict[@"data"];
    
    [self.investListArray addObjectsFromArray:array];
    
    if (self.investListArray.count == 0) {
        [self showLoadingViewWithState:LoadingStateNoneData];
    }
    [self.tableView reloadData];
    
    _pageNumber ++;
    _lastPageNumber = [dict[@"last_page"] intValue]+1;
}

- (void)willChangePromptView
{
    self.loadingStateView.promptStr = @"暂时没有投资数据";
}

- (NSMutableArray *)investListArray
{
    if (!_investListArray) {
        _investListArray = [[NSMutableArray alloc]init];
    }
    return _investListArray;
}

#pragma UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.investListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"accountIdentifier";
    
    InvestListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (!cell) {
        cell = [[InvestListViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                }
    NSDictionary *dict = self.investListArray[indexPath.row];
    cell.timeLable.text = [dict stringForKey:@"invest_date"];
    cell.nameLable.text = [dict stringForKey:@"investor_nick_name"];
    cell.moneyLable.text = [dict stringFloatForKey:@"invest_fee"];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 19.50f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    UILabel *timeLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 7.5, 80, 18)];
    timeLable.text = @"时间";
    timeLable.font = [UIFont systemFontOfSize:15.0];
    [view addSubview:timeLable];
    
    UILabel *nameLable = [[UILabel alloc]initWithFrame:CGRectMake(APPScreenWidth *.5, 7.5, 80, 18)];
    nameLable.text = @"用户";
    nameLable.font = [UIFont systemFontOfSize:15.0];
    [view addSubview:nameLable];
    
    UILabel *moneyLable = [[UILabel alloc]initWithFrame:CGRectMake(APPScreenWidth - 120, 7.5, 105, 18)];
    moneyLable.text = @"金额(元)";
    moneyLable.font = [UIFont systemFontOfSize:15.0];
    moneyLable.textAlignment = NSTextAlignmentRight;
    [view addSubview:moneyLable];
    [view setBackgroundColor:[UIColor jd_backgroudColor]];
    return view;
}


@end
