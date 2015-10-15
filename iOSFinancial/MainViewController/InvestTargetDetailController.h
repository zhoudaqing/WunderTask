//
//  InvestTargetDetailController.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/28.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseTableViewController.h"
#import "InvestDetailModel.h"

/*!
 @header InvestTargetDetailController.h
 @abstract   显示投资项目的相关信息
 @discussion
 */

typedef NS_ENUM(NSInteger, DetailType) {
        DetailTypeNormal,   //  项目
        DetailTypeFengKeng, //  风控
        DetailTypeQIYE,     //  企业
        DetailTypeDIYa      //  抵押
};

@interface InvestTargetDetailController : HTBaseTableViewController

@property (nonatomic,  assign)  InvestDetailModel *investDetailModel;
@property (nonatomic,  assign)  DetailType type;

@end
