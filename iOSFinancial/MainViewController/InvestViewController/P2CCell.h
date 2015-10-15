//
//  P2CCell.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/26.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseCell.h"

@interface P2CCell : HTBaseCell

//  背景视图
@property (nonatomic, strong) IBOutlet UIView *backView;

//  标题
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
//  年化收益
@property (nonatomic, strong) IBOutlet UILabel *annualize;
//  期限
@property (nonatomic, strong) IBOutlet UILabel *returnCycle;
//  担保方
@property (nonatomic, strong) IBOutlet UIImageView *warrentImageView;
//  担保方
@property (nonatomic, strong) IBOutlet UILabel *warrentLabel;
//  投资状态
@property (nonatomic, strong) IBOutlet UILabel *warrentState;




@end
