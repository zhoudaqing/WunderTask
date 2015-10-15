//
//  InvestingTableViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/2.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvestingTableViewController.h"
#import "InvestingTableViewCell.h"
#import "ReturnMoneyDetailViewController.h"
#import "RedeenModel.h"

@interface InvestingTableViewController ()<MJRefreshBaseViewDelegate,ReturnMoneyDetailDelegate>
{
    int _last_page, _current_page;
}
@property (nonatomic) MJRefreshFooterView *footer;

@property (nonatomic) NSMutableArray *mArray;

@property (nonatomic, strong)RedeenModel *redeenModel;

@end

@implementation InvestingTableViewController

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
}

- (void)setNetWork
{
    HTBaseRequest *request = [HTBaseRequest requestWithURL:self.url];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self removeLoadingView];
        NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
        if (result) {
            _last_page = [result[@"last_page"] intValue]+1;
            NSArray *array  = result[@"projects"];
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
            NSArray *array = result[@"projects"];
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
    NSString *url = [NSString stringWithFormat:@"%@&&page=%d",self.url,_current_page];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.footer.scrollView =  self.tableView;
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
    
    
    InvestingTableViewCell *cell = [[InvestingTableViewCell alloc] init];
    NSDictionary  *dict = self.mArray[indexPath.section];
    if ([[dict stringIntForKey:@"rid"] intValue] > 0) {
        cell.isRedeem = YES;
    }else
    {
        cell.isRedeem = NO;
    }
    cell.abstractLable.text = [NSString stringWithFormat:@"%@%@",[dict stringForKey:@"pro_type"],[dict stringIntForKey:@"pid"]];
    cell.timeLable.text = [NSString stringWithFormat:@"于%@认购",[dict stringForKey:@"invest_date"]];
    cell.moneyLable.text = [NSString stringWithFormat:@"%@元",[dict stringFloatForKey:@"invest_fee"]];
    cell.yieldLable.text = [NSString stringWithFormat:@"%@%%",[dict stringFloatForKey:@"money_rate"]];
    
    NSString *yuqi;
    switch (self.i) {
        case 0:
            yuqi = @"预期收益 ";
            break;
        case 1:
            yuqi = @"预期收益 ";
            break;
        default:
            yuqi = @"收益 ";
            break;
    }
    
    cell.expectMoneyLable.text = [NSString  stringWithFormat:@"%@%@元",yuqi,[dict stringFloatForKey:@"total_income"]];
    
    cell.returnTimeLable.text = [self createStringWithstring:[NSString stringWithFormat:@"%@",[dict stringForKey:@"next_repayment_day"]] with:1];
    
    cell.payOffLable.text =[self createStringWithstring:[NSString stringWithFormat:@"%@/%@",[dict stringIntForKey:@"repayment_finish_mon"],[dict stringIntForKey:@"repayment_deadline"]] with:0];
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 135.0f;
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
    ReturnMoneyDetailViewController *returnMoreVC = [[ReturnMoneyDetailViewController alloc]init];
    NSDictionary *dict = self.mArray[indexPath.section];
    [self.redeenModel setContentWithDic:dict];
    self.redeenModel.i = self.i;
    returnMoreVC.delegate  = self;
    returnMoreVC.redeenModel = self.redeenModel;
    [self.navigationController pushViewController:returnMoreVC animated:YES];
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

- (void)selfDissMiss
{
    if ((self.redeenModel.i == 0 && self.redeenModel.can_redeem)) {
        __weakSelf;
        [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state){
            [weakSelf setNetWork];
        }];
        
        [self showLoadingViewWithState:LoadingStateLoading];
        
        self.footer.scrollView =  self.tableView;
        _current_page  = 1;
        self.mArray = nil;
        [self setNetWork];
    }
}

// 判断显示字符
- (NSString *)createStringWithstring:(NSString *)string with:(int)i
{
    NSString *returnDate,  *returnStatus;
    switch (self.i) {
        case 0:
            returnDate = [NSString stringWithFormat:@"将于%@完成下次回款",string];
            returnStatus = [NSString stringWithFormat:@"还款中%@",string];
            break;
        case 1:
            returnDate = @"回款日期未定";
            returnStatus = [NSString stringWithFormat:@"未满%@",string];
            break;
        default:
            returnDate = [NSString stringWithFormat:@"已完成全部回款"];
            returnStatus =[NSString stringWithFormat:@"已还清%@",string];
            break;
    }
    if (i==1) {
        return returnDate;
    }
    return returnStatus;
}

- (RedeenModel *)redeenModel
{
    if (!_redeenModel) {
        _redeenModel = [[RedeenModel alloc]init];
    }
    return _redeenModel;
}

@end
