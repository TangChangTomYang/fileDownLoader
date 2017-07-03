//
//  YRFileDownLoadManager.m
//  DownLoaderKit
//
//  Created by yangrui on 2017/7/2.
//  Copyright © 2017年 TangChangTomYang. All rights reserved.
//

#import "YRFileDownLoadManager.h"

static YRFileDownLoadManager *_Mgr;


@implementation YRFileDownLoadManager


+(void)downLoadFileAtUrl:(NSURL *)fileUrl changeState:(YRChangeStateCallBack)changeState changeProgress:(YRChangeProgressCallBack)changeProgress successCallBack:(YRSuccessCallBack)successCallBack failCallBack:(YRFailCallBack)failCallBack;{

   YRFileDownLoaderTool *downLoadTool = [self downLoadingTool_OfUrl:fileUrl];
    
    if (downLoadTool == nil) {
        downLoadTool = [self new_downLoadTool_OfUrl:fileUrl];
    }
    
   
    // 这里有个地方比较巧妙,拦截block
  __weak typeof(_Mgr) weakMgr =  (_Mgr = [self sharemManager]);
    [downLoadTool downLoadFileAtUrl:fileUrl changeState:changeState changeProgress:changeProgress successCallBack:^(NSString *cachePath) {
        // 拦截 block
        NSString *md5Str = [fileUrl.absoluteString MD5];
        [weakMgr.downLoadingTools removeObjectForKey:md5Str];
        successCallBack(cachePath);
    } failCallBack:failCallBack];
    
}



#pragma mark- 具体 性操作所有
+(void)resumeDownload:(NSURL *)url{
    
    YRFileDownLoaderTool *downLoadTool = [self downLoadingTool_OfUrl:url];
    [downLoadTool resumeDownload];
}

+(void)pauseDownLoad:(NSURL *)url{
    YRFileDownLoaderTool *downLoadTool = [self downLoadingTool_OfUrl:url];
    [downLoadTool pauseDownLoad];
}

+(void)cancleDownLoad:(NSURL *)url{
    YRFileDownLoaderTool *downLoadTool = [self downLoadingTool_OfUrl:url];
    [downLoadTool cancleDownLoad];
}

+(void)cancleDownLoadAndCleanCache:(NSURL *)url{
    
    YRFileDownLoaderTool *downLoadTool = [self downLoadingTool_OfUrl:url];
    [downLoadTool cancleDownLoadAndCleanCache];
}




#pragma mark- 一次性操作所有
+(void)all_resumeDownload{
    _Mgr = [self sharemManager];
    [_Mgr.downLoadingTools.allValues makeObjectsPerformSelector:@selector(resumeDownload)];
    
}

+(void)all_pauseDownLoad{
    _Mgr = [self sharemManager];
    [_Mgr.downLoadingTools.allValues makeObjectsPerformSelector:@selector(pauseDownLoad)];
    
}

+(void)all_cancleDownLoad{
    _Mgr = [self sharemManager];
    [_Mgr.downLoadingTools.allValues makeObjectsPerformSelector:@selector(cancleDownLoad)];
    
}

+(void)all_cancleDownLoadAndCleanCache{
    _Mgr = [self sharemManager];
    [_Mgr.downLoadingTools.allValues makeObjectsPerformSelector:@selector(cancleDownLoadAndCleanCache)];
    
}

#pragma mark- 内部私有方法
/** 下面这4个方法保证 绝对的单例子 */
+(instancetype)sharemManager{
    
    if (!_Mgr ) {
        _Mgr = [[self alloc]init];
    }
    return _Mgr;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!_Mgr) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _Mgr = [super allocWithZone:zone];
        });
    }
    return _Mgr;
}

-(id)copyWithZone:(NSZone *)zone{
    return _Mgr;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    return _Mgr;
}



-(NSMutableDictionary *)downLoadingTools{
    if (!_downLoadingTools) {
        _downLoadingTools = [NSMutableDictionary dictionary];
    }
    return _downLoadingTools;
}


+(YRFileDownLoaderTool *)downLoadingTool_OfUrl:(NSURL *)fileUrl{
    
    _Mgr = [self sharemManager];
    
    NSString *md5Str = [fileUrl.absoluteString MD5];
    
    YRFileDownLoaderTool *downLoadTool =  _Mgr.downLoadingTools[md5Str] ;
    return downLoadTool;
}

+(YRFileDownLoaderTool *)new_downLoadTool_OfUrl:(NSURL *)fileUrl{
    
    _Mgr = [self sharemManager];
    
    NSString *md5Str = [fileUrl.absoluteString MD5];
    YRFileDownLoaderTool *downLoadTool = [[YRFileDownLoaderTool alloc]init];
    _Mgr.downLoadingTools[md5Str] = downLoadTool;
    
    return downLoadTool;
}




@end
