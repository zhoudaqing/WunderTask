//
//  ReturnMoneyDetailViewCell.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/8.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReturnMoneyDetailViewCell : UITableViewCell

@property (nonatomic) int times;

@property (nonatomic) NSString *returnMoney;

@property (nonatomic) NSString *interests;

@property (nonatomic) NSString *time;

@property (nonatomic) NSString *returnStatus;

- (void)addView;

@end
