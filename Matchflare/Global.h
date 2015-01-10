//
//  Global.h
//  Matchflare
//
//  Created by Piyush Poddar on 12/24/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface Global : NSObject

@property(nonatomic,retain) Person *thisUser;

+ (Global*) getInstance;
- (NSString*) accessToken;
+ (NSString *) getDeviceId;
- (BOOL) setAccessToken:(NSString *) mAccessToken;
+ (void) postTo:(NSString *) path withParams:(NSDictionary *) params withBody:(id) body success:(void (^)(NSURLSessionDataTask *__strong, __strong id)) success failure:(void (^)(NSURLSessionDataTask *__strong, NSError *__strong)) failure;

+ (void) get:(NSString *) path withParams:(NSDictionary *) params success:(void (^)(NSURLSessionDataTask *__strong, __strong id)) success failure:(void (^)(NSURLSessionDataTask *__strong, NSError *__strong)) failure;

@end
