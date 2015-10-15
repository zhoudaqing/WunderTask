//
//  ReturnMoneyTableViewCell.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/29.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttributedLabel.h"

@interface ReturnMoneyTableViewCell : UITableViewCell

@property (nonatomic) AttributedLabel *colorLable;

/** 项目回款描述  */
- (void)setCellContentLableWithString:(NSString *)text;

/** 金额描述 */
- (void)setCellMoneyLanleWithSring:(NSString *)text;

@end
