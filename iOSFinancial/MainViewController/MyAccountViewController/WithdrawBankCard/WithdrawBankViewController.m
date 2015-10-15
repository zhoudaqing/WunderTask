//
//  WithdrawBankViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/28.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "WithdrawBankViewController.h"
#import "AddCardViewController.h"
#import "BankModel.h"

@interface WithdrawBankViewController ()
{
    BankModel *_model;
    UITextField *_banckCity, *_bankName;
    UIButton *_editBtn;
}
@property (nonatomic, strong)   NSArray *bankList;

@property (nonatomic, assign)   BOOL isUniq;

@property (nonatomic) UIView *safeCard;

@end

@implementation WithdrawBankViewController


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showLoadingViewWithState:LoadingStateLoading];
    
    __weakSelf;
    [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state){
        [weakSelf requestBankCardList];
    }];
    
    
    [self requestBankCardList];

}


- (void)willChangePromptView
{
    self.loadingStateView.promptStr = @"未绑定任何银行卡";
}

- (void)requestBankCardList
{
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString bankCard]];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self removeLoadingView];
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
            
        }else {
            NSArray *result = [request.responseJSONObject arrayForKey:@"result"];
            [self parseCardList:result];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self showLoadingViewWithState:LoadingStateNetworkError];
        [self showHudErrorView:PromptTypeError];

    }];

}

- (void)parseCardList:(NSArray *)array
{
    NSMutableArray *mutArray = [NSMutableArray array];
    for (NSDictionary *cardDic in array) {
        BankModel *model = [BankModel new];
        [model parseWithDictionary:cardDic];
        [mutArray addObject:model];
    }
    
    _bankList = [mutArray copy];
    
    if (_bankList.count == 0) {
        [self showLoadingViewWithState:LoadingStateNoneData];
        [self addRightBtn];
    }else {
        _model = _bankList[0];
        self.isUniq = _model.isUniq;
        if (!_model.isUniq) {
            [self addRightBtn];
        }
        if (self.isUniq) {
            self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        }
        [self.tableView reloadData];
    }
}

- (void)addRightBtn
{
    UIBarButtonItem *addCardBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(clickAddCardBtn)];
    [self.navigationItem setRightBarButtonItem:addCardBtn];
}

- (void)clickAddCardBtn
{
    AddCardViewController *addCard = [[AddCardViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    addCard.title = @"绑定银行卡";
    [self.navigationController pushViewController:addCard animated:YES];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _bankList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"accountIdentifier";
    
        HTBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            
            cell = [[HTBaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            cell.detailTextLabel.textColor = [UIColor jd_settingDetailColor];
        }
        if (!self.isUniq) {
        BankModel *modle = [_bankList objectAtIndex:indexPath.row];
        
            [self configCell:cell withBankModel:modle];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }else
        {
            [cell addSubview:self.safeCard];
            cell.backgroundColor = HTClearColor;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    
}

- (void)configCell:(HTBaseCell *)cell withBankModel:(BankModel *)model
{
    cell.imageView.image = [UIImage imageNamed:model.bankType];
    cell.textLabel.text = model.bankName;

    NSString *str;
    if (is35Inch || is4Inch) {
        str = [NSString stringWithFormat:@"尾号 %@",[model.cardNum substringWithRange:NSMakeRange(model.cardNum.length - 4, 4)]];
    }else
    {
        str = model.cardNum;
    }
    
    cell.detailTextLabel.text = str;
    
}

- (UITableView *)tableViewWithStyle:(UITableViewStyle)tableViewStyle
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:tableViewStyle];
        
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isUniq) {
        return 200;
    }
    return 60.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.isUniq) {
        return 240;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.isUniq) {
        return [self headerView];
    }
    return nil;
}

- (UIView *)headerView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APPScreenWidth, 240)];
    view.backgroundColor = HTHexColor(0xff6d2f);
    
    
 //白色区域
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(15, 15, APPScreenWidth - 30 , 180)];
    backView.backgroundColor = HTWhiteColor;
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.cornerRadius = 3.0;
    backView.layer.borderWidth = .5;
    backView.userInteractionEnabled = YES;
    backView.layer.masksToBounds = YES;
    backView.layer.borderColor = [[UIColor jd_lineColor] CGColor];
    [view addSubview:backView];
    
    UIImageView *bankImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 29, 29)];
    [bankImage setImage:[UIImage imageNamed:_model.bankType]];
    [backView addSubview:bankImage];
    
    UILabel *bankNameLable = [[UILabel alloc]initWithFrame:CGRectMake(bankImage.right + 10, bankImage.top + 6.5, 160, 16)];
    bankNameLable.text = _model.bankName;
    bankNameLable.font = [UIFont systemFontOfSize:16.0];
    [backView addSubview:bankNameLable];
//编辑按钮
     _editBtn = [[UIButton alloc]initWithFrame:CGRectMake(backView.width - 59, bankNameLable.top, 44, 22)];
    [_editBtn setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    [_editBtn addTarget:self action:@selector(clcikeditBtn:) forControlEvents:UIControlEventTouchDown];
    [backView addSubview:_editBtn];
//银行卡号
    UILabel *cardNumberLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 68, backView.width, 22)];
    cardNumberLable.text = _model.cardNum;
    cardNumberLable.font =[UIFont systemFontOfSize:22];
    cardNumberLable.textAlignment = NSTextAlignmentCenter;
    [backView  addSubview:cardNumberLable];
//两条线
    UIView *rimline = [Sundry rimLine];
    rimline.frame = CGRectMake(0, 120, backView.width, .5);
    [backView  addSubview:rimline];
    
    UIView *verticalRimline = [Sundry rimLine];
    verticalRimline.frame = CGRectMake(backView.width * .4, rimline.bottom, .5, 60);
    [backView addSubview:verticalRimline];
// 城市前面的位置符号
    UIImageView *location = [[UIImageView alloc]initWithFrame:CGRectMake(verticalRimline.right * .25, rimline.bottom  + 18, 11.5, 16)];
    [location setImage:[UIImage imageNamed:@"location"]];
    [backView  addSubview:location];
// 两个textField
    _banckCity = [[UITextField alloc]initWithFrame:CGRectMake(location.right + 5, location.top , verticalRimline.right - location.right, 18)];
    _banckCity.placeholder = @"开卡城市";
    _banckCity.text = _model.bankCity;
    _banckCity.textColor  = [UIColor jd_globleTextColor];
    _banckCity.userInteractionEnabled = NO;
    _banckCity.font = [UIFont systemFontOfSize:14.0];
    [backView addSubview:_banckCity];
    
    _bankName = [[UITextField alloc]initWithFrame:CGRectMake(verticalRimline.right, _banckCity.top, backView.width - verticalRimline.right, 18)];
    _bankName.font =[UIFont systemFontOfSize:14.0];
    _bankName.textAlignment = NSTextAlignmentCenter;
    _bankName.placeholder = @"开户支行";
    _bankName.text = _model.bankBranch;
    _bankName.textColor  = [UIColor jd_globleTextColor];
    _bankName.userInteractionEnabled = NO;
    [backView addSubview:_bankName];
//底部文字
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, backView.bottom + 13, 16, 20)];
    [imageView setImage:[UIImage imageNamed:@"safe"]];
    [view addSubview:imageView];
    
    UILabel *lable =[[UILabel alloc]initWithFrame:CGRectMake(imageView.right + 4, imageView.top + 1, APPScreenWidth, 14)];
    lable.text = @"此卡为简单理财网“安全卡”";
    lable.font = [UIFont systemFontOfSize:14.0];
    lable.textColor = HTWhiteColor;
    [view addSubview:lable];
    
    return view;
}
- (void)clcikeditBtn:(UIButton *)btn
{
    if ((btn.titleLabel.text == nil || [btn.titleLabel.text  isEqual: @" "]) || btn == nil) {
        
        [_editBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        
        [_editBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_editBtn setTitleColor:[UIColor jd_barTintColor] forState:UIControlStateNormal];
        _banckCity.userInteractionEnabled = YES;
        _bankName.userInteractionEnabled = YES;
        [_banckCity becomeFirstResponder];
    }else
    {
        [_editBtn setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        [_editBtn setTitle:@" " forState:UIControlStateNormal];
        _banckCity.userInteractionEnabled = NO;
        _bankName.userInteractionEnabled = NO;
        [self saveCardcontent];
        NSLog(@"保存数据");
        
    }
    
}

- (void)saveCardcontent
{
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString editBankCard]];
    [request addPostValue:_model.cardId forKey:@"id"];
    [request addPostValue:_banckCity.text forKey:@"bank_city"];
    [request addPostValue:_bankName.text forKey:@"bank_branch"];
    [request addPostValue:_model.bankNum forKey:@"bank_card_type_id"];
    [self showHudWaitingView:PromptTypeWating];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
            
        }else {
            [self showHudSuccessView:@"银行卡信息修改成功"];
            if ([self.Wdelegate respondsToSelector:@selector(selfHelpWithdraw)]) {
                [self.Wdelegate selfHelpWithdraw];
            }
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self showHudErrorView:PromptTypeError];
    }];

}


- (UIView *)safeCard
{
    if (!_safeCard) {
        _safeCard = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APPScreenWidth, 200)];
        _safeCard.backgroundColor = HTWhiteColor;
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, APPScreenWidth -15, 18)];
        title.text = @"什么是“安全卡”？";
        [title setFont:[UIFont systemFontOfSize:18.0]];
        [_safeCard addSubview:title];
        
        UILabel *contentLable = [[UILabel alloc]initWithFrame:CGRectMake(15, title.bottom + 5 , APPScreenWidth - 30, 0)];
        
        contentLable.font = [UIFont systemFontOfSize:13.0];
        contentLable.numberOfLines = 0;
        contentLable.text = @"为保证您的账户资金在简单理财网的安全性，特推出“安全卡”，每一个用户只能绑定一张卡作为快捷支付方式。“安全卡”是您支付资金的唯一通道，在资金支付便捷的同时保证资金安全，避免盗卡诈骗等风险。";
        contentLable.textColor = [UIColor jd_globleTextColor];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:contentLable.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle setLineSpacing:4];//调整行间距
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [contentLable.text length])];
        contentLable.attributedText = attributedString;
        
        [_safeCard addSubview:contentLable];
        [contentLable sizeToFit];
        _safeCard.frame = CGRectMake(0, 0, APPScreenWidth, contentLable.bottom +10);
        
        UIImageView *topRimeLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, _safeCard.bottom, APPScreenWidth, 6.5)];
        UIImage *image = [UIImage imageNamed:@"xiajuchi"];
        topRimeLine.backgroundColor = [UIColor colorWithPatternImage:image];
        [_safeCard addSubview:topRimeLine];
    }
    return _safeCard;
}


@end
