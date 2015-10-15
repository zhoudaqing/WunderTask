//
//  InvestMarketDetailController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvestMarketDetailController.h"
#import "InvesetDetailHeaderView.h"
#import "Buttons.h"
#import "InvestTargetDetailController.h"
#import "InvestViewController.h"
#import "HTNavigationController.h"
#import "WillInvestProjects.h"
#import "NSString+Size.h"
#import "InvestDetailModel.h"
#import "InvestTargetPersonlController.h"
#import "NSDate+BFExtension.h"
#import "InvestDetailTitleCell.h"
#import "MobClick.h"
#import "UIView+Layer.h"
#import "InvestListViewController.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"

@interface InvestMarketDetailController ()

@property (nonatomic, strong)   NSArray *functionTitles;
@property (nonatomic, strong)   InvesetDetailHeaderView *headerView;
@property (nonatomic, strong)   UIButton *investButton;
@property (nonatomic, assign)   NSTimeInterval timeLeft;
@property (nonatomic, strong)   NSTimer *refreshTimer;
@property (nonatomic, strong)   NSDictionary *responseDic;

//  投资详情的数据模型
@property (nonatomic, strong)   InvestDetailModel *investDetailModel;

//  用户单击了那个信息列表
@property (nonatomic, strong)   NSIndexPath *numIndexPathClicked;

@end

@implementation InvestMarketDetailController

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_refreshTimer invalidate];
    _refreshTimer = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_responseDic) {
        [self changeLeftTime:_responseDic];
    }
    
    //  刷新投资按钮状态
    [self refreshInvestButton];
    
    [self refreshTableHeaderView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showRefreshHeaderView = YES;

    //  init headerView
    InvesetDetailHeaderView *headerView = [InvesetDetailHeaderView xibView];
    self.tableView.tableHeaderView = headerView;
    _headerView = headerView;
    
    //  init footerView
    UIView *footView = [[UIView alloc] init];
    footView.height = 49.0f;
    self.tableView.tableFooterView = footView;
    
    [self.view addSubview:self.investButton];
    
    //  refresh headerView data
    if (self.projectID.length) {
        [self showLoadingViewWithState:LoadingStateLoading];
        self.loadingStateView.backgroundColor = [UIColor jd_backgroudColor];
        
        _detailModel = [[P2CCellModel alloc] init];
        _detailModel.loanID = self.projectID;
        
        [self investDetailRequestShowHud:NO];
        
    }else {
        [self refreshTableHeaderView];
        
        [self.refreshHeaderView beginRefreshing];
        
        [self refreshInvestButton];
    }
    
    __weakSelf;
    [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state){
        [weakSelf investDetailRequestShowHud:NO];
    }];
    
    //项目详情分享按钮
    UIBarButtonItem *rechangeBtn = [[UIBarButtonItem alloc] initWithTitle:@"分享 " style:UIBarButtonItemStylePlain target:self action:@selector(shareProject)];
    rechangeBtn.tintColor = HTWhiteColor;
    
    [self.navigationItem setRightBarButtonItem:rechangeBtn];

}

- (void)shareProject
{
    NSString *url, *content;
    if (self.isRedeem) {
        url = [NSString stringWithFormat:@" https://m.jiandanlicai.com/project/detail/%@?transfer=1",_detailModel.rid];
        NSString *month;
        if ([_detailModel.leftMonth intValue] == 0) {
            month = @"";
        }else
        {
            month = [NSString stringWithFormat:@"%@个月",_detailModel.leftMonth];
        }
        content = [NSString stringWithFormat:@"简单理财网【%@】——年化收益%@%%，项目期限%@%@天",_detailModel.projectTitle,_detailModel.annualize,month,_detailModel.leftDays];
    }else
    {
        url = [NSString stringWithFormat:@"https://m.jiandanlicai.com/project/detail/%@",_detailModel.projectPid];
        content = [NSString stringWithFormat:@"简单理财网【%@】——年化收益%@，项目期限%@",_detailModel.projectTitle,_detailModel.annualize,_detailModel.returnCycleDescription];
    }
    
    [UMSocialQQHandler setQQWithAppId:QQAppId appKey:QQAppKey url:url];
    [UMSocialData defaultData].title = @"简单理财网";
    [UMSocialData defaultData].extConfig.qqData.shareImage = [UIImage imageNamed:@"app_icon"];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UMengShareAppKey
                                      shareText:[NSString stringWithFormat:@"%@%@",content,url]
                                     shareImage:nil
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,nil]
                                       delegate:nil];
}

- (void)refreshInvestButton
{
    if (_detailModel.invesetPersent == 1.0) {
        self.investButton.enabled = NO;
        self.investButton.alpha = .8;
    }
}

//  MARK:reLayout headerView
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    _headerView.height = 361;
    self.tableView.tableHeaderView = _headerView;
    
    //  投资按钮
    self.investButton.frame = CGRectMake(0, self.view.height - 49, self.view.width, 49);
    [self.view bringSubviewToFront:self.investButton];
}

//  MARK:下拉刷新
- (void)refreshViewBeginRefresh:(MJRefreshBaseView *)baseView
{
    [self investDetailRequestShowHud:NO];
}

- (NSString *)requestURL
{
    if (_isRedeem) {
        return [NSString redeemDetail:_detailModel.loanID];
    }
    
    return [NSString investDetail:_detailModel.loanID];
}

//  MARK:详情数据接口
- (void)investDetailRequestShowHud:(BOOL)show
{
    HTBaseRequest *request = [HTBaseRequest requestWithURL:[self requestURL]];
    
    if (show) {
        //  用户在没有获取到项目信息的时候单击了, 项目信息，企业信息， 抵押信息，等栏目时候要先请求数据
        [self showHudWaitingView:PromptTypeWating];
    }
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        
        //  停止下拉刷新
        [self endRefresh];
        if (show) {
            [self removeHudInManaual];
        }
        
        NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
        
        if (result) {
            [self removeLoadingView];
            _detailModel.redeemDurrationDate = [result stringIntForKey:@"redeem_month_restriction"];
            _detailModel.rid = [result stringIntForKey:@"rid"];
            [self handleResponseData:result];
            //  MARK:计算剩余时间
            _responseDic = request.responseJSONObject;
            [self changeLeftTime:_responseDic];
            
            if (show) {
                [self showInvestTargetDetailViewController:_numIndexPathClicked];
            }
            
            [self.tableView reloadData];
        }
    } failure:^(YTKBaseRequest *request) {
        
        if (self.projectID.length) {
            [self showLoadingViewWithState:LoadingStateNetworkError];
        }
        
        [self endRefresh];
    }];
    
}

- (void)changeLeftTime:(NSDictionary *)dic
{
    if (_detailModel.invesetPersent >= 1.0f) {
        [_headerView setTimeLeft:@"已结束"];
        [_refreshTimer invalidate];
        _refreshTimer = nil;
        
        return;
    }
    
    NSDictionary *result = [dic dictionaryForKey:@"result"];
    NSString *onlineEnd = [result stringForKey:@"online_end_time"];
    NSString *serverTime = [dic stringForKey:@"server_time"];
    NSTimeInterval serverTimeInt = [serverTime doubleValue];
    
    NSDate *date = [NSDate dateWithString:onlineEnd format:nil];

    NSTimeInterval dateInt = [date timeIntervalSince1970];
    
    if (serverTimeInt >= dateInt) {
        //(时间到了，但是还没有满标)
        [_headerView setTimeLeft:@"即将结束"];

    }else {
        
        NSTimeInterval left = dateInt - serverTimeInt;
        _timeLeft = left;
        [_headerView setTimeLeft:[self caluateTimeLeft:left]];
        
        if (!_refreshTimer) {
            _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshTimerAction:) userInfo:nil repeats:YES];
        }
    }
}

- (NSString *)caluateTimeLeft:(NSTimeInterval)left
{
    NSTimeInterval daySecond = 24 * 60 * 60;
    NSTimeInterval hourSecond = 60 * 60;
    NSTimeInterval miniteSecond = 60;
    
    int day = left / daySecond;
    int hour = (left - day * daySecond) / hourSecond;
    int minite = (left - day *daySecond - hour * hourSecond) / miniteSecond;
    
    NSString *dayStr = @"";
    NSString *hourStr = @"";
    NSString *miniteStr = @"";
    
    if (day > 0) {
        dayStr = HTSTR(@"%d天", day);
    }
    
    if (hour > 0) {
        hourStr = HTSTR(@"%d小时", hour);
    }
    
    if (minite > 0) {
        miniteStr = HTSTR(@"%d分", minite);
    }
    
    return HTSTR(@"%@%@%@", dayStr, hourStr, miniteStr);
}

- (void)refreshTimerAction:(NSTimer *)timer
{
    static NSInteger lastMinite;
    __weakSelf;
    if (lastMinite == 0) {
        lastMinite = [weakSelf nowMinite];
    }
    
    NSInteger nowMinite = [weakSelf nowMinite];
    
    if (nowMinite != lastMinite) {
        weakSelf.timeLeft -= 60.0f;
        NSString *timeLeft = [weakSelf caluateTimeLeft:weakSelf.timeLeft];
        [weakSelf.headerView setTimeLeft:timeLeft];
        lastMinite = nowMinite;
    }
}

- (NSInteger)nowMinite
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags =
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *cps = [calendar components:unitFlags fromDate:[NSDate date]];
    
    return cps.minute;
}

- (void)handleResponseData:(NSDictionary *)result
{
    if (!_investDetailModel) {
        _investDetailModel = [[InvestDetailModel alloc] init];
        _investDetailModel.detailModel = _detailModel;
    }
    
    if (_isRedeem) {
        [_investDetailModel parseWithRedeemDic:result];
    }else {
        
        if (self.projectID.length) {
            [_detailModel parseInvestDetailDic:result];
            [_detailModel parseWithDictionary:result];
            
        }
        
        [_investDetailModel parseWithDictionary:result];
    }
    
    [self refreshTableHeaderView];
    
    [self refreshInvestButton];
}

//  投资
- (void)investButtonClicked:(UIButton *)button
{
    User *user = [User sharedUser];
    
    if (user.isLogin) {
        
        if ([user isUserLoginOutTime]) {
            [self presentGestureViewController:self];
            
        }else {
            [self presentInvestViewController];
            // 友盟详情页面 立即投资  成功进入页面数量统计
            [self clickDescibInVestNumber];
        }
        
    }else {
        [self presentUserLoginViewController:self];
        
    }
}

// MARK:友盟详情页面 立即投资  成功进入页面数量统计
- (void)clickDescibInVestNumber
{
    [MobClick event:@"describInvest"];
}

//  MARK:显示投资页面
- (void)presentInvestViewController
{
    InvestViewController *invest = [[InvestViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    invest.detailModel = _detailModel;
    invest.isRedeem = self.isRedeem;
    HTNavigationController *nav = [[HTNavigationController alloc] initWithRootViewController:invest];
    
    [self presentViewController:nav animated:YES completion:nil];
}

//  刷新TableHeaderView
- (void)refreshTableHeaderView
{
    [_headerView setTitleStr:[_detailModel projectTitle]];
    [_headerView setPersent:_detailModel.invesetPersent];
    [_headerView setAnnualize:_detailModel.annualize];
    if (_isRedeem) {
        NSString *month = @"";
        if ([_detailModel.leftMonth integerValue] > 0) {
            month = _detailModel.leftMonth;
            month = HTSTR(@"%@个月", month);
        }
        
        if ([_detailModel.leftDays integerValue] > 0) {
            [_headerView setReturnCycle:HTSTR(@"%@%@天", month, _detailModel.leftDays)];
        }else {
            [_headerView setReturnCycle:month];
        }
        
    }else {
        [_headerView setReturnCycle:_detailModel.returnCycleDescription];
    }
    
    [_headerView setInvesetMoney:[_detailModel.unfinishMoney formatNumberString]];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.functionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray *)self.functionTitles[section]).count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.01f;
    }
    
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == _functionTitles.count - 1) {
        return 10.0f;
    }
    
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"investDetailIdentifier";
    
    InvestDetailTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[InvestDetailTitleCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [self titleAtIndex:indexPath];
    
    if (indexPath.section > 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.detailTextLabel.text = nil;
        
    }else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = [self detailAtIndex:indexPath];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
        return;
        
    }else if (indexPath.section == 1) {
        
        [self showInvestTargetDetailViewController:indexPath];
        return;
        
    }else if((_detailModel.loanType == LoanTypeShengXin) && (indexPath.section == self.functionTitles.count - 1)) {
        WillInvestProjects *project = [[WillInvestProjects alloc] initWithTableViewStyle:UITableViewStyleGrouped];
        project.title = _functionTitles[indexPath.section][indexPath.row];
        [self.navigationController pushViewController:project animated:YES];
    }else
    {
        InvestListViewController *listVC = [[InvestListViewController alloc]init];
        listVC.detailModel = _detailModel;
        [self.navigationController pushViewController:listVC animated:YES];
    }
}
 
- (void)showInvestTargetDetailViewController:(NSIndexPath *)indexPath
{
    if (!_investDetailModel) {
        _numIndexPathClicked = indexPath;
        [self investDetailRequestShowHud:YES];
        return;
    }
    
    UIViewController *viewController = nil;
    if (_investDetailModel.personalModel && indexPath.row == 2) {
        //  个人信息
        InvestTargetPersonlController *target = [[InvestTargetPersonlController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
        target.detailModel = _investDetailModel;
        viewController = target;
        
    }else {
        //  其它信息
        InvestTargetDetailController *target = [[InvestTargetDetailController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
        viewController = target;
        NSInteger index = indexPath.row;
        
        target.investDetailModel = _investDetailModel;
        
        if (index == 0) {
            target.type = DetailTypeNormal;
        }else if (index == 1) {
            target.type = DetailTypeFengKeng;
        }else if (index == 2){
            target.type = DetailTypeQIYE;
        }else {
            target.type = DetailTypeDIYa;
        }
    }

    viewController.title = _functionTitles[indexPath.section][indexPath.row];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark Config

- (NSString *)titleAtIndex:(NSIndexPath *)indexPath
{
    return self.functionTitles[indexPath.section][indexPath.row] ;
}

- (NSString *)detailAtIndex:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            NSString *str;
            if (self.isRedeem) {
                str = [[_detailModel.transFee formatNumberString] stringByAppendingString:@"元"];
                
            }else{
                str = [[_detailModel.investMoney formatNumberString] stringByAppendingString:@"元"];
            }
            return str;
        }
        case 1: return _detailModel.repayType;
        case 2: return _detailModel.warrent;
        default: return @"数据错误";
    }
}

- (NSArray *)functionTitles
{
    NSString *browerMessage = _investDetailModel.personalModel ? @"个人信息" : @"企业信息";
    //  候选项目
    NSArray *willInvest = nil;
    NSString *diYa = @"抵押信息";
    if (_detailModel.loanType == LoanTypeShengXin) {
        willInvest = @[@"候选项目"];
        diYa = nil;
    }
    
    NSString *str;
    if (self.isRedeem == YES) {
        str = @"出让金额:";
        
    }else{
        str = @"项目金额:";
    }
    
    NSArray *secondSectionArray = [NSArray arrayWithObjects:@"项目信息", @"风控信息", browerMessage, diYa, nil];
    
    _functionTitles = [NSArray arrayWithObjects:@[str, @"回款方式:", @"担  保  方:"], secondSectionArray, @[@"投资列表"],willInvest, nil];
    return _functionTitles;
}

- (UIButton *)investButton
{
    if (!_investButton) {
        _investButton = [Buttons buttonWithTitle:@"立即投资" andTarget:self andSelector:@selector(investButtonClicked:)];
    }
    
    return _investButton;
}

#pragma mark - 

- (NSString *)title
{
    return @"项目详情";
}

@end
