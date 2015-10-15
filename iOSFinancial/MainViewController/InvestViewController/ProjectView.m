//
//  ProjectView.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/5/7.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "ProjectView.h"

@interface ProjectView ()

@property (nonatomic, strong)   IBOutlet UIView *lineView;
@property (nonatomic, strong)   IBOutlet UIImageView *typeView;

@end

@implementation ProjectView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.cornerRadius = 3.0f;
    self.layer.masksToBounds = YES;
    
    self.lineView.backgroundColor = [UIColor jd_settingDetailColor];
    
    self.titleLabel.backgroundColor = [UIColor colorWithHEX:0xf5f5f5];
    self.detailLabel.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel.textColor = [UIColor jd_globleTextColor];
    self.detailLabel.textColor = [UIColor jd_globleTextColor];
}

- (void)setProjectType:(LoanType)projectType
{
    if (_projectType != projectType) {
        _projectType = projectType;
        
        NSString *imageStr;
        switch (_projectType) {
            case LoanTypeAnXin:imageStr = @"project_an"; break;
            case LoanTypeDongXin:imageStr = @"project_dong"; break;
            case LoanTypeShengXin:imageStr = @"project_sheng";break;
            case LoanTypeYinQi:imageStr = @"project_yin";break;
            default:
                break;
        }
        
        _typeView.image = HTImage(imageStr);
    }
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    self.height = 61.0f;
}

@end
