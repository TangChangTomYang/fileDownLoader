//
//  YRFileDownLoaderTool.m
//  DownLoaderKit
//
//  Created by yangrui on 2017/7/1.
//  Copyright © 2017年 TangChangTomYang. All rights reserved.
//

#import "YRFileDownLoaderTool.h"
#import "YRFileManager.h"

@interface YRFileDownLoaderTool ()<NSURLSessionDataDelegate>


@property(nonatomic, strong)NSURLSession *session;
@property(nonatomic, weak)NSURLSessionDataTask *dataTask;

@property(nonatomic,  copy)NSString *cacheFilePath;
@property(nonatomic,  copy)NSString *tempFilePath;

@property(nonatomic, strong)NSOutputStream *outputStream;


@end


@implementation YRFileDownLoaderTool
{
    long long _tempSize;
    long long _totalSize;
    NSInteger _requestTimes ;//这个用来限制,一次最多请求多少次,防止循环请求错误
}

-(NSURLSession *)session{
    if (!_session) {
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
         _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue: [NSOperationQueue mainQueue]];
        
    }
    return _session;
}

/**
 坑:
 如果 用户点击了几次暂停,就需要点击几次继续,才可以继续
 */
-(void)resumeDownload{
    if(self.dataTask != nil && self.state == YRFileDownLoadState_pause){
        [self.dataTask resume];
        self.state = YRFileDownLoadState_downLoading;
    }
    
}

/**
 坑:
 如果 用户点击了几次继续,就需要点击几次暂停,才可以暂停
 */
-(void)pauseDownLoad{
    //
    if (self.state == YRFileDownLoadState_downLoading) {
        [self.dataTask suspend];
        self.state = YRFileDownLoadState_pause;
    }
   
}

-(void)cancleDownLoad{
    //    [self.dataTask cancel];//这个可以
    
    [self.session invalidateAndCancel];
    self.session = nil;
    self.state = YRFileDownLoadState_pause;
}

-(void)cancleDownLoadAndCleanCache{
    [self cancleDownLoad];
    [YRFileManager removeFileAtPath:self.tempFilePath];
    self.state = YRFileDownLoadState_pause;
    
}


-(void)downLoadFileAtUrl:(NSURL *)fileUrl changeState:(YRChangeStateCallBack)changeState changeProgress:(YRChangeProgressCallBack)changeProgress successCallBack:(YRSuccessCallBack)successCallBack failCallBack:(YRFailCallBack)failCallBack{
    
    self.changeState = changeState;
    self.changeProgress = changeProgress;
    self.successCallBack = successCallBack;
    self.failCallBack = failCallBack;
    
    [self downLoadFileAtUrl:fileUrl];
    
}
-(void)downLoadFileAtUrl:(NSURL *)fileUrl{
    
    if ([fileUrl isEqual:self.dataTask.originalRequest.URL]) {
        if (self.state == YRFileDownLoadState_pause) {
          
            [self resumeDownload];
            return;
        }
        
    }

    //文件的存放地址
   
    self.cacheFilePath = [self cacheFilePathWithUrl:fileUrl];
    self.tempFilePath = [self tempFilePathWithUrl:fileUrl];
    
  
    //判断URL 对应的文件是否存在
    //1. 检查 cacha 中是否已经下载完成 下载文件
    if ([YRFileManager isFileExistAtPath:self.cacheFilePath]) {//cache 存在
        
        // 直接返回文件的相关信息
        _totalSize = [YRFileManager sizeOfFile:self.cacheFilePath];
        self.state = YRFileDownLoadState_success;
        return;
    }
    else {//cache 不存在
        
        if ([YRFileManager isFileExistAtPath:self.tempFilePath]) {//临时文件存在
            
             _tempSize = [YRFileManager sizeOfFile:self.tempFilePath];
            
            //"Content-Range" = "bytes 0-6566256/6566257";
            [self downLoadFileAtUrl:fileUrl offset:_tempSize];
            return;
        }
        
        //临时文件 不存在
        [self downLoadFileAtUrl:fileUrl offset:0];
        
    }
    
}



#pragma mark 内部方法1 私有方法

-(void)downLoadFileAtUrl:(NSURL *)url offset:(long long)offset{

    // 我们使用 忽略本地缓存的策略,这样每次都会重新请求
    // timeout== 0 表示不超时
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    
    self.dataTask = [self.session dataTaskWithRequest:request];
   
    [self resumeDownload];
    
}

#pragma mark- NSURLSessionDelegate
/** 当第一次接收到相应就会调用这个方法--> 就是相应头,并没有具体的资源内容
 通过这个方法,可以控制是继续请求还是取消请求
 */
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSHTTPURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler{
    
    _totalSize = [self readTotalLenFromResponse:response];


    if (_tempSize > _totalSize) { //文件错误了
        
        [YRFileManager removeFileAtPath:self.tempFilePath];
        completionHandler(NSURLSessionResponseCancel);
        

         //再次从 0 请求文件
        [self downLoadFileAtUrl:response.URL];
        
    }
    else if (_tempSize == _totalSize){
        
        [YRFileManager moveFile:self.tempFilePath toPath:self.cacheFilePath];
        
        self.state = YRFileDownLoadState_success;
        completionHandler(NSURLSessionResponseCancel);
    
    }
    else if (_tempSize < _totalSize){
        
        // 以追加的方式打开输出流
        self.state = YRFileDownLoadState_downLoading;
        self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tempFilePath append:YES];
        [self.outputStream open];
        completionHandler(NSURLSessionResponseAllow);
    }
    
   
}



/** 当用户继续接受数据时候调用 */
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{

    _tempSize += data.length;
    self.progess = 1.0 * _tempSize / _totalSize;
    
    [self.outputStream write:data.bytes maxLength:data.length];
}


/** 请求完成时候调用,注意请求完成,!= 请求成功或请求失败 */
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    
    if(error){
        
        if (error.code == -999) {//错误描述 error.localizedDescription
            self.state = YRFileDownLoadState_pause;
            
            if (self.failCallBack ) {
                self.failCallBack();
            }
        }
        else{
            self.state = YRFileDownLoadState_fail;
        }
        
    }
    else{ // error == nil 不一定是成功,只能表示文件下载完成
        
        //分析:
        //比如需要下载文件为 : 123456789
        //实际下载文件为    : 123456689
        //因此需要在这个地方验证文件的正确性
        
        //判断文件的有效性方法
        //1. 首先判断接收到的文件的大小和文件的实际大小是否一致
        //2. 判断文件的 MD5 摘要是否一致,一致 说明没有被篡改,是正确的
        
        
        [YRFileManager moveFile:self.tempFilePath toPath:self.cacheFilePath];
        self.state = YRFileDownLoadState_success;
    }
    
    
    if (self.outputStream ) {
        [self.outputStream close];
    }
}

-(void)dealloc{
    if (self.outputStream ) {
        [self.outputStream close];
    }
}

#pragma mark- #pragma mark 内部方法2 私有方法

-(NSString *)cacheDirectoryPath{
    
    if (!_cacheDirectoryPath) {
     _cacheDirectoryPath =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    
    }
    return  _cacheDirectoryPath;
}

-(NSString *)tempDirectorypath{
    return  NSTemporaryDirectory();
}

-(NSString *)cacheFilePathWithUrl:(NSURL *)url{
    //下载完成地址 cache + fileName
    NSString *fileName = url.lastPathComponent;
    NSString *cacheDirectoryPath = [self cacheDirectoryPath];
    NSString *cacheFilePath = [cacheDirectoryPath stringByAppendingPathComponent:fileName];
    
    return cacheFilePath;
}

-(NSString *)tempFilePathWithUrl:(NSURL *)url{
    //下载完成地址 cache + fileName
    NSString *fileName = url.lastPathComponent;
    NSString *tempDirectoryPath = [self tempDirectorypath];
    NSString *tempFilePath = [tempDirectoryPath stringByAppendingPathComponent:fileName];
    
    return tempFilePath;
}

/** 通过 NSHTTPURLResponse 相应头信息获取文件的总大小  */
-(long long)readTotalLenFromResponse:(NSHTTPURLResponse *)response{
    
    NSString *ContentRange = response.allHeaderFields[@"Content-Range"] ;
    long long totalLen = 0;
    if(ContentRange.length > 0){ //请求时设置了 偏移位置才会有这个参数值
        totalLen =  [[[ContentRange componentsSeparatedByString:@"/"] lastObject] longLongValue];
    }
    else{
        totalLen =  [response.allHeaderFields[@"Content-Length"] longLongValue];
    }
    
    return totalLen;
}


#pragma mark- 内部测试
-(void)setState:(YRFileDownLoadState)state{
    
    if(_state == state) return;

    _state = state;
    if (self.changeState ) {
        self.changeState(_state);
    }
    
    if (state == YRFileDownLoadState_success && self.successCallBack) {
        self.successCallBack(self.cacheFilePath);
    }

}

-(void)setProgess:(float)progess{
    _progess = progess;
    if (self.changeProgress ) {
        self.changeProgress(_progess);
    }
}
@end



//响应头信息
/**  这个是没有设置起始偏移位的
 <NSHTTPURLResponse: 0x60800002d820>
 { URL: http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a }
 { status code: 200, headers
 {
 "Accept-Ranges" = bytes;
 Age = 4739091;
 "Cache-Control" = "max-age=315360000";
 Connection = "keep-alive";
 "Content-Length" = 6566257;
 "Content-Type" = "audio/x-m4a";
 Date = "Sun, 07 May 2017 18:27:23 GMT";
 Expires = "Wed, 05 May 2027 18:27:23 GMT";
 "Last-Modified" = "Thu, 24 Nov 2016 08:50:26 GMT";
 Server = Tengine;
 Via = "1.1 tongdianxin118:7 (Cdn Cache Server V2.0), 1.1 hyd179:6 (Cdn Cache Server V2.0), 1.1 dyd33:7 (Cdn Cache Server V2.0)[14 200 0]";
 "X-Real-Server" = "192.168.9.52:80";
 }
 }
 
 */

/**  这个设置了range
 <NSHTTPURLResponse: 0x600000033f60> { URL: http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a } { status code: 206, headers {
 "Accept-Ranges" = bytes;
 Age = 776752;
 "Cache-Control" = "max-age=315360000";
 Connection = "keep-alive";
 "Content-Length" = 6566257;
 "Content-Range" = "bytes 0-6566256/6566257";
 "Content-Type" = "audio/x-m4a";
 Date = "Fri, 23 Jun 2017 00:50:22 GMT";
 Expires = "Mon, 21 Jun 2027 00:50:22 GMT";
 "Last-Modified" = "Thu, 24 Nov 2016 08:50:26 GMT";
 Server = Tengine;
 Via = "1.1 tongdianxin118:7 (Cdn Cache Server V2.0), 1.1 hyd179:6 (Cdn Cache Server V2.0)[40 200 0], 1.1 dong198:0 (Cdn Cache Server V2.0)[17 200 0]";
 "X-Real-Server" = "192.168.9.52:80";
 } }
 
 
 */



















