//
//  SystemConfig.h
//  JRJNews
//
//  Created by Mr.Yang on 14-3-28.
//  Copyright (c) 2014年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>


/*---------------------------- 运行环境 ------------------------------*/

//  测试环境  1
//  线上环境  0

#define __APP_TEST__  0


#if __APP_TEST__

static NSString *const jianDanInvestServer = @"http://10.10.1.10:8077";

static NSString *const jianDanWapServer = @"http://m.fe.real";

#else

static NSString *const jianDanInvestServer = @"https://v2.app.jiandanlicai.com";

static NSString *const jianDanWapServer = @"https://m.jiandanlicai.com";

#endif



