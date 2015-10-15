//
//  InvestShareViewController.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/7/22.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseViewController.h"

@protocol InvestShareDelegate <NSObject>

- (void)selfDissmiss;

@end

@interface InvestShareViewController : HTBaseViewController

@property (nonatomic ,weak) id<InvestShareDelegate> delegate;

@property (nonatomic, strong) NSDictionary *ShareDict;

@property (nonatomic , copy) NSString *url;

@end
