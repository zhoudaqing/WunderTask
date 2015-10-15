//
//  ProjectView.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/5/7.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseView.h"

@interface ProjectView : HTBaseView

@property (nonatomic, assign)   LoanType projectType;
@property (nonatomic, strong)   IBOutlet UILabel *titleLabel;
@property (nonatomic, strong)   IBOutlet UILabel *detailLabel;


@end
