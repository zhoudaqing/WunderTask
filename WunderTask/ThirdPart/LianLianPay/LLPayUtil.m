//
//  LLPayUtil.m
//  DemoPay
//
//  Created by xuyf on 15/4/16.
//  Copyright (c) 2015年 llyt. All rights reserved.
//

#import "LLPayUtil.h"
#import <CommonCrypto/CommonDigest.h>

@interface LLPayUtil()

@property (nonatomic, assign) LLPaySignMethod signMethod;

@property (nonatomic, retain) NSString *signKey;
@property (nonatomic, retain) NSString *rsaPrivateKey;

@end

@implementation LLPayUtil


- (NSDictionary*)signedOrderDic:(NSDictionary*)orderDic
                     andSignKey:(NSString*)signKey
{
    self.signKey = signKey;
    
    NSMutableDictionary* signedOrder = [NSMutableDictionary dictionaryWithDictionary:orderDic];
    NSString *signString = [self partnerSignOrder:orderDic];
    
    
    // 请求签名	sign	是	String	MD5（除了sign的所有请求参数+MD5key）
    signedOrder[@"sign"] = signString;
    
    return signedOrder;
}


- (NSString*)partnerSignOrder:(NSDictionary*)paramDic
{
    // 所有参与订单签名的字段，这些字段以外不参与签名
    NSArray *keyArray = @[@"busi_partner",@"dt_order",@"info_order",
                          @"money_order",@"name_goods",@"no_order",
                          @"notify_url",@"oid_partner",@"risk_item", @"sign_type",
                          @"valid_order"];
    
    // 对字段进行字母序排序
    NSMutableArray *sortedKeyArray = [NSMutableArray arrayWithArray:keyArray];
    
    [sortedKeyArray sortUsingComparator:^NSComparisonResult(NSString* key1, NSString* key2) {
        return [key1 compare:key2];
    }];
    
    NSMutableString *paramString = [NSMutableString stringWithString:@""];
    
    // 拼接成 A=B&X=Y
    for (NSString *key in sortedKeyArray)
    {
        if ([paramDic[key] length] != 0)
        {
            [paramString appendFormat:@"&%@=%@", key, paramDic[key]];
        }
    }
    
    if ([paramString length] > 1)
    {
        [paramString deleteCharactersInRange:NSMakeRange(0, 1)];    // remove first '&'
    }
    
    BOOL bMd5Sign = [paramDic[@"sign_type"] isEqualToString:@"MD5"];
    
    if (bMd5Sign)
    {
        // MD5签名，在最后加上key， 变成 A=B&X=Y&key=1234
        [paramString appendFormat:@"&key=%@", self.signKey];
    }
    else{
        // RSA
    }
    
    NSString *signString = [self signString:paramString];
    
    return signString;
}

- (NSString *)signString:(NSString*)origString
{
    const char *original_str = [origString UTF8String];
    unsigned char result[32];
    //  FIXME:添加了 （unsigned int）
    CC_MD5(original_str, (unsigned int)strlen(original_str), result); //调用md5
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++){
        [hash appendFormat:@"%02x", result[i]];
    }
    
    return hash;
}


+ (NSString*)jsonStringOfObj:(NSDictionary*)dic{
    NSError *err = nil;
    
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:dic 
                                                         options:0
                                                           error:&err];
    
    NSString *str = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    
    return str;
}
@end
