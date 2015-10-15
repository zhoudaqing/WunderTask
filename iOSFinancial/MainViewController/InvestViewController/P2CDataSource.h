//
//  P2CDataSource.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseSource.h"
#import "P2CCellModel.h"
#import "P2CCell.h"


@interface P2CDataSource : HTBaseSource

//  是否是债券项目
@property (nonatomic, assign)   BOOL isRedeem;

@property (nonatomic, strong)   P2CCellModel *p2cModel;

@end

