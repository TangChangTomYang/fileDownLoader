//
//  YRFileDownLoadHeader.h
//  DownLoaderKit
//
//  Created by yangrui on 2017/7/2.
//  Copyright © 2017年 TangChangTomYang. All rights reserved.
//

#ifndef YRFileDownLoadHeader_h
#define YRFileDownLoadHeader_h


typedef NS_ENUM(NSInteger, YRDownLoadInfoType) {
    
    YRDownLoadInfoType_start,
    YRDownLoadInfoType_end
};
/** 这种方式 兼容C++ */
typedef NS_ENUM(NSUInteger,YRFileDownLoadState){
    YRFileDownLoadState_pause,// pause 和 cancle 都是这个
    YRFileDownLoadState_downLoading ,
    YRFileDownLoadState_success,
    YRFileDownLoadState_fail
};

typedef void(^YRChangeStateCallBack)(YRFileDownLoadState state);
typedef void(^YRChangeProgressCallBack)(float progress);
typedef void(^YRSuccessCallBack)(NSString *cachePath);
typedef void(^YRFailCallBack)() ;




#endif /* YRFileDownLoadHeader_h */
