//
//  HTFlipNumber.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/6/11.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTFlipNumberManager.h"

static HTFlipNumberManager *currentManager;

@interface HTFlipNumberManager ()

@property (nonatomic, strong)   NSMutableArray *flipTimers;

@end

@implementation HTFlipNumberManager

+ (HTFlipNumberManager *)currentManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentManager = [[HTFlipNumberManager alloc] init];
    });
    
    return currentManager;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _flipTimers = [NSMutableArray array];
    }

    return self;
}



@end
