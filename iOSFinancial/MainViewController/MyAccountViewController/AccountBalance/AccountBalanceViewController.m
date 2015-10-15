//
//  AccountBalanceViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/30.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "AccountBalanceViewController.h"
#import "AccountBalanceTableViewCell.h"
#import "RechangeViewController.h"
#import "HTNavigationController.h"
#import "WithdrawViewController.h"
#import "DropDownListView.h"
#import "BankModel.h"
#import "AddCardViewController.h"
#import "NameCertificationController.h"
#import "NSString+Size.h"

@interface AccountBalanceViewController ()<MJRefreshBaseViewDelegate>
{
    int _arrayCount, _pageNumber, _lastPageNumber;;
    UILabel *_moneyLable;
    NSMutableArray *_chooseArray;
    NSString *_type_id, *_start_time, *_end_time, *_url;
    UIView *_bottomBtnview;
}

@property (nonatomic) MJRefreshFooterView *footer;

@property (nonatomic) NSMutableArray *mArray;

@property (nonatomic) UIButton *allTypeBtn;

@property (nonatomic) UIButton *allTimeBtn;

@property (nonatomic) NSArray *allType;

@property (nonatomic) NSArray *allTmie;

@property (nonatomic) UIView *topBtnView;

@property (nonatomic) NSArray *bankList;

@end

@implementation AccountBalanceViewController

- (void)dealloc
{
    [_footer free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addWithrawingBtnAndRechageBtn];
    [self addtopTwoBtn];
    
    _pageNumber = 1;
    _lastPageNumber = 2;
    self.tableView.frame = CGRectMake(0, self.tableView.origin.y + 44, APPScreenWidth, self.view.height - 137);
    
    __weakSelf;
    [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state){
        [weakSelf refreshViewBeginRefreshing:nil];
    }];
    
    [self showLoadingViewWithState:LoadingStateLoading];
     
    [self refreshViewBeginRefreshing:nil];
    self.tableView.tableFooterView = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accounListtRefresh) name:__USER_ACCOUNT_REFRESH_NOTIFACTION object:nil];
    
    [self setCellLine];
    
    self.showRefreshHeaderView = YES;
}

// MARK:  充值或者 提现成功之后刷新
- (void)accounListtRefresh
{
    self.mArray = nil;
    _pageNumber = 1;
    _lastPageNumber = 2;
    [self refreshViewBeginRefreshing:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _moneyLable.text = [[User sharedUser].accountBalance formatNumberString];
}

// MARK:  更新余额
- (void)changeAccountBalance
{
    _moneyLable.text = [[User sharedUser].accountBalance formatNumberString];
}

- (void)refreshViewBeginRefresh:(MJRefreshBaseView *)baseView
{
    self.mArray = nil;
    _pageNumber = 1;
    _lastPageNumber = 2;
    [self refreshViewBeginRefreshing:nil];
}

//  MARK:加载更多
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    HTBaseRequest *request = [HTBaseRequest requestWithURL:[self investorBillurl]];
    if (_pageNumber < _lastPageNumber) {
        [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            [self removeLoadingView];
            [self removeHudInManaual];
            [self.footer endRefreshing];
            [self endRefresh];
            NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
            if (result) {
                NSArray *array = result[@"data"];
                [self.mArray addObjectsFromArray:array];
                _lastPageNumber = [result[@"last_page"] intValue] + 1;
                _pageNumber ++;
                if (array.count == 0) {
                    [self showLoadingViewWithState:LoadingStateNoneData];
                }
                [self.tableView reloadData];
            }
            
        } failure:^(YTKBaseRequest *request) {
            [self showLoadingViewWithState:LoadingStateNetworkError];
            [self showHudErrorView:PromptTypeError];
        }];
    }else
    {
        [refreshView endRefreshing];
        [self showHudAuto:@"没有更多数据了"];
    }
    
}

- (void)willChangePromptView
{
    self.loadingStateView.promptStr = @"没有数据";
    self.loadingStateView.userInteractionEnabled = NO;
}

- (MJRefreshFooterView *)footer
{
    if (!_footer) {
        //上啦刷新
        _footer = [MJRefreshFooterView footer];
        _footer.delegate = self;
        _footer.scrollView = self.tableView;
    }
    return _footer;
}


- (NSMutableArray *)mArray
{
    if (!_mArray) {
        _mArray  = [[NSMutableArray alloc]init];
    }
    return _mArray;
}

//  MARK: 生成加载网址
- (NSString *)investorBillurl
{
    if (_url== nil) {
        _url = [NSString investorBill];
    }else if (_type_id == nil && _start_time == nil && _end_time == nil) {
        _url = [NSString stringWithFormat:@"%@?&page=%d",[NSString investorBill], _pageNumber];
    }else if (_type_id != nil && _start_time == nil && _end_time == nil) {
        _url = [NSString stringWithFormat:@"%@?&type_id=%@&page=%d",[NSString investorBill], _type_id, _pageNumber];
    }else if(_type_id != nil && _start_time != nil && _end_time != nil){
        _url =  [NSString stringWithFormat:@"%@?type_id=%@&page=%d&start_time=%@&end_time=%@",[NSString investorBill], _type_id, _pageNumber, _start_time, _end_time];
    }else if(_type_id == nil && _start_time != nil && _end_time != nil){
        _url = [NSString stringWithFormat:@"%@?&page=%d&start_time=%@&end_time=%@",[NSString investorBill], _pageNumber, _start_time, _end_time];
    }
    return _url;
}

//  MARK: 添加上两个按钮
- (void)addtopTwoBtn
{
    _chooseArray = [NSMutableArray arrayWithArray:@[
                                                    @[@"全部类型",@"投资",@"充值",@"提现",@"回收本金",@"回收收益",@"赎回",@"获取红包",@"解锁红包",@"其他",@"余额生息"],
                                                    @[@"全部时间",@"近一个星期",@"近一个月",@"近半年",@"近一年",@"近两年"]
                                                    ]];
    
    DropDownListView *dropDownView = [[DropDownListView alloc] initWithFrame:CGRectMake(0,TransparentTopHeight, APPScreenWidth, 44) dataSource:self delegate:self];
    dropDownView.mSuperView = self.view;
    [self.view addSubview:dropDownView];
}

#pragma mark -- dropDownListDelegate
-(void) chooseAtSection:(NSInteger)section index:(NSInteger)index
{
    NSLog(@"虎大爷选了section:%ld ,index:%ld",(long)section,(long)index);
    _url = [NSString stringWithFormat:@"%@?type_id=%@&&page=%d&&start_time=%@&&end_time=%@",[NSString investorBill], _type_id, _pageNumber, _start_time, _end_time];
    _pageNumber = 1 ;
    _lastPageNumber = 2;
    
    switch (section) {
        case 0:
        {
            switch (index) {
                case 0:
                {
                    _type_id = nil;
                }
                    break;
                default:
                    _type_id = [NSString stringWithFormat:@"%ld",(long)index];
                    break;
            }
            
        }
            break;
            
        default:
            switch (index) {
                case 0:
                {
                    _start_time  = nil;
                    _end_time = nil;
                }
                    break;
                case 1:
                {
                    _end_time = [self endTime];
                    _start_time = [self startedTimeWithTimeLong:604800];
                }
                    break;
                case 2:
                {
                    _end_time = [self endTime];
                    _start_time = [self startedTimeWithTimeLong:30*24*3600];
                }
                    break;
                case 3:
                {
                    _end_time = [self endTime];
                    _start_time = [self startedTimeWithTimeLong:182*24*3600];
                }
                    break;
                case 4:
                {
                    _end_time = [self endTime];
                    _start_time = [self startedTimeWithTimeLong:365*24*3600];
                }
                    break;
                default:
                {
                    _end_time = [self endTime];
                    _start_time = [self startedTimeWithTimeLong:2*365*24*3600];
                }
                    break;
            }
            break;
    }
    
    self.mArray = nil;
    [self.tableView reloadData];
    
    __weakSelf;
    [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state){
        [weakSelf refreshViewBeginRefreshing:nil];
    }];
    
    [self showLoadingViewWithState:LoadingStateLoading];
    
    [self refreshViewBeginRefreshing:nil];
}

//  MARK: 生成结束时间
- (NSString *)endTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return  [dateFormatter stringFromDate:[NSDate date]];

}

//  MARK:生成开始时间
- (NSString *)startedTimeWithTimeLong:(long int)timeLong
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:a - timeLong];
    NSString *started = [NSString stringWithFormat:@"%@",confromTimesp];
    
    return [started substringToIndex:10];
}

#pragma mark -- dropdownList DataSource
-(NSInteger)numberOfSections
{
    return [_chooseArray count];
}
-(NSInteger)numberOfRowsInSection:(NSInteger)section
{
    NSArray *arry =_chooseArray[section];
    return [arry count];
}
-(NSString *)titleInSection:(NSInteger)section index:(NSInteger) index
{
    return _chooseArray[section][index];
}
-(NSInteger)defaultShowSection:(NSInteger)section
{
    return 0;
}

#pragma -tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

    return .01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell_identifier";
    AccountBalanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[AccountBalanceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (self.mArray.count>0) {
        NSDictionary *dict = self.mArray[indexPath.row];
        cell.typeLable.text = [dict stringForKey:@"bill_type_name"];
        cell.balanceLable.text = [dict stringFloatForKey:@"balance_fee"];
        cell.timeLable.text = [dict stringForKey:@"bill_date"];
        cell.moneyLable.text = [dict stringFloatForKey:@"income_fee"];
        cell.abstractLable.text = [dict stringForKey:@"summary"];
    }
   

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 96.0f;
}

// MARK:  cell的线从屏幕左侧开始
- (void)setCellLine
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}



//  MARK: 添加账户余额 提现 和 充值 按钮
- (void)addWithrawingBtnAndRechageBtn
{
    _bottomBtnview = [[UIView alloc]initWithFrame:CGRectMake(0, APPScreenHeight - 93 - 44, APPScreenWidth, 93)];
    _bottomBtnview.backgroundColor = [UIColor colorWithHEX:0xf5f5f5];
    [self.view addSubview:_bottomBtnview];

    UIView *rimline = [Sundry rimLine];
    rimline.frame = CGRectMake(0, 0, APPScreenWidth, 0.5);
    [_bottomBtnview addSubview:rimline];
    
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, APPScreenWidth/2, 44)];
    lable.textAlignment = NSTextAlignmentLeft;
    lable.text = @"账户余额（元）";
    [_bottomBtnview addSubview:lable];
    
    _moneyLable = [[UILabel alloc]initWithFrame:CGRectMake(APPScreenWidth/2, 0, APPScreenWidth/2-15, 44)];
    _moneyLable.textColor = [UIColor jd_barTintColor];
    _moneyLable.text = [User sharedUser].accountBalance;
    _moneyLable.textAlignment = NSTextAlignmentRight;
    [_bottomBtnview addSubview:_moneyLable];
    
    UIButton *withdrawingBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 44, APPScreenWidth/2, 49)];
    withdrawingBtn.backgroundColor = [UIColor grayColor];
    [withdrawingBtn setTitle:@"提现" forState:UIControlStateNormal];
    withdrawingBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [withdrawingBtn setTitleColor:[UIColor jd_darkBlackTextColor] forState:UIControlStateNormal];
    [withdrawingBtn setBackgroundImage:[Sundry createImageWithColor:[UIColor colorWithHEX:0xe5e5e5]] forState:UIControlStateNormal];
    [withdrawingBtn setBackgroundImage:[Sundry createImageWithColor:[UIColor colorWithHEX:0xcccccc]] forState:UIControlStateHighlighted];
    [withdrawingBtn addTarget:self action:@selector(clickwihtDrawBtn) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBtnview addSubview:withdrawingBtn];
    
    UIButton *rechageBtn = [[UIButton alloc]initWithFrame:CGRectMake(APPScreenWidth/2, 44, APPScreenWidth/2, 49)];
    rechageBtn.backgroundColor = [UIColor jd_barTintColor];
    rechageBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [rechageBtn setTitle:@"充值" forState:UIControlStateNormal];
    [rechageBtn setBackgroundImage:[Sundry createImageWithColor:[UIColor jd_BigButtonNormalColor]] forState:UIControlStateNormal];
    [rechageBtn setBackgroundImage:[Sundry createImageWithColor:[UIColor jd_BigButtonHightedColor]] forState:UIControlStateHighlighted];
    [rechageBtn addTarget:self action:@selector(clickRechageBtn) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBtnview addSubview:rechageBtn];
}

// MARK: 点击提现按钮
- (void)clickwihtDrawBtn
{
    if ([User sharedUser].real_name_status == 2) {
        [self showHudManaual:@"加载中..."];
        HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString bankCard]];
        [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            [self removeHudInManaual];
            NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
            if (error) {
                NSString *message = [error stringForKey:@"message"];
                [self showHudErrorView:message];
                
            }else {
                NSArray *result = [request.responseJSONObject arrayForKey:@"result"];
                [self parseCardList:result];
            }
            
        } failure:^(YTKBaseRequest *request) {
            
            [self showHudErrorView:PromptTypeError];
            
            
        }];
    }else if ([User sharedUser].real_name_status == 1)
    {
        [self showAlert:@"您的实名正在审核状态，请耐心等待,审核通过后可以提现"];
    }else if ([User sharedUser].real_name_status == -1)
    {
        NSString *prompt = @"您的实名认证失败，是否联系客服？";
        [self alertViewWithButtonsBlock:^NSArray *{
            return @[@"拨打"];
        } andHandleBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                // 拨打电话
                NSString *telphone = HTSTR(@"telprompt://%@",kServicePhone);
                [[UIApplication sharedApplication] openURL:HTURL(telphone)];
            }
            
        } andMessage:prompt];
    }else
    {
        // 未认证或者认证失败时调用
            NSString *prompt = @"提现需要实名认证,是否进行实名认证？";
            [self alertViewWithButtonsBlock:^NSArray *{
                return @[@"确定"];
            } andHandleBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    // 跳转页面
                    NameCertificationController *ctr= [[NameCertificationController alloc]init];
                    ctr.hidesBottomBarWhenPushed = YES;
                    ctr.title  = @"实名认证";
                    [self.navigationController pushViewController:ctr animated:YES];
                }else
                {
                    [self  dismissViewController];
                }
                
            } andMessage:prompt];

    }
}

//  MARK:点击提现时的操作
- (void)parseCardList:(NSArray *)array
{
    NSMutableArray *mutArray = [NSMutableArray array];
    for (NSDictionary *cardDic in array) {
        BankModel *model = [BankModel new];
        [model parseWithDictionary:cardDic];
        [mutArray addObject:model];
    }
    
    _bankList = [mutArray copy];
    
    if (array.count == 0) {
        
        NSString *prompt = HTSTR(@"您尚未添加提现银行卡，是否现在添加？");
        [self alertViewWithButtonsBlock:^NSArray *{
            return @[@"添加"];
        } andHandleBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if (buttonIndex == 1) {
                AddCardViewController *addCard = [[AddCardViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
                addCard.title = @"绑定银行卡";
                HTNavigationController *nav = [[HTNavigationController alloc]initWithRootViewController:addCard ];
                [self presentViewController:nav animated:YES completion:nil];
            }
            
        } andMessage:prompt];

        
    }else {
        
        WithdrawViewController  *withdrawCtr = [[WithdrawViewController alloc]init];
        withdrawCtr.title = @"申请提现";
        withdrawCtr.cardInfoArray  = array;
        withdrawCtr.money = [User sharedUser].accountBalance;
        [self.navigationController pushViewController:withdrawCtr animated:YES];
    }
}


// MARK: 点击充值按钮
- (void)clickRechageBtn
{
    RechangeViewController *rechangeCtr = [[RechangeViewController alloc]init];
    rechangeCtr.hidesBottomBarWhenPushed = YES;
    [User sharedUser].isInVestRecharge = NO;
    HTNavigationController *nav = [[HTNavigationController alloc]initWithRootViewController:rechangeCtr ];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
