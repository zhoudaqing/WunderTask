//
//  BalanceViewController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/30.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "BalanceViewController.h"
#import "BalanceHeaderView.h"
#import "BalanceRuleViewController.h"
#import "BindingPhoneNumberTableViewController.h"
#import "NameCertificationController.h"
#import "CustomIOS7AlertView.h"

#define UserInputPassword   999999

@interface BalanceViewController () <UIAlertViewDelegate>

@property (nonatomic, strong)   BalanceHeaderView *headerView;
@property (nonatomic, strong)   UIImageView *adverView;
@property (nonatomic, strong)   UISwitch *balanceSwitch;
@property (nonatomic, assign)   BOOL balanceIsOpen;
@property (nonatomic, assign)   UIAlertView *alert;

@end

@implementation BalanceViewController

- (void)setBalanceIsOpen:(BOOL)balanceIsOpen
{
    if (_balanceIsOpen != balanceIsOpen) {
        _balanceIsOpen = balanceIsOpen;
        [User sharedUser].isBalanceIncomeOpen = balanceIsOpen;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _balanceIsOpen = [User sharedUser].isBalanceIncomeOpen;
    self.balanceSwitch.on = _balanceIsOpen;
    
    __weakSelf;
    [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state){
        [weakSelf requestBalance];
    }];
    
    //  现请求数据，在判断用户有没有开通 余额生息
    if (_balanceIsOpen) {
//        [self showLoadingViewWithState:LoadingStateLoading];
//        [self requestBalance];
        
    }else {
        [self refreshBalanceFootView:NO];
    }

    //  余额生息 （网页活动，需要单独查询一遍）
    [self showLoadingViewWithState:LoadingStateLoading];
    self.loadingStateView.backgroundColor = [UIColor jd_backgroudColor];
    
    [self requestBalance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccesstokenOutDate) name:__USER_ACCESSTOKEN_OUTDATE object:nil];
    
}

- (void)userAccesstokenOutDate
{
    if (_alert) {
        [_alert dismissWithClickedButtonIndex:0 animated:YES];
    }
}

- (void)requestBalance
{
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString balanceAccout]];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self removeLoadingView];
        [self removeHudInManaual];
        
        NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
        if (result) {
            [self refreshBalaceView:result];
        }

    } failure:^(YTKBaseRequest *request) {
        [self removeHudInManaual];
        [self showLoadingViewWithState:LoadingStateNetworkError];
        [self showHudErrorView:PromptTypeError];
    }];
}

- (void)refreshBalaceView:(NSDictionary *)dic
{
    BOOL isOpen = [[dic stringIntForKey:@"enabled"] boolValue];
    _balanceIsOpen = isOpen;
    
    [_balanceSwitch setOn:_balanceIsOpen animated:YES];

    if (_balanceIsOpen) {
        //  昨日收益
        [self.headerView setAnnualize:[dic stringFloatForKey:@"yesterday_interest_amount"]];
        //  累计收益
        [self.headerView setReturnCycle:[dic stringFloatForKey:@"sum_interest_amount"]];
        //  7日年化
        NSString *year7Rate = [dic stringForKey:@"qrnh"];
//        year7Rate = [year7Rate stringByAppendingString:@"%"];
        [self.headerView setInvesetMoney:year7Rate];
        //  万份收益
        NSString *perIncome = [dic stringForKey:@"wfsy"];
        [self.headerView setTimeLeft:perIncome];
    }
    
    [self refreshBalanceFootView:_balanceIsOpen];
    [self.tableView reloadData];
}

- (NSString *)rightNavigationImageStr
{
    return @"balance_info";
}

- (void)rightBarItemClicked:(UIButton *)button
{
    BalanceRuleViewController *controller = [[BalanceRuleViewController alloc] init];
    controller.title = @"余额生息计息规则";
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    cell.textLabel.text = @"余额生息";
    cell.textLabel.textColor = [UIColor jd_globleTextColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.accessoryView = self.balanceSwitch;

    return cell;
}

- (void)balanceSwitchClicked:(UISwitch *)balanceSwitch
{
    if (balanceSwitch.isOn == NO) {
        [self showPasswordInputView];
        
    }else {
        if ([User sharedUser].real_name_status == UserNameAuthStateAuthing) {
            [self revertSwitchState];
            [self showAlert:@"实名认证中,认证通过后,方可开启余额生息"];
            return;
        }
        
        [self sendBalanceStateRequest];
    }
}

- (void)sendBalanceStateRequest
{
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString balanceAccout]];
    request.shouldShowErrorMsg = NO;
    [self showHudWaitingView:PromptTypeWating];
    
    NSString *isOpen = _balanceSwitch.on ? @"on" : @"off";
    [request addPutValue:isOpen forKey:@"status"];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self removeHudInManaual];
        
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            
            [self showAlertMessage:message];
            
            [self revertSwitchState];
            
        }else {
            if ([isOpen isEqualToString:@"on"]) {
                [self requestBalance];
                self.balanceIsOpen = YES;
            }else {
                [self refreshBalanceFootView:NO];
                self.balanceIsOpen = NO;
            }
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self showHudErrorView:PromptTypeError];
        
        [self revertSwitchState];
    }];
}

- (void)showAlertMessage:(NSString *)message
{
    User *user = [User sharedUser];
    
    NSString *buttonStr = @"认证";
    if (isEmpty(user.userTelPhone)) {
        //  显示真实姓名认证
        buttonStr = @"绑定";
    }
    
    [self alertViewWithButtonsBlock:^NSArray *{
        return @[buttonStr];
    } andHandleBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self showValidateController];
        }
        
    } andMessage:message];
    
}

- (void)showValidateController
{
    User *user = [User sharedUser];
    
    UIViewController *controller = nil;
    if (isEmpty(user.userTelPhone)) {
        //  显示真实姓名认证
        BindingPhoneNumberTableViewController *bind = [[BindingPhoneNumberTableViewController alloc] init];
        controller = bind;
        
    }else {
        NameCertificationController *name = [[NameCertificationController alloc] init];
        controller = name;
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)refreshBalanceFootView:(BOOL)isOpen
{
    UIView *hideView = isOpen ? self.adverView : self.headerView;
    UIView *showView = isOpen ? self.headerView : self.adverView;
    
    __weakSelf;
    [UIView animateWithDuration:.35 animations:^{
        hideView.alpha = .0f;
        
    } completion:^(BOOL finished) {
        weakSelf.tableView.tableFooterView = showView;
        [UIView animateWithDuration:.35 animations:^{
            showView.alpha = 1.0f;
        }];
    }];
}

- (void)showPasswordInputView
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"关闭余额生息需要输入支付密码" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = UserInputPassword;
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = @"支付密码";
    
    _alert = alertView;
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag != UserInputPassword) {
        if (buttonIndex == 1) {
            [self showValidateController];
        }
        
        return;
    }
    
    //  只处理用户输入密码事件
    if (buttonIndex == 0) {
        //  取消
        [self revertSwitchState];
        
    }else {
        //  确认
        UITextField *textField = [alertView textFieldAtIndex:0];
        [self verifyPassword:textField.text];
        
    }
}

- (void)verifyPassword:(NSString *)pass
{
    if (![pass isValidatePass]) {
        [self showHudErrorView:@"密码需要在6~16位之间"];
        [self revertSwitchState];
        return;
    }
    
    HTBaseRequest *request = [HTBaseRequest requestWithURL:[NSString verificatifyUserPassword]];
    
    [request addPostValue:[User sharedUser].userID forKey:@"uid"];
    [request addPostValue:pass forKey:@"pay_pwd"];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        
        NSString *result = [request.responseJSONObject stringForKey:@"result"];
        
        if (result.length > 0) {
            [self sendBalanceStateRequest];
        }else {
            [self revertSwitchState];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self revertSwitchState];
    }];
}

- (void)revertSwitchState
{
    BOOL isOn = !self.balanceSwitch.on;
    [self.balanceSwitch setOn:isOn animated:YES];
}

#pragma mark - Config

- (BalanceHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [BalanceHeaderView xibView];
        _headerView.height = 200.0f;
    }
    
    return _headerView;
}

- (UIImageView *)adverView
{
    if (!_adverView) {
        _adverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 300)];
        UIImage *image = HTImage(@"balancePrompt");
        if (is47Inch) {
            image = HTImage(@"balancePrompt6");
        }
        _adverView.image = image;
        [_adverView sizeToFit];
    }
    
    return _adverView;
}

- (UISwitch *)balanceSwitch
{
    if (!_balanceSwitch) {
        _balanceSwitch = [[UISwitch alloc] init];
        [_balanceSwitch addTarget:self action:@selector(balanceSwitchClicked:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _balanceSwitch;
}

- (NSString *)title
{
    return @"余额生息";
}

@end
