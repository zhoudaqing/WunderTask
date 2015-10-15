//
//  RedeemViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/7/14.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "RedeemViewController.h"
#import "AttributedLabel.h"
#import "HTWebViewController.h"
#import "NSString+IsValidate.h"
#import "TPKeyboardAvoidingScrollView.h"


@interface RedeemViewController ()<UITextFieldDelegate>
{
    UIButton *_nextBtn;
    UITextField *_toSellMoney, *_payPassword;
    NSDictionary *_dict;
    UILabel *_toSellLable, *_redeem_moneyLable, *_balance_amountLable;
    NSString  *_texting;
}

@property (nonatomic)AttributedLabel *JDprotocol;

@property (nonatomic) UITapGestureRecognizer *tap;

@end

@implementation RedeemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"提前赎回";
    
    [self.tableView removeFromSuperview];
    __weakSelf;
    [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state){
        [weakSelf setNetWork];
    }];
    
    [self showLoadingViewWithState:LoadingStateLoading];
    
    [self setNetWork];
}

- (void)setNetWork
{
    HTBaseRequest *request = [HTBaseRequest requestWithURL:[NSString stringWithFormat:@"%@%@",[NSString loansRelationRedeemBase],self.redeenModel.ipid]];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self removeLoadingView];
        _dict = [request.responseJSONObject dictionaryForKey:@"result"];
       
        
        if (_dict) {
            // 添加确认赎回按钮
            if (APPScreenHeight < 600) {
                TPKeyboardAvoidingScrollView *keyScrollView = [[TPKeyboardAvoidingScrollView alloc]initWithFrame:self.view.frame];
                keyScrollView.delegate = self;
                [self.view addSubview:keyScrollView];
                [keyScrollView addSubview:self.tableView];
            }else
            {
                [self.view addSubview:self.tableView];
            }

            _nextBtn =[Sundry BigBottomBtnWithTitle:@"确认赎回"];
            [_nextBtn addTarget:self action:@selector(ClickAffirmBtn) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_nextBtn];

        }else
        {
            _dict = [request.responseJSONObject dictionaryForKey:@"error"];
            [self showHudAuto:[_dict stringIntForKey:@"message"]];
            [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:.8f];
        }
        
    } failure:^(YTKBaseRequest *request) {
        
        [self showLoadingViewWithState:LoadingStateNetworkError];
        
    }];
    
}



- (void)ClickAffirmBtn
{
    if ([_toSellMoney.text doubleValue]<[[_dict stringIntForKey:@"transfer_fee"] doubleValue]) {
        
        [self showHudAuto:[NSString stringWithFormat:@"出让金额不能少于%@元",[_dict stringIntForKey:@"transfer_fee"]]];
        [self performSelector:@selector(showKeyBoard) withObject:nil afterDelay:1.2f];
        
    }else if ([_toSellMoney.text doubleValue] > [[_dict stringIntForKey:@"max_transferFee"] doubleValue])
    {
        [self showHudAuto:[NSString stringWithFormat:@"出让金额不能超过%@元",[_dict stringIntForKey:@"max_transferFee"]]];
        [self performSelector:@selector(showKeyBoard) withObject:nil afterDelay:1.2f];
    }else if (![_payPassword.text isValidatePass])
    {
        [_payPassword becomeFirstResponder];
        [self showHudAuto:@"请核对您的支付密码"];
        
    }else
    {
        [self showHudWaitingView:@"正在提交信息..."];
        HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString stringWithFormat:@"%@%@",[NSString loansRelationRedeem],self.redeenModel.ipid]];
        [request addPostValue:_toSellMoney.text forKey:@"money"];
        [request addPostValue:_payPassword.text forKey:@"pay_pwd"];
        [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
            [self removeHudInManaual];
            if (error) {
                NSString *message = [error stringForKey:@"message"];
                [self showHudErrorView:message];
                
            }else {
                [self showHudSuccessView:@"赎回成功~！"];
                [self performSelector:@selector(dismissToGranpfater) withObject:nil afterDelay:.8f];
            }
            
        } failure:^(YTKBaseRequest *request) {
            [self showHudErrorView:PromptTypeError];
            [self removeHudInManaual];
        }];

        
       }
}

- (void)showKeyBoard
{
    [_toSellMoney becomeFirstResponder];
}

- (void)dismissToGranpfater
{
   
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    if ([self.delegate respondsToSelector:@selector(selfDissMiss)]) {
        [self.delegate selfDissMiss];
    }
}

- (NSArray *)Plist
{
    return @[@[@"出让金额(元)"],@[@"代收本金(元)",@"当期应收收益(元)",@"折让费用(元)",@"手续费(元)",@"赎回金额(元)",@"赎回后账户金额(元)"],@[@"支付密码"]];
}

#pragma mark: TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array =[self Plist][section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"redeemVTIdentifier";
    
    HTBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[HTBaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
        NSArray *array = [self Plist];
        cell.textLabel.text =array[indexPath.section][indexPath.row];
        cell.detailTextLabel.textColor   = [UIColor jd_globleTextColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        switch (indexPath.section) {
            case 0:
                _toSellMoney = [Sundry CellTextFieldWithFrame:CGRectMake(APPScreenWidth - 200, 0, 185, cell.height) withPlaceholder:[NSString stringWithFormat:@"转让金额最低%@元,最高%@元",[_dict stringIntForKey:@"transfer_fee"],[_dict stringIntForKey:@"max_transferFee"]]];
                _toSellMoney.text = [_dict stringIntForKey:@"transfer_fee"];
                _toSellMoney.keyboardType = UIKeyboardTypeNumberPad;
                _toSellMoney.delegate = self;
                [cell addSubview:_toSellMoney];
                break;
            case 1:
                switch (indexPath.row) {
                    case 0:
                        cell.detailTextLabel.text = [_dict stringFloatForKey:@"capital"];
                        break;
                    case 1:
                        cell.detailTextLabel.text = [_dict stringFloatForKey:@"investment_income"];
                        break;
                    case 2:
                        //这让费用
                        _toSellLable = [self cellLableWithFrame:CGRectMake(APPScreenWidth - 200, 0, 185, cell.height)];
                        _toSellLable.text = [NSString stringWithFormat:@"-%@",[_dict stringIntForKey:@"transfer_fee"]];
                        [cell addSubview:_toSellLable];
                        break;
                    case 3:
                        cell.detailTextLabel.text = [_dict stringFloatForKey:@"process_fee"];
                        break;
                    case 4:
                        //赎回金额
                        _redeem_moneyLable = [self cellLableWithFrame:CGRectMake(APPScreenWidth - 200, 0, 185, cell.height)];
                        _redeem_moneyLable.text = [_dict stringFloatForKey:@"redeem_money"];
                        [cell addSubview:_redeem_moneyLable];
                        break;
                    case 5:
                        //赎回后账户金额
                        _balance_amountLable = [self cellLableWithFrame:CGRectMake(APPScreenWidth - 200, 0, 185, cell.height)];
                        _balance_amountLable.text = [_dict stringFloatForKey:@"balance_amount"];
                        [cell addSubview:_balance_amountLable];
                        break;
                    default:
                        break;
                }
            default:
                if (indexPath.section == 2) {
                    _payPassword = [Sundry CellTextFieldWithFrame:CGRectMake(APPScreenWidth - 200, 0, 185, cell.height) withPlaceholder:@"请输入支付密码"];
                    _payPassword.keyboardType = UIKeyboardTypeASCIICapable;
                    _payPassword.secureTextEntry = YES;
                    _payPassword.delegate = self;
                    _payPassword.returnKeyType = UIReturnKeyDone;
                    [cell addSubview:_payPassword];
                }
                break;
        }

        
    }
    
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        UIButton *checkbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
        [checkbtn setImage:[UIImage imageNamed:@"checkBox"] forState:UIControlStateNormal];
        [checkbtn  setImage:[UIImage imageNamed:@"checkBoxSelected"] forState:UIControlStateSelected];
        [checkbtn addTarget:self action:@selector(clickCheckBtn:) forControlEvents:UIControlEventTouchDown];
        checkbtn.selected = YES;
        
        UIView *checkBoxView = [[UIView alloc]initWithFrame:CGRectMake((APPScreenWidth - 204)*.5, 10, 204, 22)];
        [checkBoxView addSubview:checkbtn];
        [checkBoxView addSubview:self.JDprotocol];
        
        UILabel *contentLable2 = [[UILabel alloc]initWithFrame:CGRectMake(15, self.JDprotocol.bottom + 10, APPScreenWidth - 30, 0)];
        
        contentLable2.font = [UIFont systemFontOfSize:13.0];
        contentLable2.numberOfLines = 0;
        contentLable2.text = @"注:折让费会额外付给购买此项目的用户，属于您的额外支出，请慎重。";
        contentLable2.textColor = [UIColor jd_globleTextColor];
        
        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:contentLable2.text];
        NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle2 setLineSpacing:4];//调整行间距
        
        [attributedString2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle2 range:NSMakeRange(0, [contentLable2.text length])];
        contentLable2.attributedText = attributedString2;
        
        [contentLable2 sizeToFit];

        
        UIView *footerView = [[UIView alloc]init];
        [footerView addSubview:checkBoxView];
        [footerView addSubview:contentLable2];
        
        UITapGestureRecognizer  *endIngYes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selfDissKeyBoard)];
        [footerView addGestureRecognizer:endIngYes];
        return footerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        return 88;
    }
    return 0.01;
}


- (void)clickCheckBtn:(UIButton *)btn
{
    if (btn.selected == YES) {
        btn.selected = NO;
        _nextBtn.enabled = NO;
    }else
    {
        btn.selected = YES;
        _nextBtn.enabled = YES;
    }
}

- (UILabel *)cellLableWithFrame:(CGRect)frame;
{
    UILabel *lable = [[UILabel alloc]initWithFrame:frame];
    lable.textAlignment = NSTextAlignmentRight;
    lable.textColor = [UIColor jd_globleTextColor];
    lable.font = [UIFont systemFontOfSize:14.0];
    return lable;
}

- (UILabel *)JDprotocol
{
    if (!_JDprotocol) {
        _JDprotocol = [[AttributedLabel alloc]initWithFrame:CGRectMake(22, 4, 204, 22)];
        _JDprotocol.text = @"我同意《简单理财网债权转让协议》";
        //设置lable文字的属性
        [_JDprotocol setFont:[UIFont systemFontOfSize:12.0] fromIndex:0 length:16];
        [_JDprotocol setColor:[UIColor jd_settingDetailColor] fromIndex:4 length:11];
        [_JDprotocol setColor:[UIColor jd_globleTextColor] fromIndex:0 length:4];
        _JDprotocol.backgroundColor = [UIColor clearColor];
        _JDprotocol.userInteractionEnabled = YES;
        [self.JDprotocol addGestureRecognizer:self.tap];
        
    }
    return _JDprotocol;
}

- (UITapGestureRecognizer *)tap
{
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushJDprotocolCtr)];
    }
    return _tap;
}

- (void)pushJDprotocolCtr
{
    HTWebViewController *vc = [[HTWebViewController alloc] init];
    vc.titleStr = @"简单理财网债权转让协议";
    vc.url = HTURL(kRegeitProtocal5);
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (_payPassword.isFirstResponder == NO) {
        if ([string isEqualToString:@""])
        {
            if (textField.text.length != 0) {
                _texting = [textField.text substringToIndex:textField.text.length - 1];
            }
        }else
        {
            _texting = [NSString stringWithFormat:@"%@%@",textField.text,string];
        }
        
        _toSellLable.text = [NSString stringWithFormat:@"-%@",_texting];
        _redeem_moneyLable.text = [NSString stringWithFormat:@"%.2f",[[_dict stringIntForKey:@"capital"] doubleValue] + [[_dict stringFloatForKey:@"investment_income"] doubleValue] - [_texting doubleValue] - [[_dict stringFloatForKey:@"process_fee"] doubleValue]];
        _balance_amountLable.text = [NSString stringWithFormat:@"%.2f",[[_dict stringFloatForKey:@"balance_amount"] doubleValue] - [_texting doubleValue] + [[_dict stringIntForKey:@"transfer_fee"] doubleValue]];
        
        if ([self validateMoney:_texting]||[string isEqualToString:@""]) {
            
            return YES;
        }
        return NO;

    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_payPassword.isFirstResponder == YES) {
        [self ClickAffirmBtn];
    }
    [self.view endEditing:YES];
    return YES;
}

- (BOOL) validateMoney:(NSString *)text
{
    //根据输入数字做出判断
    NSString *emailRegex = @"^[1-9]+([0-9]{0,9})?$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:text];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)selfDissKeyBoard
{
    [self.view endEditing:YES];
}

@end
