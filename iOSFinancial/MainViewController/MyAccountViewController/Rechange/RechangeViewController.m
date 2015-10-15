//
//  RechangeViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "RechangeViewController.h"
#import "AttributedLabel.h"
#import "HTWebViewController.h"
#import "RechangeAffirmViewController.h"
#import "NameCertificationController.h"
#import "HTNavigationController.h"
#import "SafeExplainViewController.h"
#import "NSString+IsValidate.h"
#import "UIBarButtonExtern.h"

@interface RechangeViewController()<UITextFieldDelegate,LLPaySdkDelegate>
{
    NSDictionary *_bankList;
    NSMutableDictionary *_mDict;
}

@property (nonatomic) UITextField *moneyTextField;

@property (nonatomic) AttributedLabel *jdProtocolLable;

@property (nonatomic) AttributedLabel *jdStipulateLable;

@property (nonatomic) AttributedLabel *jdStipulateLableIphone61;

@property (nonatomic) AttributedLabel *jdStipulateLableIphone62;

@property (nonatomic) AttributedLabel *jdStipulateLableIphone6L1;

@property (nonatomic) AttributedLabel *jdStipulateLableIphone6L2;

@property (nonatomic) UITapGestureRecognizer *tap;

@property (nonatomic) UITapGestureRecognizer *tap1;

@property (nonatomic) UIButton *nextBtn;

@property (nonatomic) NSDictionary *safeCarDict;

@property (nonatomic) UIView *footerView;

@property (nonatomic) UIView *cardView;

@property (nonatomic) UIView *safeView;

@property (nonatomic, retain) NSMutableDictionary *orderParam;

@end

@implementation RechangeViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self judgeViewStatus];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"充值";
    [self.tableView removeFromSuperview];

    self.navigationItem.rightBarButtonItem = [UIBarButtonExtern buttonWithTitle:@"银行限额" target:self andSelector:@selector(rechargeLimitProtocal)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selfDissmiss) name:__USER_ACCOUNT_REFRESH_NOTIFACTION object:nil];
    
    [self addKeyboardNotifaction];
}

//  充值限额
- (void)rechargeLimitProtocal
{
    HTWebViewController *controller = [[HTWebViewController alloc] init];
    controller.titleStr = @"银行限额";
    controller.url = HTURL(kRechargeProtocal4);
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)selfDissmiss
{
    if (![User sharedUser].isInVestRecharge) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)judgeViewStatus
{
    switch ([User sharedUser].real_name_status) {
        case -1:
        {
            //认证超限
            [self showPromptMessage];
        }
            break;
        case 0:
        {
            //未认证
            [self showPromptMessage:@"您尚未进行实名认证，实名认证后可进行充值,是否再次实名认证？"];
        }
            break;
        case 3:
        {
            //认证失败
            [self showPromptMessage:@"您的实名认证失败,实名认证后可进行充值,是否再次实名认证？"];
        }
            break;
        default:
            //判断是否是首次充值
            [self showLoadingViewWithState:LoadingStateLoading];
            [self isFirstRecharge];
            
            __weakSelf;
            [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state){
                [weakSelf isFirstRecharge];
            }];
            break;
    }
}

//认证超限
- (void)showPromptMessage
{
    NSString *prompt = HTSTR(@"您的实名认证次数超限不能进行充值,如有疑问请联系客服电话:%@, 是否拨打？",kServicePhone_f);
    [self alertViewWithButtonsBlock:^NSArray *{
        return @[@"拨打"];
    } andHandleBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            // 拨打电话
            NSString *telphone = HTSTR(@"tel://%@",kServicePhone);
            [[UIApplication sharedApplication] openURL:HTURL(telphone)];
            [self  dismissViewController];
        }else
        {
            [self  dismissViewController];
        }
        
    } andMessage:prompt];
}

// 未认证或者认证失败时调用
- (void)showPromptMessage:(NSString *)message
{
    NSString *prompt = HTSTR(@"%@", message);
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

- (void)isFirstRecharge
{
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString safeCard]];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self removeLoadingView];
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        if (error) {
            
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
            
        }else {
            
            NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
            [self parseCardList:result];
            
        }
        
    } failure:^(YTKBaseRequest *request) {
        
        [self showLoadingViewWithState:LoadingStateNetworkError];
        [self showHudErrorView:PromptTypeError];
        
    }];

}

- (void)parseCardList:(NSDictionary *)dict
{
    _bankList = dict;
    if (_bankList.count ==0) {
        // 进行是首次支付
        [self.view addSubview:self.tableView];
        
    }else{
        //已有绑定安全卡
        self.safeCarDict = dict;
        [self.view addSubview:self.tableView];
    }
}

#pragma mark - TableView

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!(_bankList.count ==0)) {
        
        //进行 N次支付
        return 2;
        
    }else
    {
        // 进行是首次支付
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:return 1;
        case 1:return 1;
        default:return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"accountIdentifier";
    
    HTBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[HTBaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
        if (indexPath.section>0 && !(_bankList.count == 0)) {
            
            self.moneyTextField.frame = CGRectMake(0, 0, APPScreenWidth-15, cell.height);
            [cell addSubview:self.moneyTextField];
            
        }else
        {
            self.moneyTextField.frame = CGRectMake(0, 0, APPScreenWidth-15, cell.height);
            [cell addSubview:self.moneyTextField];
        }
        if (indexPath.section == 0 && !(_bankList.count == 0) ) {
            [cell addSubview:self.cardView];
        }
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1 && !(_bankList.count ==0))
    {
        return 0.01;
    }
    return 15.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
   
    if (section == 0 && (_bankList.count ==0))
    {
        return 119.0;
    }
    if (section == 1 && !(_bankList.count ==0)) {
        return 119.0;
    }
    
    if (section == 0 && !(_bankList.count ==0))
    {
        return 38;
    }
    
    return .01;

}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
  
    if ((section == 0 && (_bankList.count == 0)) ||(section == 1 && !(_bankList.count == 0))) {
        return self.footerView;
    }
    if (section == 0 && !(_bankList.count == 0)) {
        return self.safeView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!(_bankList.count == 0)&& indexPath.section == 0 && indexPath.row == 0) {
        return 60;
    }
    return 44;
}

- (UIView *)cardView
{
    if (!_cardView) {
        _cardView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APPScreenWidth, 60.0)];
        
        UIImageView *bankImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 40, 40)];
        [bankImage setImage:[UIImage  imageNamed:[_bankList stringForKey:@"bank_code_llapy"]]];
        [_cardView addSubview:bankImage];
        
        UILabel *bankName = [[UILabel alloc]initWithFrame:CGRectMake(bankImage.right + 15, 21, APPScreenWidth, 18)];
        bankName.text = [_bankList stringForKey:@"bank_name"];
        [_cardView addSubview:bankName];
        
        UILabel *bankNum = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, APPScreenWidth -15, 20)];
        bankNum.text = [NSString stringWithFormat:@"尾号%@",[_bankList stringForKey:@"card_no"]];
        bankNum.textAlignment = NSTextAlignmentRight;
        [_cardView addSubview:bankNum];
        
    }
    return _cardView;
}

- (UIView *)footerView
{
    if (!_footerView) {
        _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,APPScreenWidth, 119.0)];
        _footerView.backgroundColor = HTClearColor;
        [_footerView addSubview:self.jdProtocolLable];
        if (is35Inch || is4Inch) {
            [_footerView addSubview:self.jdStipulateLable];
        }else if (is47Inch)
        {
            [_footerView addSubview:self.jdStipulateLableIphone61];
            [_footerView addSubview:self.jdStipulateLableIphone62];
        }else
        {
            [_footerView addSubview:self.jdStipulateLableIphone6L1];
            [_footerView addSubview:self.jdStipulateLableIphone6L2];
        }
        [_footerView addSubview:self.nextBtn];

    }
    return _footerView;
}

- (UIView *)safeView
{
    if (!_safeView) {
        _safeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APPScreenWidth, 28)];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 12, 16, 20)];
        [imageView setImage:[UIImage imageNamed:@"safe"]];
        [_safeView addSubview:imageView];
        
        UILabel *lable =[[UILabel alloc]initWithFrame:CGRectMake(imageView.right + 4, imageView.top + 1, APPScreenWidth, 14)];
        lable.text = @"此卡为简单理财网“安全卡”";
        lable.font = [UIFont systemFontOfSize:14.0];
        lable.textColor = [UIColor jd_globleTextColor];
        [_safeView addSubview:lable];
    }
    return _safeView;
}

- (UITextField *)moneyTextField
{
    if (!_moneyTextField) {
        _moneyTextField = [[UITextField alloc]init];
        _moneyTextField.placeholder = @"请输入充值金额";
        _moneyTextField.font = [UIFont systemFontOfSize:15.0];
        _moneyTextField.textAlignment = NSTextAlignmentRight;
        _moneyTextField.keyboardType = UIKeyboardTypeDecimalPad;
        _moneyTextField.delegate = self;
    }
    return _moneyTextField;
}

- (UILabel *)jdProtocolLable
{
    if (!_jdProtocolLable) {
        _jdProtocolLable = [[AttributedLabel alloc]initWithFrame:CGRectMake(10,10, 300, 15)];
        _jdProtocolLable.text = @"充值代表你同意简单理财网投资信息咨询与管理协议";
        //设置lable文字的属性
        _jdProtocolLable.numberOfLines = 0;
        [_jdProtocolLable setColor:[UIColor orangeColor] fromIndex:7 length:16];
        [_jdProtocolLable setColor:[UIColor jd_globleTextColor] fromIndex:0 length:7];
        [_jdProtocolLable setFont:[UIFont systemFontOfSize:13] fromIndex:0 length:23];
        [_jdProtocolLable setStyle:kCTUnderlineStyleSingle fromIndex:7 length:16];
        _jdProtocolLable.backgroundColor = [UIColor clearColor];
        _jdProtocolLable.userInteractionEnabled = YES;
        [self.jdProtocolLable addGestureRecognizer:self.tap];
        
    }
    return _jdProtocolLable;
}

- (UILabel *)jdStipulateLable
{
    if (!_jdStipulateLable) {
        _jdStipulateLable = [[AttributedLabel alloc]initWithFrame:CGRectMake(10,self.jdProtocolLable.bottom + 10, APPScreenWidth, 15.0)];
        _jdStipulateLable.text = @"及简单理财资金管理规定";
        //设置lable文字的属性
        [_jdStipulateLable setColor:[UIColor orangeColor] fromIndex:1 length:10];
        [_jdStipulateLable setColor:[UIColor jd_globleTextColor] fromIndex:0 length:1];
        [_jdStipulateLable setFont:[UIFont systemFontOfSize:13] fromIndex:0 length:11];
        [_jdStipulateLable setStyle:kCTUnderlineStyleSingle fromIndex:1 length:10];
        _jdStipulateLable.backgroundColor = [UIColor clearColor];
        _jdStipulateLable.userInteractionEnabled = YES;
        [self.jdStipulateLable addGestureRecognizer:self.tap1];
        
    }
    return _jdStipulateLable;
}

- (UILabel *)jdStipulateLableIphone61
{
    if (!_jdStipulateLableIphone61) {
        _jdStipulateLableIphone61 = [[AttributedLabel alloc]initWithFrame:CGRectMake(self.jdProtocolLable.right, 10, 169, 15)];
        _jdStipulateLableIphone61.text = @"及简单理";
        //设置lable文字的属性
        [_jdStipulateLableIphone61 setColor:[UIColor orangeColor] fromIndex:1 length:3];
        [_jdStipulateLableIphone61 setColor:[UIColor jd_globleTextColor] fromIndex:0 length:1];
        [_jdStipulateLableIphone61 setFont:[UIFont systemFontOfSize:13] fromIndex:0 length:4];
        [_jdStipulateLableIphone61 setStyle:kCTUnderlineStyleSingle fromIndex:1 length:3];
        _jdStipulateLableIphone61.backgroundColor = [UIColor clearColor];
        _jdStipulateLableIphone61.userInteractionEnabled = YES;
        [self.jdStipulateLableIphone61 addGestureRecognizer:self.tap1];
        
    }
    return _jdStipulateLableIphone61;
}

- (UILabel *)jdStipulateLableIphone62
{
    if (!_jdStipulateLableIphone62) {
        _jdStipulateLableIphone62 = [[AttributedLabel alloc]initWithFrame:CGRectMake(10, self.jdProtocolLable.bottom + 10, 169, 15)];
        _jdStipulateLableIphone62.text = @"财资金管理规定";
        //设置lable文字的属性
        [_jdStipulateLableIphone62 setColor:[UIColor orangeColor] fromIndex:0 length:7];
        [_jdStipulateLableIphone62 setFont:[UIFont systemFontOfSize:13] fromIndex:0 length:7];
        [_jdStipulateLableIphone62 setStyle:kCTUnderlineStyleSingle fromIndex:0 length:7];
        _jdStipulateLableIphone62.backgroundColor = [UIColor clearColor];
        _jdStipulateLableIphone62.userInteractionEnabled = YES;
        [self.jdStipulateLableIphone62 addGestureRecognizer:self.tap1];
        
    }
    return _jdStipulateLableIphone62;
}
- (UILabel *)jdStipulateLableIphone6L1
{
    if (!_jdStipulateLableIphone6L1) {
        _jdStipulateLableIphone6L1 = [[AttributedLabel alloc]initWithFrame:CGRectMake(self.jdProtocolLable.right, 10, 169, 15)];
        _jdStipulateLableIphone6L1.text = @"及简单理财资金";
        //设置lable文字的属性
        [_jdStipulateLableIphone6L1 setColor:[UIColor orangeColor] fromIndex:1 length:6];
        [_jdStipulateLableIphone6L1 setColor:[UIColor  jd_globleTextColor] fromIndex:0 length:1];
        [_jdStipulateLableIphone6L1 setFont:[UIFont systemFontOfSize:13] fromIndex:0 length:7];
        [_jdStipulateLableIphone6L1 setStyle:kCTUnderlineStyleSingle fromIndex:1 length:6];
        _jdStipulateLableIphone6L1.backgroundColor = [UIColor clearColor];
        _jdStipulateLableIphone6L1.userInteractionEnabled = YES;
        [self.jdStipulateLableIphone6L1 addGestureRecognizer:self.tap1];
        
    }
    return _jdStipulateLableIphone6L1;
}

- (UILabel *)jdStipulateLableIphone6L2
{
    if (!_jdStipulateLableIphone6L2) {
        _jdStipulateLableIphone6L2 = [[AttributedLabel alloc]initWithFrame:CGRectMake(10, self.jdProtocolLable.bottom + 10, 169, 15)];
        _jdStipulateLableIphone6L2.text = @"管理规定";
        //设置lable文字的属性
        [_jdStipulateLableIphone6L2 setColor:[UIColor orangeColor] fromIndex:0 length:4];
        [_jdStipulateLableIphone6L2 setFont:[UIFont systemFontOfSize:13] fromIndex:0 length:4];
        [_jdStipulateLableIphone6L2 setStyle:kCTUnderlineStyleSingle fromIndex:0 length:4];
        _jdStipulateLableIphone6L2.backgroundColor = [UIColor clearColor];
        _jdStipulateLableIphone6L2.userInteractionEnabled = YES;
        [self.jdStipulateLableIphone6L2 addGestureRecognizer:self.tap1];
        
    }
    return _jdStipulateLableIphone6L2;
}


- (UITapGestureRecognizer *)tap
{
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushJDprotocolCtr)];
    }
    return _tap;
}

- (UITapGestureRecognizer *)tap1
{
    
    _tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushJDprotocolCtr1)];
    return _tap1;
}

- (void)pushJDprotocolCtr
{
    HTWebViewController *vc = [[HTWebViewController alloc] init];
    vc.titleStr = @"简单理财网投资信息咨询与管理协议";
    vc.url = HTURL(kRegeitProtocal2);
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushJDprotocolCtr1
{
    HTWebViewController *vc = [[HTWebViewController alloc] init];
    vc.titleStr = @"简单理财网资金管理规定";
    vc.url = HTURL(kRegeitProtocal3);
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIButton *)nextBtn
{
    if (!_nextBtn) {
        
        _nextBtn = [Sundry BigBtnWithHihtY:self.jdStipulateLable.bottom + 10 withTitle:@"下一步"];
        [_nextBtn addTarget:self action:@selector(clickNextBtn) forControlEvents:UIControlEventTouchDown];
        
    }
    return _nextBtn;
}
- (void)clickNextBtn
{
    if ([self.moneyTextField.text doubleValue]>0) {
        
    [self showHudWaitingView:@"加载中..."];
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString firstRecharge]];
    
    [request addPostValue:self.moneyTextField.text forKey:@"money"];

    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self removeHudInManaual];
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
            
        }else {
            
            _mDict =[[NSMutableDictionary alloc]init];
            [_mDict addEntriesFromDictionary:[request.responseJSONObject dictionaryForKey:@"result"]];
            [_mDict setObject:_moneyTextField.text forKey:@"money_order"];
            
            if (_bankList.count == 0 ) {
                SafeExplainViewController *safeCtr = [[SafeExplainViewController alloc]init];
                safeCtr.title = @"安全说明";
                safeCtr.dict = _mDict;
                safeCtr.popVC = self;
                [self.navigationController pushViewController:safeCtr animated:YES];
            }
            else{
                [self payforMoney];
            }
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self removeHudInManaual];

        [self showHudErrorView:PromptTypeError];
        
    }];
        
    }else
    {
        [self showHudErrorView:@"请输入有效金额"];
        [self.moneyTextField becomeFirstResponder];
    }

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self clickNextBtn];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
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




//以下全部是支付相关
- (void)payforMoney
{
    [self createOrder];
    LLPayUtil *payUtil = [[LLPayUtil alloc] init];
    
    NSDictionary *signedOrder = [payUtil signedOrderDic:self.orderParam andSignKey:[self partnerKey:self.orderParam[@"oid_partner"]]];
    
    self.sdk = [[LLPaySdk alloc] init];
    self.sdk.sdkDelegate = self;
    
    //认证支付、快捷支付、预授权切换，0快捷 1认证 2预授权。假如不需要切换，可以不调用这个方法
    [LLPaySdk setLLsdkPayState:1];
    
    
    [self.sdk presentPaySdkInViewController:self withTraderInfo:signedOrder];
    
    
}



- (void)createOrder
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *simOrder = [dateFormater stringFromDate:[NSDate date]];
    
    
    NSString *signType = @"MD5";    // MD5 || RSA
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    [param setDictionary:@{
                           @"sign_type":signType,
                           //签名方式	partner_sign_type	是	String	RSA  或者 MD5
                           @"busi_partner":@"101001",
                           //商户业务类型	busi_partner	是	String(6)	虚拟商品销售：101001
                           @"dt_order":simOrder,
                           //商户订单时间	dt_order	是	String(14)	格式：YYYYMMDDH24MISS  14位数字，精确到秒
                           //                           @"money_order":@"0.10",
                           //交易金额	money_order	是	Number(8,2)	该笔订单的资金总额，单位为RMB-元。大于0的数字，精确到小数点后两位。 如：49.65
                           @"notify_url":@"https://www.jiandanlicai.com/notice/llpay",
                           //服务器异步通知地址	notify_url	是	String(64)	连连钱包支付平台在用户支付成功后通知商户服务端的地址，如：http://payhttp.xiaofubao.com/back.shtml
                           @"no_order":[NSString stringWithFormat:@"%@",_mDict[@"no_order"]],
                           //商户唯一订单号	no_order	是	String(32)	商户系统唯一订单号
                           @"name_goods":@"订单名",
                           //商品名称	name_goods	否	String(40)
                           @"info_order":simOrder,
                           //订单附加信息	info_order	否	String(255)	商户订单的备注信息
                           @"valid_order":@"10080",
                           //分钟为单位，默认为10080分钟（7天），从创建时间开始，过了此订单有效时间此笔订单就会被设置为失败状态不能再重新进行支付。
                           //                           @"shareing_data":@"201412030000035903^101001^10^分账说明1|201310102000003524^101001^11^分账说明2|201307232000003510^109001^12^分账说明3"
                           // 分账信息数据 shareing_data  否 变(1024)
                           
                           //                           @"risk_item":@"{\"user_info_bind_phone\":\"13958069593\",\"user_info_dt_register\":\"20131030122130\"}",
                           //风险控制参数 否 此字段填写风控参数，采用json串的模式传入，字段名和字段内容彼此对应好
                          @"risk_item" : [LLPayUtil jsonStringOfObj:@{
                                                                      @"user_info_dt_register":_mDict[@"user_info_dt_register"],
                                                                      @"frms_ware_category":@"2009",
                                                                      @"user_info_mercht_userno":_mDict[@"user_info_uid"],
                                                                      @"user_info_bind_phone":_mDict[@"user_info_bind_phone"],
                                                                      @"user_info_full_name":_mDict[@"user_info_name"],
                                                                      @"user_info_id_type":@"0",//0代表身份证或者企业经营证件号码
                                                                      @"user_info_id_no":_mDict[@"user_info_no_id_card"],//用户证件号码
                                                                      @"user_info_identify_state":@"1",//认证为1
                                                                      @"user_info_identify_type":@"3"//3身份证远程认证
                                                                      }],
                           //                           @"user_id":@"",
                           //商户用户唯一编号 否 该用户在商户系统中的唯一编号，要求是该编号在商户系统中唯一标识该用户
                           // user_id，一个user_id标示一个用户
                           // user_id为必传项，需要关联商户里的用户编号，一个user_id下的所有支付银行卡，身份证必须相同
                           // demo中需要开发测试自己填入user_id, 可以先用自己的手机号作为标示，正式上线请使用商户内的用户编号
                           
                           //                           @"id_no":@"339005198403100026",
                           //证件号码 id_no 否 String
                           //                           @"acct_name":@"测试号",
                           //银行账号姓名 acct_name 否 String
                           //                           @"flag_modify":@"1",
                           //修改标记 flag_modify 否 String 0-可以修改，默认为0, 1-不允许修改 与id_type,id_no,acct_name配合使用，如果该用户在商户系统已经实名认证过了，则在绑定银行卡的输入信息不能修改，否则可以修改
                           //                           @"card_no":@"6227001540670034271",
                           //银行卡号 card_no 否 银行卡号前置，卡号可以在商户的页面输入
                           //                           @"no_agree":@"2014070900123076",
                           //签约协议号 否 String(16) 已经记录快捷银行卡的用户，商户在调用的时候可以与pay_type一块配合使用
                           }];
    
    
    param[@"acct_name"] = _mDict[@"user_info_name"];
    param[@"id_no"] = _mDict[@"user_info_no_id_card"];
    param[@"user_id"] = _mDict[@"user_info_uid"];
    param[@"oid_partner"] = @"201505051000312505";
    param[@"no_agree"] = _bankList[@"no_agree"];
    param[@"money_order"] = self.moneyTextField.text;
    self.orderParam = param;
}

- (NSString*)partnerKey:(NSString*)oid_partner{
    
    return @"2b028b0990ddc3cc15476d5d21f467cf";
}

- (void)paymentEnd:(LLPayResult)resultCode withResultDic:(NSDictionary*)dic
{
    NSString *msg = @"支付异常";
    switch (resultCode) {
        case kLLPayResultSuccess:
        {
            msg = @"支付成功";
            //支付成功之后的操作
            NSString* result_pay = dic[@"result_pay"];
            
            [User sharedUser].accountBalance = [NSString stringWithFormat:@"%.2f",[self.moneyTextField.text doubleValue] + [[User sharedUser].accountBalance doubleValue]];
            [[NSNotificationCenter defaultCenter] postNotificationName:__USER_ACCOUNT_REFRESH_NOTIFACTION object:nil];
            
            if ([User sharedUser].isInVestRecharge) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            if ([result_pay isEqualToString:@"SUCCESS"])
            {
                //支付成功之后的操作
                            }
            else if ([result_pay isEqualToString:@"PROCESSING"])
            {
                msg = @"支付单处理中";
            }
            else if ([result_pay isEqualToString:@"FAILURE"])
            {
                msg = @"支付单失败";
            }
            else if ([result_pay isEqualToString:@"REFUND"])
            {
                msg = @"支付单已退款";
            }
        }
            break;
        case kLLPayResultFail:
        {
            msg = @"支付失败";
        }
            break;
        case kLLPayResultCancel:
        {
            msg = @"支付取消";
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
            break;
        case kLLPayResultInitError:
        {
            msg = @"sdk初始化异常";
        }
            break;
        case kLLPayResultInitParamError:
        {
            msg = dic[@"ret_msg"];
        }
            break;
        default:
            break;
    }
    
    /*
    [[[UIAlertView alloc] initWithTitle:@"结果"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:@"确认"
                      otherButtonTitles:nil] show];
     */
    
    [self showAlert:msg];
}


@end
