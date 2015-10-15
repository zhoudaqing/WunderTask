//
//  InvestTargetDetailController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/28.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvestTargetDetailController.h"
#import "TargetDescriptionCell.h"
#import "TargetDescriptionCell1.h"


@implementation InvestTargetDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
}

#pragma mark - TabelView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch (_type) {
        case DetailTypeNormal:return 2;
        case DetailTypeFengKeng:
        case DetailTypeQIYE: return 4;
        case DetailTypeDIYa: return 2;
        default:
            return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return .01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((_type == DetailTypeFengKeng) &&
        indexPath.row < 2) {
        
        return 44.0f;
    }
    
    return [TargetDescriptionCell heightForText:[self getParamStyleDetailText:[self detailAtIndextPath:indexPath.row]]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((_type == DetailTypeFengKeng ) &&
        indexPath.row < 2) {
        
        TargetDescriptionCell1 *targetCell = [TargetDescriptionCell1 newCell];
        targetCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        targetCell.titleLabel.attributedText = [self formatTitleAtIndex:indexPath.row];
        
        return targetCell;
    }
    
    TargetDescriptionCell *targetMoreCell = [TargetDescriptionCell newCell];
    targetMoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
    targetMoreCell.titleLabel.text = [self titleAtIndexPath:indexPath.row];
    NSString *detail = [self detailAtIndextPath:indexPath.row];
    
    targetMoreCell.promptLabel.attributedText = [self getParamStyleDetailText:detail];
     
    //targetMoreCell.promptLabel.text = detail;
    
    return targetMoreCell;
}

- (NSAttributedString *)getParamStyleDetailText:(NSString *)detail
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = 6;
    NSMutableAttributedString *detailStr = [[NSMutableAttributedString alloc] initWithString:detail];
    [detailStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, detailStr.length)];
    [detailStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, detail.length)];
    [detailStr addAttribute:NSForegroundColorAttributeName value:[UIColor jd_globleTextColor] range:NSMakeRange(0, detail.length)];
    
    return detailStr;
}

- (NSMutableAttributedString *)formatTitleAtIndex:(NSInteger)index
{
    
    if (index == 0) {
        
        return [self formatString:@"担  保  方 : " andValue:_investDetailModel.detailModel.warrent];
    }else {
        
        return [self formatString:@"风控审查 : " andValue:@"简单理财网"];
    }
}

- (NSString *)titleAtIndexPath:(NSInteger)index
{
    if (_type == DetailTypeNormal) {
        
        if (index == 0) {
            return @"项目用途";
        }
        
        return @"还款来源";
    
    }else if (_type == DetailTypeDIYa) {

        if (index == 0) {
            return @"固定资产抵押";
        }
        
        return @"汽车抵押";
        
    }else if (_type == DetailTypeQIYE) {
        
        if (index == 0) {
            
            return @"企业类型";
        }else if (index == 1) {
            
            return @"企业性质";
        }else if (index == 2) {
            
            return @"企业简介";
        }else {
            
            return @"经营状况";
        }
        
    }else {
        if (index == 0) {
            
            return @"担  保  方:";
        }else if (index == 1) {
        
            return @"风控审查:";
        }else if (index == 2) {
            
            return @"担保公司审查结论";
        }else {
        
            return @"简单理财网意见";
        }
    }
}

- (NSString *)detailAtIndextPath:(NSInteger)index
{
    if (_type == DetailTypeNormal) {
        //  项目信息
        if (0 == index) {
            return [self replaceWebNewLine:HTSTR(@"%@%@", _investDetailModel.loan_use_type, _investDetailModel.loan_use)];
        }
        
        //  还款来源
        return [self replaceWebNewLine:_investDetailModel.repayment_source];
        
    }else if (_type == DetailTypeDIYa) {
        
        if (index == 0) {
            //  抵押信息
            return _investDetailModel.mortgage_house_con;
        }
        
        return _investDetailModel.mortgage_car_con;
        
    }else if (_type == DetailTypeQIYE) {
        if (0 == index) {
            
            return _investDetailModel.company_type;
        }else if (1 == index) {
        
            return _investDetailModel.company_nature;
        }else if (2 == index) {
        
            return [self replaceWebNewLine:_investDetailModel.introduction];
        }else {
        
            return _investDetailModel.reputation;
        }
     
    }else {
        
        //  风控信息
        if (index == 2) {
            
            return [self replaceWebNewLine:_investDetailModel.counter_guarantee];
        }else {
            
            return _investDetailModel.jianDan_review;
        }
    }
}

- (NSMutableAttributedString *)formatString:(NSString *)text1 andValue:(NSString *)value
{
    UIFont *blodFont = [UIFont boldSystemFontOfSize:16.0f];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:HTSTR(@"%@%@", text1, value)];
    [string addAttribute:NSFontAttributeName value:blodFont range:NSMakeRange(0, text1.length)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, text1.length)];
    
    [string addAttribute:NSFontAttributeName value:blodFont range:NSMakeRange(text1.length, value.length)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor jd_settingDetailColor] range:NSMakeRange(text1.length, value.length)];
    
    return string;
}

- (NSString *)replaceWebNewLine:(NSString *)string
{
    NSArray *array = [string componentsSeparatedByString:@"<br>"];
    string = [array componentsJoinedByString:@""];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return isEmpty(string) ? @"无" : string;
}

@end
