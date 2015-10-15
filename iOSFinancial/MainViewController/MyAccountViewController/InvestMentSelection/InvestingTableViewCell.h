//
//  InvestingTableViewCell.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/2.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvestingTableViewCell : UITableViewCell

@property (nonatomic)UILabel  *abstractLable;

@property (nonatomic,assign) BOOL isRedeem;

@property (nonatomic)UILabel *timeLable;

@property (nonatomic)UILabel *moneyLable;

@property (nonatomic)UILabel *yieldLable;

@property (nonatomic)UILabel *expectMoneyLable;

@property (nonatomic)UILabel *returnTimeLable;

@property (nonatomic)UILabel *payOffLable;

@end
