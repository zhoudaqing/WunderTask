//
//  TotalIncomeViewController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/6/1.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "TotalIncomeViewController.h"
#import "TotalIncomeHeader.h"
#import "TotalInComeCircle.h"
#import "NSString+Size.h"

@interface TotalIncomeViewController ()

@property (nonatomic, strong) TotalIncomeHeader *totalHeader;

@property (nonatomic, strong) NSMutableArray *circles;
@property (nonatomic, strong)   UITableViewCell *firstCell;
@property (nonatomic, strong)   UITableViewCell *secondCell;

@end

@implementation TotalIncomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showRefreshHeaderView = YES;
    
    self.totalHeader.width = self.view.width;
    
    self.tableView.tableHeaderView = self.totalHeader;
    self.tableView.tableFooterView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.refreshHeaderView beginRefreshing];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (is35Inch) {
        self.totalHeader.height = 90.0f;
    }else {
        self.totalHeader.height = 110.0f;
    }
    
    self.tableView.tableHeaderView = self.totalHeader;
    
}

- (void)refreshDataZero
{
    self.totalHeader.totalIncomeLabel.text = @"--";
    
    for (TotalInComeCircle *circle in _circles) {
        [circle.persentView setPercent:.0f];
        circle.totalLabel.text = @"--";
    }
}

- (void)refreshViewBeginRefresh:(MJRefreshBaseView *)baseView
{
    [self requestTotalInComeMoney];
}

- (void)requestTotalInComeMoney
{
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString allIncome]];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self endRefresh];
        
        NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
            
        if (result) {
            [self handleResponseDic:result];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self endRefresh];
    }];
    
}

- (void)handleResponseDic:(NSDictionary *)dict
{
    [self refreshDataZero];
    
    for (NSInteger i = 0; i < self.circles.count; i++) {
        [self refreshCicleData:dict atIndex:i];
    }
}

- (NSString *)titleAtIndex:(NSInteger)index
{
    switch (index) {
        case 0:return @"投资总收益";
        case 1:return @"余额生息收益";
        case 2:return @"红包解锁收益";
        case 3:return @"其它收益";
        default: return @"";
    }
}

- (UIColor *)tintColorAtIndex:(NSInteger)index
{
    uint color;
    switch (index) {
        case 0: color = 0x1ebaba; break;
        case 1: color = 0xb0d02a; break;
        case 2: color = 0xe94e1e; break;
        case 3: color = 0xfe8f28; break;
        default: color = 0x1ebaba;break;
    }
    
    return [UIColor colorWithHEX:color];
}

- (NSString *)keyAtIndex:(NSInteger)index
{
    switch (index) {
        case 0: return @"investor_income";
        case 1: return @"balance_income";
        case 2: return @"cashgift_unlocked";
        case 3: return @"other_income";
            
        default:
            return @"";
    }
    
}

- (void)refreshCicleData:(NSDictionary *)dict atIndex:(NSInteger)index
{
    if (index > self.circles.count) {
        return;
    }
 
    double totalInCome = [[dict stringDoubleValueForKey:@"net_income"] doubleValue];
    
    double inCome = [[dict stringDoubleValueForKey:[self keyAtIndex:index]] doubleValue];
    
    _totalHeader.totalIncomeLabel.text = [HTSTR(@"%.2f", totalInCome) formatNumberString];
    
    CGFloat percent = inCome / totalInCome;
    NSString *inComeStr = [[HTSTR(@"%.2f", inCome) formatNumberString] stringByAppendingString:@"元"];
    
    TotalInComeCircle *circleView = [self.circles objectAtIndex:index];
    
    circleView.totalLabel.text = inComeStr;
    
    //  转换比例（刨除四舍五入）
    NSString *percentStr = HTSTR(@"%.3f", percent);
    percentStr = [percentStr substringToIndex:percentStr.length - 1];
    percent = [percentStr floatValue];
    
    [circleView.persentView setpercent:percent animated:YES];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (is55Inch) {
        return 36.0f;
    }else if (is47Inch) {
        return 26.0f;
    }else {
        return 15.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 179.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && _firstCell) {
        return _firstCell;
    }else if (indexPath.row == 1 &&  _secondCell) {
        return _secondCell;
    }
    
    HTBaseCell *cell = [[HTBaseCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.autoresizesSubviews = NO;

    [self addSubviewAtIndex:indexPath onCell:cell];
    
    if (indexPath.row == 0) {
        _firstCell = cell;
    }else {
        _secondCell = cell;
    }
    
    return cell;
}

- (void)addSubviewAtIndex:(NSIndexPath *)indexPath onCell:(HTBaseCell *)cell
{
    CGFloat margin = 20.0f;
    CGFloat marginY = 30.0f;
    
    if (is55Inch) {
        marginY = 30.0f;
    }else if (is47Inch) {
        marginY = 26.0f;
    }else {
        marginY = 10.0f;
        margin = 10.0f;
    }
    
    if (!_circles) {
        _circles = [NSMutableArray array];
    }
    
    CGFloat locationX = (APPScreenWidth - margin -  146 * 2) / 2.0f;
    
    for (NSInteger i = 0; i < 2; i++) {
        TotalInComeCircle *circle = [TotalInComeCircle xibView];
        
        circle.left = locationX + (i % 2) * (margin + circle.width);
        
        NSString *title = [self titleAtIndex:indexPath.row * 2 + i];
        UIColor *tintColor = [self tintColorAtIndex:indexPath.row * 2 + i];
        
        circle.persentView.promptLabel.text = title;
        circle.persentView.tintColor = tintColor;
        [circle.persentView setPercent:.0f];
        
        [cell.contentView addSubview:circle];
        [_circles addObject:circle];
    }

}

- (TotalIncomeHeader *)totalHeader
{
    if (!_totalHeader) {
        _totalHeader = [TotalIncomeHeader xibView];
    }
    
    return _totalHeader;
}

@end
