//
//  FlipNumberCell.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/6/9.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseCell.h"

@interface FlipTitleView : UIView

@end

@interface FlipNumberCell : HTBaseCell

//  总收益
@property (nonatomic, copy)   NSString *totalIncome;
//  投资收益
@property (nonatomic, copy)   NSString *investoreFree;
//  总注册人数
@property (nonatomic, copy)   NSString *registerNumb;

@property (nonatomic, strong)   IBOutlet FlipTitleView *titleView1;
@property (nonatomic, strong)   IBOutlet FlipTitleView *titleView2;
@property (nonatomic, strong)   IBOutlet FlipTitleView *titleView3;
@property (nonatomic, strong)   IBOutlet UIImageView *backImageView;

- (void)startAnimation;

@end
