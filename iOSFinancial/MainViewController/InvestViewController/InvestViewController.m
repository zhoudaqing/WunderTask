//
//  InvestViewController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/28.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvestViewController.h"
#import "InvestHeaderView.h"
#import "InvesetMoneyView.h"
#import "Buttons.h"
#import "RechangeViewController.h"
#import "NSString+Size.h"
#import "UIBarButtonExtern.h"
#import "InvestShareViewController.h"
#import "HTNavigationController.h"

@interface InvestViewController () <UITextFieldDelegate,InvestShareDelegate>

@property (nonatomic, strong)   InvestHeaderView *headerView;
@property (nonatomic, strong)   InvesetMoneyView *investMoneyView;
@property (nonatomic, strong)   UIButton *confirmButton;
@property (nonatomic, strong)   NSTimer *refreshTimer;
@property (nonatomic, strong)   HTBaseRequest *investRequest;
@property (nonatomic, strong)   UILabel *noticeLable;

//  返回的字典
@property (nonatomic, strong)   NSDictionary *resultDic;

//  是否是第一次加载
@property (nonatomic, assign)   BOOL isFirstLoad;

@end

@implementation InvestViewController

- (void)dealloc
{
    if (self.investRequest) {
        [self.investRequest stop];
        self.investRequest = nil;
    }
    
    if (_refreshTimer) {
        [_refreshTimer invalidate];
        _refreshTimer = nil;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /*
    [self runRefreshTimer];
     */
    
    [self requestInvestAccount];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //  不是第一次进入了
    _isFirstLoad = NO;
    
    /*
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
     */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"投资项目";
    
    //  第一次进入
    _isFirstLoad = YES;
    
    self.showRefreshHeaderView = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (self.projectId.length == 0) {
        [self refreshTableHeaderView];
        [self.tableView reloadData];
    }else {
        //  推送过来的消息
        
        [self requestInvestAccount];
        
        [self showLoadingViewWithState:LoadingStateLoading];
        
        self.detailModel = [[P2CCellModel alloc] init];
        self.detailModel.loanID = self.projectId;
    }
    
    [self addKeyboardNotifaction];
     self.navigationItem.rightBarButtonItem = [UIBarButtonExtern buttonWithTitle:@"确定" target:self andSelector:@selector(confirmButtonClicked:)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    
    [self.tableView addGestureRecognizer:tap];
}

- (void)tapGesture
{
    [self.view endEditing:YES];
}

- (void)refreshViewBeginRefresh:(MJRefreshBaseView *)baseView
{
    [self requestInvestAccount];
    
    /*
    [_refreshTimer invalidate];
    _refreshTimer = nil;
    
    [self performSelector:@selector(runRefreshTimer) withObject:nil afterDelay:3.0f];
     */
}

- (void)runRefreshTimer
{
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(refreshTimerAction:) userInfo:nil repeats:YES];
}

//  MARK:定时刷新页面
- (void)refreshTimerAction:(NSTimer *)timer
{
    [self requestInvestAccount];
}

- (NSString *)requestURL
{
    if (_isRedeem) {
        return  [NSString redeemAccount:_detailModel.loanID];
    }
    
    return [NSString investAccount:_detailModel.loanID];
}

//  MARK:请求个人账户数据
- (void)requestInvestAccount
{
    __weakSelf;
    if (weakSelf.investRequest) {
        [weakSelf.investRequest stop];
        weakSelf.investRequest = nil;
    }
    
    HTBaseRequest *request = [HTBaseRequest requestWithURL:[self requestURL]];
    weakSelf.investRequest = request;
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [weakSelf removeHudInManaual];
        [self endRefresh];
        
        NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
        
        if (result) {
            [self removeLoadingView];
            [weakSelf handleResponseData:result];
        }
        
    } failure:^(YTKBaseRequest *request) {
        
        [self showLoadingViewWithState:LoadingStateNetworkError];
        [self endRefresh];
        [weakSelf removeHudInManaual];
    }];
}

- (void)handleResponseData:(NSDictionary *)dic
{
    //  处理推送过来的消息
    if (self.projectId.length > 0) {
        _resultDic = dic;
        
        [self.detailModel parseWithDictionary:dic];
        [self.detailModel parseInvestDetailDic:dic];
        
        [self refreshTableHeaderView];
        [self.tableView reloadData];
    }
    
    _resultDic = dic;
    
    //  钱包
    [_investMoneyView setAvaMoney:[[dic stringFloatForKey:@"balance"] formatNumberString]];
    //  可投金额
    [_headerView setInvesetMoney:[[dic stringIntForKey:@"unfinished"] formatNumberString]];
    
}

#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self confirmButtonClicked:nil];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *changeStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([string isNumber] || isEmpty(string)) {
        //  删除键的时候返回yes
        NSString * inCome = [self inComeInvestConcaluate:changeStr];
        //  设置收益
        [_investMoneyView setInCoMoney:[inCome formatNumberString]];
        
        return YES;
    }
    
    return NO;
}

#pragma mark -

static CGFloat margin = .0f;

- (void)keyboardDidAppear:(NSNotification *)noti withKeyboardRect:(CGRect)rect
{
    
    if (margin > 0) {
        return;
    }
    
    CGFloat investViewBottom = CGRectGetMaxY([self.investMoneyView convertRect:self.investMoneyView.frame toView:self.tableView]);
    
    CGFloat keyboardTop = self.view.height - CGRectGetHeight(rect);
    
    margin = investViewBottom - keyboardTop + 40;
    
    if (margin > .0f) {
        [UIView animateWithDuration:.25 animations:^{
            self.tableView.top -= margin;
        }];
    }
}

- (void)keyboardWillDisappear:(NSNotification *)noti withKeyboardRect:(CGRect)rect
{
    if (margin > .0f) {
        [UIView animateWithDuration:.25 animations:^{
            self.tableView.top += margin;
            margin = 0;
        }];
    }
}

//  刷新TableHeaderView
- (void)refreshTableHeaderView
{
    [self.headerView setTitle:[NSString stringWithFormat:@"%@",_detailModel.projectTitle]];
    [self.headerView setAnnualize:_detailModel.annualize];

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
    
    self.investMoneyView.investMoney.placeholder = HTSTR(@"最少投资金额:%@", _detailModel.min_invest_fee);
    
}

//  MARK:充值按钮事件
- (void)rechangeMoneyButtonClicked
{
    RechangeViewController *recharge = [[RechangeViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    [User sharedUser].isInVestRecharge = YES;
    [self.navigationController pushViewController:recharge animated:YES];
}

//  投资确认事件
- (void)confirmButtonClicked:(UIButton *)button
{
    CGFloat investNum = [_investMoneyView.investMoney.text floatValue];
    CGFloat balanceNum = [[_resultDic stringFloatForKey:@"balance"] floatValue];
    CGFloat unfinishNum = [[_resultDic stringFloatForKey:@"unfinished"] floatValue];
    CGFloat minInvestNum = [_detailModel.min_invest_fee floatValue];
    
    if (investNum > balanceNum) {
        [self showAlert:@"您的账户余额已不足,请充值"];
        
    }else if (investNum > unfinishNum) {
        [self showHudErrorView:@"投资金额不能大于可投金额"];
        
    }else if (investNum < minInvestNum) {
        [self showAlert:HTSTR(@"最小投资金额为%@", _detailModel.min_invest_fee)];
        
    }else {
        //submin
        [self submitInvestRequest];
    }
}

//  投资请求
- (NSString *)requestActionURL
{
    if (_isRedeem) {
        return [NSString redeemAction:_detailModel.loanID];
    }
    
    return [NSString invsetAction:_detailModel.loanID];
}

//  发送投资请求
- (void)submitInvestRequest
{
    CGFloat investNum = [_investMoneyView.investMoney.text floatValue];
    HTBaseRequest *request = [HTBaseRequest requestWithURL:[self requestActionURL]];
    [request addPostValue:[NSNumber numberWithFloat:investNum] forKey:@"money"];
    
    [self showHudWaitingView:PromptTypeWating];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        
        NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"error"];
        if (!result) {
            //  发送账户刷新的通知, 刷新余额
            [[NSNotificationCenter defaultCenter] postNotificationName:__USER_ACCOUNT_REFRESH_NOTIFACTION object:nil];
            
            [self miniseUnfinishMoney];
            [self showHudSuccessView:@"投资成功"];
            NSDictionary *dict = [request.responseJSONObject dictionaryForKey:@"result"];
            [self investShare:dict];
        }
        
    }];
}

- (void)investShare:(NSDictionary *)dict
{
    NSString *url;
    if (self.isRedeem) {
        
        url = [NSString stringWithFormat:@"%@rid=%@",[NSString sharingValidation],_detailModel.rid];
        
    }else
    {
        url = [NSString stringWithFormat:@"%@pid=%@",[NSString sharingValidation],_detailModel.projectPid];
    }
    
    HTBaseRequest *request = [HTBaseRequest requestWithURL:url];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        
        NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
        if (result.count > 0) {
            InvestShareViewController *investShareVc = [[InvestShareViewController alloc]init];
            
            investShareVc.delegate  = self;
            
            investShareVc.ShareDict = dict;
            
            investShareVc.url = [result stringForKey:@"sharing_link"];
            
            HTNavigationController *nav = [[HTNavigationController alloc] initWithRootViewController:investShareVc];
            
            [self presentViewController:nav animated:YES completion:nil];
            
        }
        else
        {
            [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:0.8f];
        }
        
    }];
    
    

}

- (void)selfDissmiss
{
    [self dismissViewControllerAnimated:NO complainBlock:nil];
}

- (void)miniseUnfinishMoney
{
    NSInteger unfinish = [_detailModel.unfinishMoney integerValue];
    unfinish -= [_investMoneyView.investMoney.text integerValue];
    _detailModel.unfinishMoney = HTSTR(@"%ld", (long)unfinish);
}

- (InvestHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [InvestHeaderView xibView];
    }

    return _headerView;
}

- (InvesetMoneyView *)investMoneyView
{
    if (!_investMoneyView) {
        _investMoneyView = [InvesetMoneyView xibView];
        _investMoneyView.investMoney.delegate = self;
        __weakSelf;
        [_investMoneyView setRechargeBlock:^(InvesetMoneyView *investView) {
            [weakSelf rechangeMoneyButtonClicked];
        
        }];
    }
    
    return _investMoneyView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark -  TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 130.0f;
    }
    
    return 112.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 30.0f;
    }
    
    return .01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = HTClearColor;
    if ([_detailModel.redeemDurrationDate isEqualToString:@""] || [_detailModel.redeemDurrationDate isEqualToString:@"0"]) {
        
        
        
    }else if(section == 1){
    self.noticeLable.frame = CGRectMake(15, 10, APPScreenWidth, 20);
    self.noticeLable.text = [NSString stringWithFormat:@"注：该项目%@个月内不可赎回",_detailModel.redeemDurrationDate];
    [view addSubview:self.noticeLable];
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        
        [cell addSubview:self.headerView];
        self.headerView.frame = cell.bounds;
        
    }else {
        [cell addSubview:self.investMoneyView];
        self.investMoneyView.frame = cell.bounds;
    }
   
    return cell;
}

- (UILabel *)noticeLable
{
    if (!_noticeLable) {
        _noticeLable = [[UILabel alloc]init];
        _noticeLable.textColor = [UIColor jd_globleTextColor];
        _noticeLable.font = [UIFont systemFontOfSize:13.0];
    }
    return _noticeLable;
}

#pragma mark - 预期收益计算公式
//  MARK:利息计算方式
- (NSString *)inComeInvestConcaluate:(NSString *)value
{
    CGFloat monthRate = [_detailModel.annualize floatValue] / 12 / 100.0f;
    CGFloat dayRate = [_detailModel.annualize floatValue] / 365 / 100.0f;
    
    NSInteger investDays = 0;
    NSInteger investMonths = 0;
    
    //  总收益
    NSString *inComeTotal = nil;
    
    if (_isRedeem) {
        //  债权
        investDays = [_detailModel.leftDays integerValue];
        investMonths = [_detailModel.leftMonth integerValue];
        
        NSInteger daysInCurrentMonth = [self daysInCurrentMonth];
        
        if ([_detailModel.repayType isEqualToString:kRepayType_Denge]) {
            //  等额本息 (每个月的收益不一样)
            
            NSArray *inComeArray = [self dengEInComes:[value floatValue] andInvestMonth:[_detailModel.returnCycleNum integerValue]];
            
            CGFloat inComeMoney = .0f;
            for (NSNumber *inCome in inComeArray) {
                NSInteger inComeMonth = [inComeArray indexOfObject:inCome];
                
                // 完成的月数
                NSInteger finishMonth = [_detailModel.returnCycleNum integerValue] - investMonths;
                
                if (inComeMonth >= (finishMonth - 1)) {
                    if (inComeMonth >= finishMonth) {
                        //  计算剩余的天数的利息
                        inComeMoney = [inCome floatValue] / daysInCurrentMonth * investDays;
                        
                    }else {
                        //  计算剩余的月数的利息
                        inComeMoney += [inCome floatValue];
                    }
                }
            }
            
            inComeTotal = HTSTR(@"%.3f", inComeMoney);
            
        }else {
            //  每日的收益率
            dayRate = (monthRate / daysInCurrentMonth);
            //  剩余天数的收益 + 剩余月数的收益
            inComeTotal = HTSTR(@"%.3f", dayRate * investDays * [value floatValue] +
                                monthRate * investMonths * [value floatValue]);
        }
        
    }else {
        
        if (_detailModel.loanType == LoanTypeYinQi) {
            //  银企桥接，15天计划
            investDays = [_detailModel.returnCycleNum integerValue];
            inComeTotal = HTSTR(@"%.3f", investDays * dayRate * [value floatValue]);
            
        }else {
            
            investMonths = [_detailModel.returnCycleNum integerValue];
            
            if ([_detailModel.repayType isEqualToString:kRepayType_Denge]) {
                //  等额本息
                NSArray *inComeArray = [self dengEInComes:[value floatValue] andInvestMonth:investMonths];
                
                CGFloat inComeMoney = .0f;
                for (NSNumber *inCome in inComeArray) {
                    inComeMoney += [inCome floatValue];
                }
                
                inComeTotal = HTSTR(@"%.3f", inComeMoney);
            }else {
                //  按月返息，到期还本 2.到期还本付息
                
                inComeTotal = HTSTR(@"%.3f", investMonths * monthRate * [value floatValue]);
            }
            
        }
    }
    
    return [inComeTotal substringToIndex:inComeTotal.length - 1];
}

- (NSInteger)daysInCurrentMonth
{
    NSInteger daysInMonth = 0;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[NSDate date]];
    //  当月的天数
    daysInMonth = range.length;
    
    return daysInMonth;
    
}

//  (债权项目)等额本息的计算
- (NSArray *)dengEInComes:(CGFloat)investMoney andInvestMonth:(NSInteger)investMonth
{
    CGFloat rateMonth = [_detailModel.annualize floatValue] / 12.0f / 100.0f;
    
    CGFloat totalInCome;
    //  等额本息
    CGFloat rateDenge = pow((rateMonth + 1), [_detailModel.returnCycleNum integerValue]);
    //  每月还款额
    CGFloat moneyTotal_perMonth = investMoney * rateDenge * rateMonth / (rateDenge - 1);
    
    //  每期利息
    CGFloat inComePerMonth;
    //  每期本金
    CGFloat moneyPerMonth;
    
    NSMutableArray *mutArray = [NSMutableArray array];
    
    for (int i = 1; i <= investMonth; i++) {
        //  每期利息
        inComePerMonth = investMoney * rateMonth;
        
        //  每期本金
        moneyPerMonth = moneyTotal_perMonth - inComePerMonth;
        //  剩余金额
        investMoney -= moneyPerMonth;
        
        //  总收益
        totalInCome += inComePerMonth;
        
        [mutArray addObject:@(inComePerMonth)];
    }
    
    return mutArray;
}


#pragma mark - 

/*  预期收益计算公式  */

/*
 NSDictionary *calculateRedeemInterest(NSString * money, NSString *rate, NSString *deadline, NSString *finishMon, NSString *nextDay, NSString *type)
 {
 CGFloat realInvestMoney = [money floatValue];
 var income = {};
 if (type == 1) {
 var leftCapital = 100000;
 income = calculateInterest(leftCapital, rate, deadline, type);
 for(var i=0;i<finishMon;i++) {
 leftCapital = leftCapital - income['eachRepay'][i][0];
 }
    realInvestMoney = (100000*money/leftCapital).toFixed(2);
 }
 
 income = calculateInterest(realInvestMoney, rate, deadline, type);
 var totalIncome = income['totalIncome'];
 for(i=0;i<finishMon;i++) {
 totalIncome = totalIncome - income['eachRepay'][i][1];
 }
 var now = new Date();
 now = +new Date((new Date).Format('yyyy-MM-dd'));
 
 var nextDate = new Date(nextDay);
 var preMonDate = new Date(nextDay);
 preMonDate.setDate(0);
 var dayInMons = preMonDate.getDate();
 var leftDays = dayInMons - parseInt((nextDate.getTime() - now)/86400000);
 var nowInterest = 0;
 if (type == 3) {
 nowInterest = (income['oneRepay'] * leftDays / dayInMons).toFixed(2);
 } else if (type == 1) {
 nowInterest = (income['eachRepay'][finishMon][1] * leftDays / dayInMons).toFixed(2);
 } else if (type == 2) {
 nowInterest = ((finishMon+leftDays/dayInMons) * income['totalIncome'] / deadline).toFixed(2);
 }
 
 totalIncome -= nowInterest;
 income['repayInterest'] = income['totalIncome'] - totalIncome;
 income['totalIncome'] = totalIncome;
 income['nowInterest'] = nowInterest;
 
 return income;
 
 }
 
 function calculateInterest(money, rate, deadline, type) {
 var oneRepay = 0, totalIncome = 0, eachRepay = [];
 if (type == 1) {    //等额本息
 //期利率
 var oneRate = rate/(12*100);
 var tmp = Math.pow(1+oneRate, deadline);
 //每月还款项
 oneRepay = parseFloat((money * oneRate * tmp / (tmp - 1))).toFixed(4);
 var oneInterest, oneSeedCapital;
 for (var i=0; i < deadline; i++) {
 //每期利率
 oneInterest = parseFloat((money * oneRate)).toFixed(4);
 //每期本金
 oneSeedCapital = parseFloat((oneRepay - oneInterest)).toFixed(4);
 eachRepay[i] = [parseFloat(oneSeedCapital).toFixed(2), parseFloat(oneInterest).toFixed(2)];
 money = parseFloat((money - oneSeedCapital)).toFixed(4);
 totalIncome += parseFloat(oneInterest);
 }
 } else if (type == 2) {
 totalIncome = money * rate * deadline / 1200;
 for(var i=0; i < deadline; i++) {
 eachRepay.push([0, 0]);
 }
 } else if (type == 3) {
 oneRepay = money * rate /1200;
 oneRepay = parseFloat(oneRepay).toFixed(2);
 totalIncome = money * rate /1200 * deadline;
 for (var i=0; i < deadline; i++) {
 eachRepay.push([0, oneRepay]);
 }
 }
 totalIncome = parseFloat(totalIncome).toFixed(2);
 return {'oneRepay': oneRepay, 'totalIncome': totalIncome, 'eachRepay': eachRepay};
 }
 */

@end