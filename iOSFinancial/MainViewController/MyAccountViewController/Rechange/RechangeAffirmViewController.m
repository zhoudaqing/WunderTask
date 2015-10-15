//
//  RechangeAffirmViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "RechangeAffirmViewController.h"

@interface RechangeAffirmViewController ()<UITextFieldDelegate>
{
    UIButton  *_getVerifyNumberBtn;
    UILabel *_timeLable, *_detailTextLabel;
    int _second;
    NSTimer *_timeLock;
}
@property (nonatomic) UITextField *verifyNumber;


@end

@implementation RechangeAffirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"充值确认";
    [self addAiffirmBtn];

}

- (void)addAiffirmBtn
{
    UIButton *btn = [Sundry BigBtnWithHihtY:TransparentTopHeight +49.0 *4 +20 withTitle:@"确定支付"];
    [self.tableView addSubview:btn];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"affirmIdentifier";
    
    HTBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[HTBaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    if (indexPath.row ==3) {
        [cell addSubview:self.verifyNumber];
        self.verifyNumber.frame = CGRectMake(15, 0, cell.width*.65, cell.height);
        _getVerifyNumberBtn = [Sundry getVerifyNumberBtnWithFrame:CGRectMake(APPScreenWidth*.65, 0, APPScreenWidth*.35, cell.height)];
        [_getVerifyNumberBtn addTarget:self action:@selector(NgainCode) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:_getVerifyNumberBtn];
    }else
    {
        cell.textLabel.text = [self titleAtIndexPath:indexPath];
        cell.detailTextLabel.textColor = [self colorAtIndexPath:indexPath];
        cell.detailTextLabel.text = [self detailTextAtIndexPath:indexPath];    }
    
    return cell;
}


#pragma mark - Config

- (NSString *)titleAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *titles = @[@"支付金额",@"工商银行",@"手机号码",@""];
    
    return titles[indexPath.row];
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
    return @"nothing";
}

- (UITextField *)verifyNumber
{
    if (!_verifyNumber) {
        _verifyNumber = [[UITextField alloc]init];
        _verifyNumber.placeholder = @"请输入验证码";
        _verifyNumber.delegate = self;
    }
    return _verifyNumber;
}

//  点击获取验证码按钮
- (void)NgainCode
{
    //验证码请求成功执行以下代码
    _second = 60;
    _timeLock = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(secondSubtract) userInfo:nil repeats:YES];
    
    [_getVerifyNumberBtn setTitle:HTSTR(@"%d", _second) forState:UIControlStateNormal];
    _getVerifyNumberBtn.enabled = NO;
}

//  倒计时每秒所调用方法
- (void)secondSubtract
{
    NSString *text = HTSTR(@"%d", --_second);
    
    [_getVerifyNumberBtn setTitle:text forState:UIControlStateNormal];
    
    if (_second <= 0) {
        [_timeLock invalidate];
        _timeLock = nil;
        
        _getVerifyNumberBtn.enabled = YES;
        [_getVerifyNumberBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    }
}
@end
