//
//  YRViewController.m
//  DownLoaderKit
//
//  Created by TangChangTomYang on 07/01/2017.
//  Copyright (c) 2017 TangChangTomYang. All rights reserved.
//

#import "YRViewController.h"
#import "YRFileDownLoadManager.h"

@interface YRViewController ()



@end

@implementation YRViewController





- (IBAction)download:(id)sender {
    
    NSURL *fileUrl = [NSURL URLWithString:@"https://nodejs.org/dist/v6.11.0/node-v6.11.0.pkg" ];
    
    [YRFileDownLoadManager downLoadFileAtUrl:fileUrl
                                 changeState:^(YRFileDownLoadState state) {
                                     [self changeState:state];
    
                                 } changeProgress:^(float progress) {
                                     [self changeProgress:progress];
    
                                 } successCallBack:^(NSString *cachePath) {
    
                                     NSLog(@"下载完成了---->");
                                    } failCallBack:^{
                                     NSLog(@"下载失败 了---->");
                                    }
     ];
   
    
    
}

-(void)changeState:(YRFileDownLoadState)state{
    switch (state) {
        case YRFileDownLoadState_downLoading:
            NSLog(@"-----------下载 中------");
            break;
        case YRFileDownLoadState_pause:
            NSLog(@"-----------下载 暂停------");
            break;
        case YRFileDownLoadState_success:
            NSLog(@"-----------下载 成功------");
            break;
        case YRFileDownLoadState_fail:
            NSLog(@"-----------下载  失败------");
            break;
            
    }
}


-(void)changeProgress:(float)progress{

    NSLog(@"-----------当前下载了: %f------",progress);
}


- (IBAction)resume:(id)sender{
    NSURL *fileUrl = [NSURL URLWithString:@"https://nodejs.org/dist/v6.11.0/node-v6.11.0.pkg" ];
    
    [YRFileDownLoadManager resumeDownload:fileUrl];
}

- (IBAction)pause:(id)sender {
    
    NSURL *fileUrl = [NSURL URLWithString:@"https://nodejs.org/dist/v6.11.0/node-v6.11.0.pkg" ];
    
    [YRFileDownLoadManager pauseDownLoad:fileUrl];
    
}
- (IBAction)cancle:(id)sender {
    NSURL *fileUrl = [NSURL URLWithString:@"https://nodejs.org/dist/v6.11.0/node-v6.11.0.pkg" ];
    [YRFileDownLoadManager cancleDownLoad:fileUrl];
}
- (IBAction)cancleAndClean:(id)sender {
    
    NSURL *fileUrl = [NSURL URLWithString:@"https://nodejs.org/dist/v6.11.0/node-v6.11.0.pkg" ];
    [YRFileDownLoadManager cancleDownLoad:fileUrl];
}




@end
