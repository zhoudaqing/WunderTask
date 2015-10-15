//
//  RedEnvelopeViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/3.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "RedEnvelopeViewController.h"
#import "RedEnvelopCell.h"

@interface RedEnvelopeViewController ()
{
    int _pageNumber, _lastPageNumber;
}

@property (nonatomic) NSArray *titleArray;
// 所获红包
@property (nonatomic) UILabel *getEnvelopeLable;
// 解锁红包
@property (nonatomic) UILabel *clearEnvelopeLable;
// 正在解锁
@property (nonatomic) UILabel *clearingEnvelopeLable;
// 解锁红包描述
@property (nonatomic) UILabel *clearDeitalLable;
// 未解锁红包
@property (nonatomic) UILabel *unclearEnvelopeLable;

@property (nonatomic) NSDictionary *dict;

@property (nonatomic) NSMutableArray *hongbaoArrary;

@property (nonatomic) NSDictionary *hongbaoHead;

@end

@implementation RedEnvelopeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //  init Header
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 160)];
    backView.backgroundColor = [UIColor jd_accountBackColor];
    [self.view addSubview:backView];
    [self.view sendSubviewToBack:backView];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    __weakSelf;
    [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state){
        if (weakSelf.hongbaoHead == nil) {
            [weakSelf loadData];
        }else {
            [weakSelf refreshViewBeginRefresh:nil];
        }
    }];
    
    [self showLoadingViewWithState:LoadingStateLoading];
    self.loadingStateView.backgroundColor = [UIColor jd_backgroudColor];
    [self.view bringSubviewToFront:self.loadingStateView];
    
    self.showRefreshFooterView = YES;
    
    _pageNumber = 1;
    _lastPageNumber = 2;
    [self loadData];
    self.tableView.tableFooterView = nil;
}

// MARK:  红包的总数据
- (void)loadData
{
    __weakSelf;
    HTBaseRequest *request1 = [[HTBaseRequest alloc] initWithURL:[NSString getCashgiftInfo]];
    [request1 startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request1) {
        NSDictionary *result = [request1.responseJSONObject dictionaryForKey:@"result"];
        if (result) {
            weakSelf.hongbaoHead = result;
            [weakSelf refreshViewBeginRefresh:nil];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [weakSelf showLoadingViewWithState:LoadingStateNetworkError];
        [self showHudErrorView:PromptTypeError];
    }];
    
}
// MARK: 上啦加载更多红包
- (void)refreshViewBeginRefresh:(MJRefreshBaseView *)baseView
{
    //-----------------------红包记录
    if (_pageNumber <  _lastPageNumber) {
        
        HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString stringWithFormat:@"%@?page=%d",[NSString getRecorder],_pageNumber]];
        request.shouldShowErrorMsg = NO;
        
        __weakSelf;
        [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            [weakSelf endRefresh];
            
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
    NSArray *array = dict[@"data"][@"hongbao"];
    [self.hongbaoArrary addObjectsFromArray:array];
    
    [self.tableView reloadData];
    
    _pageNumber ++;
    _lastPageNumber = [dict[@"last_page"] intValue]+1;
}

// MARK: HeaderView
- (UIView *)redEnvelopeView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, TransparentTopHeight, APPScreenWidth, 199.0)];
    
    UIView *back = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APPScreenWidth, 106.0)];
    back.backgroundColor  = HTHexColor(0xff6d2f);
    [view addSubview:back];
    
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 25, APPScreenWidth-15, 13)];
    lable.font = [UIFont systemFontOfSize:13.0];
    lable.text = @"未解锁红包";
    lable.textColor = HTWhiteColor;
    [back addSubview:lable];
    
    self.unclearEnvelopeLable.frame = CGRectMake(0, 25, APPScreenWidth-15, 15);
    CGFloat redlocked = [self.hongbaoHead[@"total_cashgift"] doubleValue] - [self.hongbaoHead[@"total_unlocked"] doubleValue];
    self.unclearEnvelopeLable.text = [NSString stringWithFormat:@"%.2f元",redlocked];
    [back addSubview:self.unclearEnvelopeLable];
    
    self.clearDeitalLable.frame = CGRectMake(0, 68, APPScreenWidth-15, 13);
    self.clearDeitalLable.text = [NSString stringWithFormat:@"解锁需要额外投资%@元/12个月",[self.hongbaoHead stringFloatForKey:@"total_invest_to_unlock"]];
    [back addSubview:self.clearDeitalLable];
    
    UIImageView *topRimeLine = [[UIImageView alloc]initWithFrame:CGRectMake(15, 53, APPScreenWidth-30, 1.0)];
    UIImage *image = [UIImage imageNamed:@"RedEenvlopePoint"];
    topRimeLine.backgroundColor = [UIColor colorWithPatternImage:image];
    [view addSubview:topRimeLine];
    
    UIView *bottomBcak = [[UIView alloc]initWithFrame:CGRectMake(0, 96.0, APPScreenWidth, 62)];
    bottomBcak.backgroundColor = HTWhiteColor;
    [view addSubview:bottomBcak];
    
    UIView *bottomLine = [Sundry rimLine];
    bottomLine.frame = CGRectMake(0, bottomBcak.bottom-0.5, APPScreenWidth, .5);
    [view addSubview:bottomLine];
    
    for (int i = 0; i<3; i++) {
        UIView *rimeLine = [Sundry rimLine];
        rimeLine.frame = CGRectMake(i*APPScreenWidth/3, 13, .5, bottomBcak.height-26.0);
        [bottomBcak addSubview:rimeLine];
        
        UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(i*APPScreenWidth/3+15, 13.0, APPScreenWidth/3, 13)];
        titleLable.font = [UIFont systemFontOfSize:13.0];
        titleLable.text = self.titleArray[i];
        titleLable.textColor = [UIColor jd_darkBlackTextColor];
        [bottomBcak addSubview:titleLable];
        
        if (i==0) {
            self.getEnvelopeLable.frame = CGRectMake(i*APPScreenWidth/3, 36, APPScreenWidth/3-15, 13);
            self.getEnvelopeLable.text = [NSString stringWithFormat:@"%@",[self.hongbaoHead stringFloatForKey:@"total_cashgift"]];
            
            [bottomBcak addSubview:self.getEnvelopeLable];
            
        }else if (i ==1){
            
            self.clearEnvelopeLable.frame = CGRectMake(i*APPScreenWidth/3, 36, APPScreenWidth/3-15, 13);
            self.clearEnvelopeLable.text = [NSString stringWithFormat:@"%@",[self.hongbaoHead stringFloatForKey:@"total_unlocked"]];
            [bottomBcak addSubview:self.clearEnvelopeLable];
        }else{
            self.clearingEnvelopeLable.frame = CGRectMake(i*APPScreenWidth/3, 36, APPScreenWidth/3-15, 13);
            self.clearingEnvelopeLable.text = [NSString stringWithFormat:@"%@",[self.hongbaoHead stringFloatForKey:@"total_unlocking"]];
            [bottomBcak addSubview:self.clearingEnvelopeLable];
        }
        
    }
    
    UILabel *redEnveloeRecord = [[UILabel alloc]initWithFrame:CGRectMake((APPScreenWidth-72)/2, bottomBcak.bottom+14.5, 72, 12)];
    redEnveloeRecord.text = @"红包获取记录";
    redEnveloeRecord.font = [UIFont systemFontOfSize:12.0];
    redEnveloeRecord.textColor = [UIColor jd_globleTextColor];
    [view addSubview:redEnveloeRecord];
    
    UIView *lineLeft = [Sundry rimLine];
    lineLeft.frame = CGRectMake(15, redEnveloeRecord.top+6,(APPScreenWidth- 108)/2, 1);
    [view addSubview:lineLeft];
    UIView *lineRight = [Sundry rimLine];
    lineRight.frame = CGRectMake(APPScreenWidth - lineLeft.width - 15 , redEnveloeRecord.top + 6, lineLeft.width, 1);
    [view addSubview:lineRight];
    
    view.backgroundColor = [UIColor jd_backgroudColor];
    
    return view;
    
}

- (NSArray *)titleArray
{
    if (!_titleArray) {
        _titleArray = @[@"所获红包(元)",@"累计解锁(元)",@"正在解锁(元)"];
    }
    return _titleArray;
}

- (UILabel *)getEnvelopeLable
{
    if (!_getEnvelopeLable) {
        _getEnvelopeLable = [[UILabel alloc]init];
        _getEnvelopeLable.textAlignment = NSTextAlignmentRight;
        _getEnvelopeLable.font = [UIFont systemFontOfSize:15.0];
        _getEnvelopeLable .textColor = [UIColor jd_settingDetailColor];
    }
    return _getEnvelopeLable;
}

- (UILabel *)clearEnvelopeLable
{
    if (!_clearEnvelopeLable) {
        _clearEnvelopeLable = [[UILabel alloc]init];
        _clearEnvelopeLable.textAlignment = NSTextAlignmentRight;
        _clearEnvelopeLable.font = [UIFont systemFontOfSize:15.0];
        _clearEnvelopeLable .textColor = [UIColor jd_settingDetailColor];
    }
    return _clearEnvelopeLable;
}

- (UILabel *)clearingEnvelopeLable
{
    if (!_clearingEnvelopeLable) {
        _clearingEnvelopeLable = [[UILabel alloc]init];
        _clearingEnvelopeLable.textAlignment = NSTextAlignmentRight;
        _clearingEnvelopeLable.font = [UIFont systemFontOfSize:15.0];
        _clearingEnvelopeLable .textColor = [UIColor jd_settingDetailColor];
    }
    return _clearingEnvelopeLable;
}

- (UILabel *)unclearEnvelopeLable
{
    if (!_unclearEnvelopeLable) {
        _unclearEnvelopeLable = [[UILabel alloc]init];
        _unclearEnvelopeLable.textAlignment = NSTextAlignmentRight;
        _unclearEnvelopeLable.font = [UIFont systemFontOfSize:15.0];
        _unclearEnvelopeLable .textColor = HTWhiteColor;
    }
    return _unclearEnvelopeLable;
}

- (UILabel *)clearDeitalLable
{
    if (!_clearDeitalLable) {
        _clearDeitalLable = [[UILabel alloc]init];
        _clearDeitalLable.textAlignment = NSTextAlignmentRight;
        _clearDeitalLable.font = [UIFont systemFontOfSize:13.0];
        _clearDeitalLable .textColor = HTWhiteColor;
    }
    return _clearDeitalLable;
}

- (NSMutableArray *)hongbaoArrary
{
    if (!_hongbaoArrary) {
        _hongbaoArrary = [[NSMutableArray alloc]init];
    }
    return _hongbaoArrary;
}

#pragma UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.hongbaoArrary.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"redIdentifier";
    RedEnvelopCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[RedEnvelopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    NSDictionary *dict = self.hongbaoArrary[indexPath.row];
    cell.activityNameLable.text = [dict stringForKey:@"cash_type"];
    cell.timeLable.text = [NSString stringWithFormat:@"%@",[dict stringForKey:@"cash_time"]];
    cell.moneyLable.text = [NSString stringWithFormat:@"%d元",[[dict stringIntForKey:@"cash_money"] intValue]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 199.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self redEnvelopeView];
}

@end
