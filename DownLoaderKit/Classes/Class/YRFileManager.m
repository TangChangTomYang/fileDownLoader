//
//  YRFileManager.m
//  DownLoaderKit
//
//  Created by yangrui on 2017/7/1.
//  Copyright © 2017年 TangChangTomYang. All rights reserved.
//

#import "YRFileManager.h"

@implementation YRFileManager

+(BOOL)isFileExistAtPath:(NSString *)path{
    
    if(path.length == 0)    return NO;
    return    [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+(long long)sizeOfFile:(NSString *)path{
    
    if (![self isFileExistAtPath:path]) {
        return 0;
    }
   NSDictionary *fileInfoDic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];

   return   [fileInfoDic[NSFileSize] longLongValue];
}

+(void)removeFileAtPath:(NSString *)path{
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}


+(void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath{
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}
@end
