 //
//  MyAccountViewController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/26.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "MyAccountViewController.h"
#import "InvestMentSelectionController.h"
#import "RechangeViewController.h"
#import "ReturnMoneyViewController.h"
#import "WithdrawBankViewController.h"
#import "AccountHeaderView.h"
#import "BalanceViewController.h"
#import "HTNavigationController.h"
#import "WithdrawingViewController.h"
#import "AccountBalanceViewController.h"
#import "RedEnvelopeViewController.h"
#import "AllIncomeViewController.h"
#import "InvitationFriendViewController.h"
#import "UIImage+Stretch.h"
#import "NSString+Size.h"
#import "TotalIncomeViewController.h"
#import "NameCertificationController.h"
#import "UILabel+FlickerNumber.h"
#import "RedemptionViewController.h"

@interface MyAccountViewController ()
{
    AccountBalanceViewController *_account;
}
@property (nonatomic, strong)  AccountHeaderView *accountView;

@property (nonatomic)  NSDictionary *accountDic;

//  刷新错误
@property (nonatomic, assign) BOOL isRefreshError;

@property (nonatomic, assign) BOOL shouldeReferesh;

@end

@implementation MyAccountViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
    
    if (_isRefreshError || _shouldeReferesh) {
        [self accountRefresh];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addRechangeBtn];
    
    self.showRefreshHeaderView = YES;
    self.tableView.tableHeaderView = self.accountView;
    
    //  init Header
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
    backView.backgroundColor = [UIColor jd_accountBackColor];
    [self.view addSubview:backView];
    [self.view sendSubviewToBack:backView];
    
    [self.refreshHeaderView makeWhite];
    
    //  登录成功，或者是手势验证成功，则刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRefereshSign) name:__USER_LOGIN_SUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountRefresh) name:__USER_INPUT_GESURE_SUCCESS object:nil];
    
    //  主动通知刷新 （投资金额变动， 取现金额变动，等等...）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRefereshSign) name:__USER_ACCOUNT_REFRESH_NOTIFACTION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginOut) name:__USER_LOGINOUT_SUCCESS object:nil];
    
    [self accountRefresh];
    
    UIView *view = [[UIView alloc] init];
    view.height = 50.0f;
    self.tableView.tableFooterView = view;
    
    [self.tableView reloadData];
    
    self.tableView.tableHeaderView = self.accountView;
    
}

- (void)changeRefereshSign
{
    _shouldeReferesh = YES;
}

- (void)userLoginOut
{
    _accountDic = nil;
    self.accountView = nil;

    self.tableView.tableHeaderView = self.accountView;
}

- (void)accountRefresh
{
    [self.refreshHeaderView refreshByManual];
}

//  MARK:布局重定义
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    [self.refreshHeaderView refreshContentInset];
}

- (void)viewDidLayoutSubviews
{
    self.tableView.tableHeaderView = self.accountView;
}

#pragma mark - AccountHeaderView

//  MARK:顶部视图
- (AccountHeaderView *)accountView
{
    if (!_accountView) {
        _accountView = [AccountHeaderView xibView];
        __weakSelf;
        [_accountView setLeftViewBlock:^(AccountHeaderView * view) {
            //  投资中
            [weakSelf headerViewLeftViewClicked];
        }];
        [_accountView setRightViewBlock:^(AccountHeaderView *view) {
            //  提现中
            [weakSelf headerViewRightViewClicked];
        }];
    }
    
    _accountView.height = 186.0f;
    
    return _accountView;
}

//  MARK:投资中页面
- (void)headerViewLeftViewClicked
{
    InvestMentSelectionController *invest = [[InvestMentSelectionController alloc] init];
    invest.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:invest animated:YES];
}

//  MARK:提现中页面
- (void)headerViewRightViewClicked
{
    WithdrawingViewController *ctr = [[WithdrawingViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
    ctr.title = @"提现中";
    ctr.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ctr animated:YES];
}

// MARK:添加充值按钮
- (void)addRechangeBtn
{
    UIButton *recharge = [UIButton buttonWithType:UIButtonTypeCustom];
    recharge.frame = CGRectMake(0, 0, 46, 30);
    [recharge setTitle:@"充值" forState:UIControlStateNormal];
    recharge.titleLabel.font = HTFont(15.0f);
    [recharge setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [recharge setBackgroundImage:[HTImage(@"account_rechage") autoStretchImage] forState:UIControlStateNormal];
    [recharge setBackgroundImage:[HTImage(@"account_rechage_high") autoStretchImage] forState:UIControlStateHighlighted];
    [recharge addTarget:self action:@selector(pushRechangeView) forControlEvents:UIControlEventTouchUpInside];
    recharge.layer.masksToBounds = YES;
    recharge.layer.cornerRadius = 12.0f;
    recharge.layer.borderWidth = .3f;
    recharge.layer.borderColor = [UIColor clearColor].CGColor;
    
    UIBarButtonItem *rechangeBtn = [[UIBarButtonItem alloc] initWithCustomView:recharge];
    rechangeBtn.tintColor = HTWhiteColor;
    
    [self.navigationItem setRightBarButtonItem:rechangeBtn];
}

//  MARK:充值页面
- (void)pushRechangeView
{
    RechangeViewController *rechangeCtr = [[RechangeViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
    [User sharedUser].isInVestRecharge = YES;
    rechangeCtr.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rechangeCtr animated:YES];
}

#pragma mark - Refresh

//  MARK:刷新控制
- (void)refreshViewBeginRefresh:(MJRefreshBaseView *)baseView
{
    [self requestUserAccountData];
}

- (void)requestUserAccountData
{
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString getMyAccount]];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        
        [self.refreshHeaderView refreshContentInsetZero];
        [self.refreshHeaderView endRefreshing];
        
        NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
        if (result) {
            
            _isRefreshError = NO;
            _shouldeReferesh = NO;
            
            [self handleResponseData:result];
            
        }else {
            _isRefreshError = YES;
            _shouldeReferesh = YES;
        }
        
    } failure:^(YTKBaseRequest *request) {
        
        _isRefreshError = YES;
        _shouldeReferesh = YES;
        
        self.tableView.contentInset = UIEdgeInsetsZero;
        [self.refreshHeaderView refreshContentInsetZero];
        [self.refreshHeaderView endRefreshing];
        
    }];
}

- (void)handleResponseData:(NSDictionary *)result
{
    self.accountDic = result;
    
    [User sharedUser].accountBalance = [result stringForKey:@"account_balance"];
    [User sharedUser].isBalanceIncomeOpen = [[result stringForKey:@"yesx_enabled"] boolValue];
    
    [self refreshHeaderView:result];
    
    // 改变账户余额页面 账户余额
    [_account changeAccountBalance];
    
    [self.tableView reloadData];
}

//  MARK:头视图刷新
- (void)refreshHeaderView:(NSDictionary *)result
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    if (APPSystemVersion >= 8) {
        formatter.formattingContext = NSNumberFormatterDecimalStyle;
    }
    
    NSString *moneyStr = [result stringFloatForKey:@"property_total"];
    CGFloat moneyValue =[moneyStr floatValue];
    
    NSString *orginStr = self.accountView.totalMoney.text;
    BOOL shouldFlip = [orginStr isEqualToString:@"--"];
    
    //  MARK:任何刷新都触发数字滚动
    shouldFlip = YES;

    if (shouldFlip) {
        [self.accountView.totalMoney dd_setNumber:[NSNumber numberWithFloat:moneyValue] duration:1.0f format:@"%.2f" formatter:formatter];
    }else{
        
        [self.accountView.totalMoney setText:[moneyStr formatNumberString]];
    }
    
    moneyStr = [result stringFloatForKey:@"investing_fee"];
    moneyValue =[moneyStr floatValue];
    
    if (shouldFlip) {
        [self.accountView.inComeMoney dd_setNumber:@(moneyValue) duration:1.0f format:@"%.2f" formatter:formatter];
        
    }else {
        self.accountView.inComeMoney.text = [moneyStr  formatNumberString];
        
    }
    
    moneyStr = [result stringFloatForKey:@"withdrawal_fee"];
    moneyValue = [moneyStr floatValue];
    
    if (shouldFlip) {
        [self.accountView.outMoney dd_setNumber:@(moneyValue) duration:1.0f format:@"%.2f" formatter:formatter];
        
    }else {
        self.accountView.outMoney.text = [moneyStr formatNumberString];
        
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:return 1;
        case 1:return 4;
        case 2:return 2;
        default:return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"accountIdentifier";
    
    HTBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[HTBaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.detailTextLabel.textColor = [self colorAtIndexPath:indexPath];
    cell.imageView.image = HTImage([self imageStrAtIndexPath:indexPath]);
    
    cell.textLabel.text = [self titleAtIndexPath:indexPath];
    cell.detailTextLabel.text = [self detailTextAtIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return 10.0f;
    }
    
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    UIViewController *viewController = nil;
    
    if (section == 0) {
        //账户余额
        _account  = [[AccountBalanceViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
        viewController = _account;
    }else if (section == 1) {
        
        if (row == 0) {
            //累计收益
            TotalIncomeViewController *totalIncome = [[TotalIncomeViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
            viewController = totalIncome;
            
        }else if (row == 1) {
        
            //红包管理
            RedEnvelopeViewController   *redEnvelope = [[RedEnvelopeViewController alloc]init];
            viewController = redEnvelope;
            
        }else if(row == 2){
            
            //  正在回款
            ReturnMoneyViewController *returnMoneyTimes = [[ReturnMoneyViewController alloc]init];
            viewController = returnMoneyTimes;
        }else if(row == 3){
            RedemptionViewController *redemption = [[RedemptionViewController alloc]init];
            viewController = redemption;
        }
    
    }else if(section == 2){
        
        if (row == 0) {
            //  提现银行卡
            if ([User sharedUser].real_name_status == UserNameAuthStateAuthed ||[User sharedUser].real_name_status == UserNameAuthStateAuthing) {
                WithdrawBankViewController *withdraw = [[WithdrawBankViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
                viewController = withdraw;
            }else if ([User sharedUser].real_name_status == UserNameAuthStateOutTime)
            {
                NSString *prompt = HTSTR(@"实名认证次数超限，如有疑问，请拨打客服电话:%@", kServicePhone_f);
                [self alertViewWithButtonsBlock:^NSArray *{
                    return @[@"拨打"];
                } andHandleBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        // 拨打电话
                        NSString *telphone = HTSTR(@"telprompt://%@",kServicePhone);
                        [[UIApplication sharedApplication] openURL:HTURL(telphone)];
                    }
                    
                } andMessage:prompt];
                
            }else{
                
                NSString *prompt = HTSTR(@"未实名认证,实名认证通过后方可查看");
                [self alertViewWithButtonsBlock:^NSArray *{
                    return @[@"确定"];
                } andHandleBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        NameCertificationController *ctr= [[NameCertificationController alloc]init];
                        ctr.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:ctr animated:YES];
                    }
        
                } andMessage:prompt];
            }
            
        }else {
            //  余额生息
            BalanceViewController *balance = [[BalanceViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
            viewController = balance;
        }
        
    }else if (section == 3){
        
        InvitationFriendViewController *invitation = [[InvitationFriendViewController alloc]init];
        viewController = invitation;
    }
    
    viewController.title = [self titleAtIndexPath:indexPath];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Config

- (NSString *)titleAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *titles = @[@[@"账户余额"],
                        @[@"累计收益", @"红包管理", @"剩余回款", @"赎回项目"],
                        @[@"提现银行卡", @"余额生息"],
                        @[@"邀请好友"]];

    return titles[indexPath.section][indexPath.row];
}

- (NSString *)imageStrAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *images = @[@[@"account_account"], @[@"accout_totalIncome", @"accout_redPoint", @"account_leftReturnMoney", @"account_rebackMoney"], @[@"account_bankMoney", @"account_balance"],@[@"account_invetFriend"]];
    
    return images[indexPath.section][indexPath.row];
}

- (UIColor *)colorAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0) {
        return [UIColor jd_settingDetailColor];
        
    }else if (section == 1){
        
        if (row == 0) {
            return [UIColor jd_settingDetailColor];
            
        }else {
            return [UIColor jd_lineColor];
        }
        
    }else {
        return [UIColor jd_lineColor];
    }
    
}

- (NSString *)detailTextAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.accountDic == nil) {
        return @"正在加载";
    }
    
    //余额生息状态
    NSString *str = [User sharedUser].isBalanceIncomeOpen ? @"已开启" : @"未开启";
    
    NSArray *titles = @[
                        @[[[User sharedUser].accountBalance formatNumberString]],
                        @[
                            [[self.accountDic stringFloatForKey:@"net_income"] formatNumberString],
                            
                            @"",
                            
                            [NSString stringWithFormat:@"还有%@笔回款",
                            [self.accountDic stringIntForKey:@"repayment_nums"]],
                            
                            @""],
                        
                        @[@"",str],
                        @[@""]
                        
                        ];
    
    return titles[indexPath.section][indexPath.row];
}

@end
