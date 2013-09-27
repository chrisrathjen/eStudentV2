//
//  ESNetworkManager.h
//  eStudent
//
//  Created by Christian Rathjen on 29.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ESNetworkManager;
@protocol ESNetworkManagerDelegate
@optional
- (void)dataFromRemoteURL:(NSData *)remoteData;
- (void)requestFailedWithError:(NSString *)localizedErrorString;
- (void)codeForSharedURL:(NSString *)shortURLString;
- (void)sharedArrayForCode:(NSArray *)array;
@end


@interface ESNetworkManager : NSObject
- (void)getDataFromNetwork:(NSURL *)remoteURL;
- (void)shareArrayWithICloud:(NSArray *)array; // This will share an NSArray with iCloud (public, for 24h)
- (void)importSharedArray:(NSString *)code;

@property (nonatomic,strong)id<ESNetworkManagerDelegate>delegate;

@end
