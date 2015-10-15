//
//  AddCardViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/28.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "AddCardViewController.h"
#import "ZHPickView.h"

@interface AddCardViewController ()<UITextFieldDelegate,ZHPickViewDelegate>
{
    UIButton *_nextBtn;
    NSString *_cardID;
}
@property (nonatomic) UITextField *cardNumber;

@property (nonatomic) UITextField *cardCity;

@property (nonatomic) UITextField *cardBank;

@property (nonatomic) UIView *nameAndDetail;

@property (nonatomic) ZHPickView *pickview;

@property (nonatomic) NSDictionary *cardIdInfo;

@property(nonatomic,strong)NSIndexPath *indexPath;

@end

@implementation AddCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNextBtn];
}

- (void)addNextBtn
{
    _nextBtn = [Sundry BigBtnWithHihtY:286.0 withTitle:@"提交"];
    [self.tableView addSubview:_nextBtn];
    [_nextBtn setBackgroundColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1]];
    [_nextBtn addTarget:self action:@selector(clickNextBtn) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickNextBtn
{
    if (isEmpty(_cardID)) {
        [self showHudAuto:@"请选择银行"];
        [self.view endEditing:YES];
    }else if (isEmpty(_cardNumber.text))
    {
        [_cardNumber becomeFirstResponder];
        [self showHudAuto:@"请输入正确的银行卡号"];
    }else {
    
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString addBankCard]];
    [request addPostValue:_cardID forKey:@"bank_card_type_id"];
    [request addPostValue:self.cardNumber.text forKey:@"bank_card_num"];
    [request addPostValue:self.cardBank.text forKey:@"bank_branch"];
    [request addPostValue:self.cardCity.text forKey:@"bank_city"];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
            
        }else {
            [self showHudSuccessView:@"恭喜~银行卡添加成功"];
            [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:.8f];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self showHudErrorView:PromptTypeError];
    }];
    }
}
#pragma -TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"addCardIdentifier";
    
    HTBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[HTBaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    switch (indexPath.section) {
        case 0:
        {
            [cell addSubview:self.nameAndDetail];
            cell.frame = cell.frame;
        }
            break;
            
        default:
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = @"选择银行";
                    cell.detailTextLabel.text = @"请选择";
                }
                    break;
                case 1:
                {
                    [cell addSubview:self.cardNumber];
                    self.cardNumber.frame = CGRectMake(0, 0, APPScreenWidth-15, cell.height);
                }
                    break;
                case 2:
                {
                    [cell addSubview:self.cardCity];
                    self.cardCity.frame = CGRectMake(0, 0, APPScreenWidth-15, cell.height);
                }
                    break;
                case 3:
                {
                    [cell addSubview:self.cardBank];
                    self.cardBank.frame = CGRectMake(0, 0, APPScreenWidth-15, cell.height);
                }
                    break;
                
            }
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    [_pickview remove];

    if (indexPath.section == 1 && indexPath.row ==0) {
        [self.pickview show];
        _indexPath = indexPath;
    }
    
}

- (NSArray *)getPlistArray{
    
    NSArray * array=@[@"中国工商银行", @"中国建设银行",@"招商银行",@"中国农业银行",@"交通银行",@"广东发展银行",@"兴业银行",@"中国光大银行",@"中国民生银行",@"中国银行",@"北京银行",@"中国邮政储蓄银行",@"中信实业银行",@"平安银行",@"上海浦东发展银行",@"华夏银行"];
    return array;
}

- (NSDictionary *)cardIdInfo
{
    if (!_cardIdInfo) {
        _cardIdInfo = @{@"中国工商银行":@"102",@"中国建设银行":@"105",@"招商银行":@"308",@"中国农业银行":@"103",@"交通银行":@"301",@"广东发展银行":@"306",@"兴业银行":@"309",@"中国光大银行":@"303",@"中国民生银行":@"305",@"中国银行":@"104",@"北京银行":@"999",@"中国邮政储蓄银行":@"403",@"中信实业银行":@"302",@"平安银行":@"313",@"上海浦东发展银行":@"310",@"华夏银行":@"304"};
    }
    return _cardIdInfo  ;
}

- (ZHPickView *)pickview
{
    if (!_pickview) {
        _pickview = [[ZHPickView alloc] initPickviewWithPlistName:self.tableView isHaveNavControler:NO withArray:[self getPlistArray]];
        [_pickview setPickViewColer:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1]];
        [_pickview setToolbarTintColor:[UIColor whiteColor]];
        _pickview.delegate=self;
    }
    return _pickview;
}

#pragma mark ZhpickVIewDelegate

- (void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString{
    
    UITableViewCell * cell=[self.tableView cellForRowAtIndexPath:_indexPath];
    cell.detailTextLabel.text=resultString;
    _cardID = self.cardIdInfo[resultString];
}

#pragma -UITextField

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.pickview remove];
}

#pragma -UIScrollView
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    [self.pickview remove];
}

#pragma -懒加载
- (UITextField *)cardNumber
{
    if (!_cardNumber) {
        _cardNumber = [[UITextField alloc]init];
        _cardNumber.placeholder = @"请输入银行卡号";
        _cardNumber.delegate = self;
        _cardNumber.font  = [UIFont systemFontOfSize:15.0];
        _cardNumber.textAlignment = NSTextAlignmentRight;
        _cardNumber.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _cardNumber;
}

- (UITextField *)cardBank
{
    if (!_cardBank) {
        _cardBank = [[UITextField alloc]init];
        _cardBank.placeholder = @"请输入支行名称";
        _cardBank.delegate = self;
        _cardBank.font  = [UIFont systemFontOfSize:15.0];
        _cardBank.textAlignment = NSTextAlignmentRight;
    }
    return _cardBank;
}

- (UITextField *)cardCity
{
    if (!_cardCity) {
        _cardCity = [[UITextField alloc]init];
        _cardCity.placeholder = @"请输入开户城市";
        _cardCity.delegate = self;
        _cardCity.font  = [UIFont systemFontOfSize:15.0];
        _cardCity.textAlignment = NSTextAlignmentRight;
    }
    return _cardCity;
}

- (UIView *)nameAndDetail
{
    if (!_nameAndDetail) {
        _nameAndDetail = [[UIView alloc]init];
        
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(10, 8, 90, 22)];
        lable.font = [UIFont systemFontOfSize:16];
        lable.text = @"持卡人姓名";
        lable.textAlignment = NSTextAlignmentCenter;
        [_nameAndDetail addSubview:lable];
        
        UILabel *nameLable = [[UILabel alloc]initWithFrame:CGRectMake(100, 8, 200, 22)];
        nameLable.text = [Sundry nameWithString:[User sharedUser].userRealName];
        nameLable.textColor = [UIColor orangeColor];
        [_nameAndDetail addSubview:nameLable];
        
        UILabel *detial = [[UILabel alloc]initWithFrame:CGRectMake(0,32, APPScreenWidth-15, 22)];
        detial.text = @"只能绑定与实名认证信息一致的银行卡";
        detial.font = [UIFont systemFontOfSize:13];
        detial.textAlignment  = NSTextAlignmentRight;
        detial.textColor = HTGrayColor;
        [_nameAndDetail addSubview:detial];
    }
    return _nameAndDetail;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    [self clickNextBtn];
    return YES;
}
@end
