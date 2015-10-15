//
//  InvestTargetPersonlController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/5/21.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvestTargetPersonlController.h"
#import "TargetDescriptionCell.h"


@interface InvestTargetPersonlController ()

@end

@implementation InvestTargetPersonlController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
}

#pragma mark - TabelView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return .01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TargetDescriptionCell heightForText:[self detailAtIndextPath:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TargetDescriptionCell *targetMoreCell = [TargetDescriptionCell newCell];
    targetMoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
    targetMoreCell.titleLabel.text = [self titleAtIndexPath:indexPath.row];
    targetMoreCell.promptLabel.attributedText = [self detailAtIndextPath:indexPath.row];
    
    return targetMoreCell;
}

- (NSString *)titleAtIndexPath:(NSInteger)index
{
    return @[@"基本信息:", @"工作信息:", @"个人资产及信用信息:"][index];
}

- (NSAttributedString *)detailAtIndextPath:(NSInteger)index
{
    
    NSAttributedString *string;
    
    NSString *message = @"";
    
    PersonalInfoModel *personal = _detailModel.personalModel;
    if (0 == index) {
        message = HTSTR(@"性别:%@     年龄:%@    婚姻状况:%@ \n学历:%@      子女个数:%@     \n户籍所在地:%@",
                        personal.sex,
                        personal.age,
                        personal.marriage_info,
                        personal.education,
                        personal.children_count,
                        personal.hukou_city);
        
    }else if (1 == index) {
        message = HTSTR(@"城市:%@\n工作时间:%@\n公司人数:%@\n行业:%@\n企业性质:%@\n岗位:%@",
                        personal.work_place,
                        personal.cur_job_start_mon,
                        personal.company_size,
                        personal.company_industry,
                        personal.company_type,
                        personal.work_position);
    
    }else {
        message = HTSTR(@"月收入:%@\n是否有房产:%@\n是否有车产%@\n是否有其它贷款:%@\n是否有信用卡:%@\n信用卡额度使用率:%@",
                        personal.income_fee,
                        [personal.if_has_house boolValue] ? @"是" : @"否",
                        [personal.if_has_vehicle boolValue] ? @"是" : @"否",
                        [personal.if_has_other_loan boolValue]? @"是" : @"否",
                        [personal.if_has_uncancel_creditcard boolValue] ? @"是" : @"否",
                        personal.credit_limit_used);
    
    }
    
    string = [self getParamStyleDetailText:message];
    
    return string;
}

- (NSAttributedString *)getParamStyleDetailText:(NSString *)detail
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6;
    
    NSMutableAttributedString *detailStr = [[NSMutableAttributedString alloc] initWithString:detail];
    [detailStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, detailStr.length)];
    [detailStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, detail.length)];
    [detailStr addAttribute:NSForegroundColorAttributeName value:[UIColor jd_globleTextColor] range:NSMakeRange(0, detail.length)];
    
    return detailStr;
}

@end
