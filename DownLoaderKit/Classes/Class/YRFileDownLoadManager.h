//
//  YRFileDownLoadManager.h
//  DownLoaderKit
//
//  Created by yangrui on 2017/7/2.
//  Copyright © 2017年 TangChangTomYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+MD5.h"
#import "YRFileDownLoaderTool.h"
#import "YRFileDownLoadHeader.h"

@interface YRFileDownLoadManager : NSObject<NSCopying,NSMutableCopying>


@property(nonatomic, strong)NSMutableDictionary *downLoadingTools;

+(instancetype)sharemManager;

+(void)downLoadFileAtUrl:(NSURL *)fileUrl changeState:(YRChangeStateCallBack)changeState changeProgress:(YRChangeProgressCallBack)changeProgress successCallBack:(YRSuccessCallBack)successCallBack failCallBack:(YRFailCallBack)failCallBack;



+(void)resumeDownload:(NSURL *)url;

+(void)pauseDownLoad:(NSURL *)url;

+(void)cancleDownLoad:(NSURL *)url;

+(void)cancleDownLoadAndCleanCache:(NSURL *)url;


+(void)all_resumeDownload;

+(void)all_pauseDownLoad;

+(void)all_cancleDownLoad;

+(void)all_cancleDownLoadAndCleanCache;
@end
