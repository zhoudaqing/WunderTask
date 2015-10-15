//
//  HTGesutreSignView.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/16.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTGestureInditaor.h"

//  圆圈数量
#define __CircleCount   9
#define __Interval  4
#define __CircleSize 7

@interface HTGestureInditaor ()

@property (nonatomic, strong)   NSMutableArray *signViews;

@end


@implementation HTGestureInditaor

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self generateSignListView];
    }
    
    return self;
}

- (NSMutableArray *)signViews
{
    if (!_signViews) {
        _signViews = [NSMutableArray array];
    }
    
    return _signViews;
}

- (void)refreshSignList:(int *)signArray
{
    _signList = signArray;
    
    [self refreshSignListView];
}

- (void)generateSignListView
{
    UIImage *unSelImage = [UIImage imageNamed:@"smallCircle"];
    
    int count = sizeof(_signList) / sizeof(int);
    NSAssert(count != __CircleCount, @"The array must be 9");
    
    count = count != 9 ? 9 : count;
    
    CGFloat circleSize = (__CircleSize + __Interval);
    for ( int i = 0; i < count; i++) {

        UIImageView *imageView = [[UIImageView alloc] initWithImage:unSelImage];
        
        NSInteger row = i / 3;
        NSInteger span = i % 3;
        
        imageView.frame = CGRectMake(__Interval + row * circleSize, __Interval + span * circleSize, __CircleSize, __CircleSize);
        [self addSubview:imageView];
        [self.signViews addObject:imageView];
    }
    
    self.frame = CGRectMake(0, 0, 3 * circleSize + __Interval, 3 * circleSize + __Interval);
}

- (void)refreshSignListView
{
    UIImage *selImage = [UIImage imageNamed:@"smallCircleSel"];
    UIImage *unSelImage = [UIImage imageNamed:@"smallCircle"];

    int count = sizeof(_signList) / sizeof(int);
    NSAssert(count != __CircleCount, @"The array must be 9");
    
    count = count != 9 ? 9 : count;
    
    for (int i = 0; i < count; i++) {
        BOOL isSel = _signList[i];

        if (i < _signViews.count) {
            UIImageView *imageView = _signViews[i];
            imageView.image = isSel ? selImage : unSelImage;
        }
    }
}

- (void)resetSignViewState
{
    UIImage *unSelImage = [UIImage imageNamed:@"smallCircle"];
    
    int count = sizeof(_signList) / sizeof(int);
    NSAssert(count != __CircleCount, @"The array must be 9");
    
    count = count != 9 ? 9 : count;
    
    for (int i = 0; i < count; i++) {
        
        if (i < _signViews.count) {
            UIImageView *imageView = _signViews[i];
            imageView.image = unSelImage;
        }
    }
    
    //  清空标记位
    _signList = nil;
}


@end
