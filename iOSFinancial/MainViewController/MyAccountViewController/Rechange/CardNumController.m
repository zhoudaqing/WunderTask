//
//  CardNumController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "CardNumController.h"
#import "LLPaySdk.h"
#import "NSString+IsValidate.h"

@interface CardNumController ()<LLPaySdkDelegate,UITextFieldDelegate>
{
    UITextField *_cardNumTextField;
}

@property (nonatomic, retain) NSMutableDictionary *orderParam;


@end

@implementation CardNumController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadsubViews];
    [self createOrder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadsubViews
{
    UIView *view = [Sundry viewAddBackImgeAndlineNumber:1 withView:self.view];
    [self.view addSubview:view];
    
    _cardNumTextField = [Sundry onBackimgeTextWith:CGRectMake(15, 0, APPScreenWidth - 30, 44) withPlaceholder:@"请输入您的银行卡号"];
    _cardNumTextField.delegate = self;
    _cardNumTextField.keyboardType = UIKeyboardTypeNumberPad;
    [view addSubview:_cardNumTextField];
    
    UIButton *nextBtn = [Sundry BigBtnWithHihtY:view.bottom + 15 withTitle:@"下一步"];
    [nextBtn addTarget:self action:@selector(clickNextBtn) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:nextBtn];
}



-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField == _cardNumTextField) {
        NSString *text = [_cardNumTextField text];
        
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
        string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
            return NO;
        }
        
        text = [text stringByReplacingCharactersInRange:range withString:string];
        text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSString *newString = @"";
        while (text.length > 0) {
            NSString *subString = [text substringToIndex:MIN(text.length, 4)];
            newString = [newString stringByAppendingString:subString];
            if (subString.length == 4) {
                newString = [newString stringByAppendingString:@" "];
            }
            text = [text substringFromIndex:MIN(text.length, 4)];
        }
        
        newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
        
        // 限制长度
        if (newString.length >= 25) {
            return NO;
        }
        
        [_cardNumTextField setText:newString];
        
        return NO;
        
    }
    return YES;
}

// 银行卡号转正常号 － 去除4位间的空格
-(NSString *)bankNumToNormalNum
{
    return [_cardNumTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
}



// 一下为支付相关内容
- (void)clickNextBtn
{
    [self.view endEditing:YES];
    if (_cardNumTextField.text.length < 1) {
        [self showHudAuto:@"请输入银行卡号"];
        [_cardNumTextField becomeFirstResponder];
    }else
    {
        // 唯一卡绑定逻辑
        
        HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString firstRecharge]];
        [request addPostValue:self.mDict[@"money_order"] forKey:@"money"];
        [request addPostValue:[self bankNumToNormalNum] forKey:@"card_no"];
        [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
            if (error) {
                NSString *message = [error stringForKey:@"message"];
                NSString *code = [error stringForKey:@"code"];
                if ([code isEqualToString:@"13005"]) {
                    [self.navigationController popToViewController:self.popVC animated:YES];
                }
                [self showHudErrorView:message];
            }else {
                
                [self notificationLianLian];
               
            }
        } failure:^(YTKBaseRequest *request) {
            
            [self showHudErrorView:PromptTypeError];
            
        }];

    }
    
}

- (void)notificationLianLian
{
    self.orderParam[@"card_no"] = [self bankNumToNormalNum];
    
    LLPayUtil *payUtil = [[LLPayUtil alloc] init];
    
    NSDictionary *signedOrder = [payUtil signedOrderDic:self.orderParam andSignKey:[self partnerKey:self.orderParam[@"oid_partner"]]];
    
    self.sdk = [[LLPaySdk alloc] init];
    self.sdk.sdkDelegate = self;
    /*
     // 切换认证支付与快捷支付，假如并不需要切换，可以不调用这个方法（此方法为老版本使用）
     [LLPaySdk setVerifyPayState:self.bVerifyPayState];
     */
    
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
                           @"no_order":[NSString stringWithFormat:@"%@",self.mDict[@"no_order"]],
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
                                                 @"user_info_dt_register":self.mDict[@"user_info_dt_register"],
                                                 @"frms_ware_category":@"2009",
                                                 @"user_info_mercht_userno":self.mDict[@"user_info_uid"],
                                                 @"user_info_bind_phone":self.mDict[@"user_info_bind_phone"],
                                                 @"user_info_full_name":self.mDict[@"user_info_name"],
                                                 @"user_info_id_type":@"0",
                                                 @"user_info_id_no":self.mDict[@"user_info_no_id_card"],//用户证件号码
                                                 @"user_info_identify_state":@"1",//认证为1
                                                 @"user_info_identify_type":@"3",//身份证远程认证3
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
    
    
    param[@"money_order"] = self.mDict[@"money_order"];
    param[@"acct_name"] = self.mDict[@"user_info_name"];
    param[@"id_no"] = self.mDict[@"user_info_no_id_card"];
    param[@"user_id"] = self.mDict[@"user_info_uid"];
    param[@"oid_partner"] = @"201505051000312505";
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
            
            NSString* result_pay = dic[@"result_pay"];
            if ([result_pay isEqualToString:@"SUCCESS"])
            {
                //
                NSString *payBackAgreeNo = dic[@"agreementno"];
                _cardNumTextField.text = payBackAgreeNo;
                
                //支付成功之后的操作
                [User sharedUser].accountBalance = [NSString stringWithFormat:@"%.2f",[self.mDict[@"money_order"] doubleValue] + [[User sharedUser].accountBalance doubleValue]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:__USER_ACCOUNT_REFRESH_NOTIFACTION object:nil];
                
                if ([User sharedUser].isInVestRecharge) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }

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
            //可以做测试使
//            [[NSNotificationCenter defaultCenter] postNotificationName:__USER_ACCOUNT_REFRESH_NOTIFACTION object:nil];
//            if ([User sharedUser].isInVestRecharge) {
//                [self.navigationController popToRootViewControllerAnimated:YES];
//                                                    }
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
    [[[UIAlertView alloc] initWithTitle:@"结果"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:@"确认"
                      otherButtonTitles:nil] show];
}

- (void)addSafeCard
{
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString lianlianAddCard]];
    
    [request addPostValue:self.mDict[@"money_order"] forKey:@"money"];
    [request addPostValue:self.orderParam[@"card_no"] forKey:@"no_card"];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudManaual:message];
        }else {
            
        }
    } failure:^(YTKBaseRequest *request) {
        [self showHudErrorView:PromptTypeError];
        
    }];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
