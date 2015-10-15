//
//  WithdrawingTableViewCell.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/30.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTBaseCell.h"

@interface WithdrawingTableViewCell : HTBaseCell

@property (weak, nonatomic) IBOutlet UIImageView *bankImage;

@property (weak, nonatomic) IBOutlet UILabel *time;

@property (weak, nonatomic) IBOutlet UILabel *money;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *promptLabel;

@end
