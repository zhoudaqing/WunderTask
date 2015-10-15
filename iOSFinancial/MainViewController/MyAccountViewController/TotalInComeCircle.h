//
//  TotalInComeCircle.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/6/1.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseView.h"
#import "HTPromptCircle.h"

@interface HTSubCircleView : UIView

@property (nonatomic, strong)   HTPromptCircle *circleView;

@end

@interface TotalInComeCircle : HTBaseView


@property (nonatomic, strong) IBOutlet HTPromptCircle *persentView;

@property (nonatomic, weak) IBOutlet UILabel *totalLabel;

@end
