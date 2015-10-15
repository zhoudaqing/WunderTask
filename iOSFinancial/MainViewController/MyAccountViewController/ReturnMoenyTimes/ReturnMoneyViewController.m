//
//  ReturnMoneyViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "ReturnMoneyViewController.h"
#import "AttributedLabel.h"
#import "ReturnMoneyTableViewCell.h"
#import "ReturnMoneyDetailViewController.h"

@interface ReturnMoneyViewController () <MJRefreshBaseViewDelegate>
{
    AttributedLabel *_cellContentLable, *_cellMoneyLanle;
    int _current_page, _last_page;
}

@property (nonatomic) MJRefreshFooterView *footer;

@property (nonatomic) NSMutableArray *mArray;

@end

@implementation ReturnMoneyViewController

- (void)dealloc
{
    [_footer free];
    _footer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.footer.scrollView =  self.tableView;
    
    __weakSelf;
    [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state){
        [weakSelf refreshViewBeginRefreshing:nil];
    }];
    
    [self showLoadingViewWithState:LoadingStateLoading];
    
    _current_page  = 1;
    _last_page = 2;
    
    [self refreshViewBeginRefreshing:nil];

}


// MARK: 上啦加载更多
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView;
{
    if (_current_page <  _last_page) {
        HTBaseRequest *request = [HTBaseRequest requestWithURL:[self loadMoreSurl]];
        [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            [self.footer endRefreshing];
            [self removeLoadingView];
            NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
            if (result) {
                _last_page = [result[@"last_page"] intValue] + 1;
                NSArray *array = result[@"data"];
                [self.mArray addObjectsFromArray:array];
                
                if (array.count == 0) {
                    [self showLoadingViewWithState:LoadingStateNoneData];
                }
                
                array   = nil;
                _current_page++;
                [self.tableView  reloadData];
            }
            
        } failure:^(YTKBaseRequest *request) {
            
            [self showLoadingViewWithState:LoadingStateNetworkError];
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
    if (_current_page == 1) {
        return [NSString investorReback];
    }
    NSString *url = [NSString stringWithFormat:@"%@?page=%d",[NSString investorReback],_current_page];
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

#pragma -TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.mArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ReturnMoneyIdentifier";
    NSDictionary *dict = self.mArray[indexPath.section];
        switch (indexPath.row) {
            case 0:
            {
                HTBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                if (!cell) {
                    cell = [[HTBaseCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.textLabel.text = [self dateWith:dict[@"reback_date"]];
                return cell;

            }
                
            case 1:
            {
                ReturnMoneyTableViewCell *cell = [[ReturnMoneyTableViewCell alloc]init];
                [cell setCellContentLableWithString:dict[@"description"]];
                return cell;

            }
            default:
            {
                ReturnMoneyTableViewCell *cell = [[ReturnMoneyTableViewCell alloc]init];
                [cell setCellMoneyLanleWithSring:[NSString stringWithFormat:@"金额:%.2f元",[[dict stringFloatForKey:@"reback_interest"] doubleValue] + [[dict stringForKey:@"reback_capital"] doubleValue]]];
                return cell;
            }
        }

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

- (NSString *)dateWith:(id)sender
{
    NSString *str = [NSString stringWithFormat:@"%@",sender];
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* inputDate = [inputFormatter dateFromString:str];
    [inputFormatter setDateFormat:@"yyyy年MM月dd日"];
    str = [inputFormatter stringFromDate:inputDate];
    return str;
}

@end
