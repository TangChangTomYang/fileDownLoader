//
//  YRFileDownLoaderTool.h
//  DownLoaderKit
//
//  Created by yangrui on 2017/7/1.
//  Copyright © 2017年 TangChangTomYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YRFileDownLoadHeader.h"


// 一个下载器,对应一个下载任务
// 一个URL 对应一个下载器
@interface YRFileDownLoaderTool : NSObject


@property(nonatomic, strong)NSString *cacheDirectoryPath;
@property(nonatomic, assign,readonly)YRFileDownLoadState state;
@property(nonatomic, assign,readonly)float progess;

@property(nonatomic, copy)YRChangeStateCallBack changeState ;
@property(nonatomic, copy)YRChangeProgressCallBack changeProgress ;
@property(nonatomic, copy)YRSuccessCallBack successCallBack ;
@property(nonatomic, copy)YRFailCallBack failCallBack ;


-(void)downLoadFileAtUrl:(NSURL *)fileUrl changeState:(YRChangeStateCallBack)changeState changeProgress:(YRChangeProgressCallBack)changeProgress successCallBack:(YRSuccessCallBack)successCallBack failCallBack:(YRFailCallBack)failCallBack;

/**
 坑:
 如果 用户点击了几次暂停,就需要点击几次继续,才可以继续
 */
-(void)resumeDownload;

/**
 坑:
 如果 用户点击了几次继续,就需要点击几次暂停,才可以暂停
 */
-(void)pauseDownLoad;

-(void)cancleDownLoad;

-(void)cancleDownLoadAndCleanCache;
@end
