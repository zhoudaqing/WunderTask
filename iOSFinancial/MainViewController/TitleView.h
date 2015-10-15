//
//  TitleView.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseView.h"

@interface TitleView : HTBaseView

//  标题
@property (nonatomic, strong)   IBOutlet UILabel *titleLabel;
//  提示标示
@property (nonatomic, strong)   IBOutlet UILabel *promptLabel;

@end
