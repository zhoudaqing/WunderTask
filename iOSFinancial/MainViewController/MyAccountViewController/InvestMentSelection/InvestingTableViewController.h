//
//  InvestingTableViewController.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/2.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseTableViewController.h"

/*!
 @header        InvestingTableViewController
 @abstract      项目名称、 项目类型、认购时间、还款时间、还款状态
 @discussion    我的账户--投资中页面
 */

@interface InvestingTableViewController : HTBaseTableViewController

/** 控制器请求网址 */
@property (nonatomic, copy)  NSString *url;

/** 根据i区别控制器 */
@property (nonatomic,assign) int i;

@end
