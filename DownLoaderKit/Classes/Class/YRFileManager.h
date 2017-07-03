//
//  YRFileManager.h
//  DownLoaderKit
//
//  Created by yangrui on 2017/7/1.
//  Copyright © 2017年 TangChangTomYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YRFileManager : NSObject


+(BOOL)isFileExistAtPath:(NSString *)path;

+(long long)sizeOfFile:(NSString *)path;

+(void)removeFileAtPath:(NSString *)path;

+(void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath;
@end
