//
//  WithdrawViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/2.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "WithdrawViewController.h"
#import "ZHPickView.h"
#import "NSString+IsValidate.h"
#import "NSString+Size.h"
#import "WithdrawBankViewController.h"

@interface WithdrawViewController ()<ZHPickViewDelegate, UITextFieldDelegate,WithDrawBankDeleagte>
{
    NSIndexPath *_indexPath;
    NSDictionary *_cardIDDic;
    NSString *_cardID;
    WithdrawBankViewController *_withdraw;
    BOOL isWithDrawBank;
}
@property (nonatomic)UITextField *moneyTextField;

@property (nonatomic)UITextField *payPasswordTextField;

@property (nonatomic) ZHPickView *pickview;

@end

@implementation WithdrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addNextBtn];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSDictionary *dict = self.cardInfoArray[0];
    //判断唯一卡银行信息是否完善
    if ([dict[@"is_uniq"] intValue] ==1) {
        if (([[dict stringForKey:@"bank_branch"] isEqualToString:@""]||[[dict stringForKey:@"bank_city"] isEqualToString:@""])&&!isWithDrawBank) {
            
            NSString *prompt = HTSTR(@"完善银行卡信息后可以提现");
            [self alertViewWithButtonsBlock:^NSArray *{
                return @[@"去完善"];
            } andHandleBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    _withdraw = [[WithdrawBankViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
                    _withdraw.title = @"提现银行卡";
                    _withdraw.Wdelegate = self;
                    _withdraw.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:_withdraw animated:YES];
                    [self performSelector:@selector(withDrawClick) withObject:nil afterDelay:1.0f];
                }else
                {
                    [self dismissViewController];
                }
                
            } andMessage:prompt];
            
                    }
    }

}

// MARK:  如果银行卡信息部完整执行操作
- (void)withDrawClick
{
    [_withdraw clcikeditBtn:nil];
}

#pragma Wdelegate
- (void)selfHelpWithdraw
{
    isWithDrawBank = YES;
}

// MARK:  添加提交按钮
- (void)addNextBtn
{
    UIButton *btn = [Sundry BigBtnWithHihtY:216 withTitle:@"提交"];
    [btn addTarget:self action:@selector(clickNextBtn) forControlEvents:UIControlEventTouchDown];
    [self.tableView addSubview:btn];
}

// MARK:  点击提交按钮
- (void)clickNextBtn
{
    [self.view endEditing:YES];
    [self.pickview  remove];
    if (!_cardID) {
        [self showHudAuto:@"请选择银行"];
    }else if(self.moneyTextField.text.length < 1 || [self.moneyTextField.text doubleValue]<=0 ){
        [self showHudAuto:@"请输入正确的提现金额"];
        [self.moneyTextField becomeFirstResponder];
        
    }else if([self.moneyTextField.text doubleValue] > [[User sharedUser].accountBalance doubleValue]){
        
        [self showHudAuto:@"提现金额大于账户余额"];
        
    }else if(![self.payPasswordTextField.text isValidatePass]){
        [self showHudAuto:@"请输入正确的支付密码"];
        [self.payPasswordTextField becomeFirstResponder];
    }else{
        [self showHudManaual:@"正在提交请稍后...."];
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString secureWithdraw]];
    [request addPostValue:_cardID forKey:@"card_id"];
    [request addPostValue:self.moneyTextField.text forKey:@"money"];
    [request addPostValue:self.payPasswordTextField.text forKey:@"pay_pwd"];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        [self removeHudInManaual];
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
            
        }else {
            [self showHudSuccessView:@"提现申请提交成功!"];
            [User sharedUser].accountBalance = [NSString stringWithFormat:@"%.2f",[self.money doubleValue] - [self.moneyTextField.text doubleValue]];
            [[NSNotificationCenter defaultCenter] postNotificationName:__USER_ACCOUNT_REFRESH_NOTIFACTION object:nil];
            [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:.8f];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self removeHudInManaual];
        [self showHudErrorView:PromptTypeError];
    }];

    }
}

#pragma -TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else
    {
        return 3;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cellIdentifier";
    
    HTBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[HTBaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.textLabel.textColor = [UIColor jd_globleTextColor];
        switch (indexPath.section) {
            case 0:
            {
                cell.textLabel.text = @"选择银行卡";
                if ([self cardInfo].count == 1) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self cardInfo][0]];
                }else
                {
                    cell.detailTextLabel.text = @"请选择";
                }
            }
                return cell;
            case 1:
            {
                switch (indexPath.row) {
                    case 0:
                    {
                        cell.textLabel.text = @"账户余额（元）";
                        cell.detailTextLabel.textColor = [UIColor jd_settingDetailColor];
                        cell.detailTextLabel.text = [[User sharedUser].accountBalance formatNumberString];
                    }
                        return cell;
                        case 1:
                    {
                        self.moneyTextField.frame = CGRectMake(0, 0, APPScreenWidth -15, cell.height);
                        [cell addSubview:self.moneyTextField];
                    }
                        return cell;
                    default:
                    {
                        self.payPasswordTextField.frame = CGRectMake(0, 0, APPScreenWidth -15, cell.height);
                        [cell addSubview:self.payPasswordTextField];
                    }
                        return cell;
                }
            }
                
            default:
                break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.pickview  remove];
    [self.view endEditing:YES];
    if (indexPath.section == 0 && indexPath.row ==0) {
        _indexPath = indexPath;
        [self.pickview show];
    }}


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

#pragma PickView
// 组合银行名称和尾号
- (NSArray *)cardInfo
{
    NSMutableArray *mArray = [[NSMutableArray alloc]init];
    _cardIDDic = [[NSMutableDictionary alloc]init];
    for (NSDictionary *dic in self.cardInfoArray) {
        
        NSString *cardNum = [dic stringForKey:@"bank_card_num"];
        cardNum = [cardNum substringWithRange:NSMakeRange(cardNum.length-4, 4)];
        cardNum = [NSString stringWithFormat:@"%@  尾号%@",[dic stringForKey:@"bank_name"],cardNum];
        [mArray addObject: cardNum];
        [_cardIDDic setValue:dic[@"id"] forKey:cardNum];
        if (mArray.count == 1) {
            _cardID = [_cardIDDic stringIntForKey:cardNum];
        }else
        {
            _cardID = nil;
        }
    }
    return mArray;
}

- (ZHPickView *)pickview
{
    if (!_pickview) {
        _pickview = [[ZHPickView alloc] initPickviewWithPlistName:self.tableView isHaveNavControler:NO withArray:[self cardInfo]];
        [_pickview setPickViewColer:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1]];
        [_pickview setToolbarTintColor:[UIColor whiteColor]];
        _pickview.delegate = self;
    }
    return _pickview;
}

- (void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString{
    
    UITableViewCell * cell=[self.tableView cellForRowAtIndexPath:_indexPath];
    cell.detailTextLabel.text=resultString;
    _cardID =  _cardIDDic[resultString];
}


#pragma UIScrollViewDelegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    [self.pickview remove];
}


// 懒加载
- (UITextField *)moneyTextField
{
    if (!_moneyTextField) {
        _moneyTextField = [[UITextField alloc]init];
        _moneyTextField.placeholder = @"请输入提现金额";
        _moneyTextField.textAlignment = NSTextAlignmentRight;
        _moneyTextField.font = [UIFont systemFontOfSize:15.0];
        _moneyTextField.keyboardType = UIKeyboardTypeDecimalPad;
        _moneyTextField.delegate  = self;
    }
    return _moneyTextField;
}

- (UITextField *)payPasswordTextField
{
    if (!_payPasswordTextField) {
        _payPasswordTextField = [[UITextField alloc]init];
        _payPasswordTextField.placeholder = @"请输入支付密码";
        _payPasswordTextField.textAlignment = NSTextAlignmentRight;
        _payPasswordTextField.font = [UIFont systemFontOfSize:15.0];
        _payPasswordTextField.secureTextEntry = YES;
        _payPasswordTextField.delegate = self;
    }
    return _payPasswordTextField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.moneyTextField.isFirstResponder == YES) {
        if ([string isNumber] || [string isEqualToString:@"."] || [string isEqualToString:@""]) {
            int point = 0;
            NSString *str = [NSString stringWithFormat:@"%@%@",textField.text,string];
            for (int i = 0; i< str.length; i++) {
                if ([[str substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"."]) {
                    point++;
                }
            }
            
            if (point > 1) {
                return NO;
            }
            if (point == 1) {
                NSRange r = [str rangeOfString:@"."];
                if (str.length - r.location > 3) {
                    return NO;
                }
                
            }
            return YES;
            
        }
        
        return NO;

    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.moneyTextField.isEditing == YES ) {
        [self.payPasswordTextField becomeFirstResponder];
    }else if (self.payPasswordTextField.isEditing == YES) {
        [self clickNextBtn];
    }
    
    return YES;
}
@end
