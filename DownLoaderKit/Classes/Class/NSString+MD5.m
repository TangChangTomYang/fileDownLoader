//
//  NSString+MD5.m
//  DownLoaderKit
//
//  Created by yangrui on 2017/7/2.
//  Copyright © 2017年 TangChangTomYang. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

-(NSString *)MD5{

    const void *data = self.UTF8String;
    NSInteger len = strlen(data);
    
    unsigned char md[CC_MD5_DIGEST_LENGTH];
    //作用: 把才语言的字符串--> MD5 C字符串
    CC_MD5(data, (CC_LONG )len, md);
    
    NSMutableString *resultStr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    //MD5  是一个16个长度的 16进制的c字符串
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultStr appendString:[NSString stringWithFormat:@"%02X",md[i]]];
    }
    
 return resultStr;
}

@end
