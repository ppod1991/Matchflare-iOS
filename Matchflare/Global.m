//
//  Global.m
//  Matchflare
//
//  Created by Piyush Poddar on 12/24/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import "Global.h"
#import "AFNetworking.h"
#import "Person.h"

@implementation Global


static Global *instance = nil;
static NSString *baseURL = @"http://matchflare.herokuapp.com/";

+ (void) postTo:(NSString *) path withParams:(NSDictionary *) params withBody:(id) body success:(void (^)(NSURLSessionDataTask *__strong, __strong id)) success failure:(void (^)(NSURLSessionDataTask *__strong, NSError *__strong)) failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[@"POST", @"GET"]];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
    
    NSString *queryString = @"";
    if ([params count] > 0) {
        NSMutableArray *parts = [NSMutableArray array];
        for (id key in params) {
            id value = [params objectForKey: key];
            NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
            [parts addObject: part];
            queryString = [@"?" stringByAppendingString: [parts componentsJoinedByString: @"&"]];
        }
    }
    
    NSString* urlString = [[baseURL stringByAppendingString:path] stringByAppendingString:queryString];
    NSLog(@"My dictionary is %@", [[body toDictionary] description]);
    
    [manager POST:urlString parameters:[body toDictionary] success:success failure:failure];
}

+ (void) get:(NSString *) path withParams:(NSDictionary *) params success:(void (^)(NSURLSessionDataTask *__strong, __strong id)) success failure:(void (^)(NSURLSessionDataTask *__strong, NSError *__strong)) failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];

    
    NSString* urlString = [baseURL stringByAppendingString:path];
    [manager GET:urlString parameters:params success:success failure:failure];
}

// helper function: get the string form of any object
static NSString *toString(id object) {
    return [NSString stringWithFormat: @"%@", object];
}

// helper function: get the url encoded string form of any object
static NSString *urlEncode(id object) {
    NSString *string = toString(object);
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}


+ (Global*) getInstance {
    @synchronized(self) {
        if (instance==nil) {
            instance = [Global new];
        }
    }
    return instance;
};

-(NSString*) accessToken {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    
    NSString *accessToken;
    
    if([preferences objectForKey:@"access_token"] == nil)
    {
        accessToken = nil;
    }
    else
    {
        //  Get current level
        accessToken = [preferences stringForKey:@"access_token"];
    }
    
    return accessToken;
};

-(BOOL) setAccessToken:(NSString *) mAccessToken {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
        
    NSString* accessToken = mAccessToken;
    
    [preferences setValue:accessToken forKey:@"access_token"];
    
    //  Save to disk
    return [preferences synchronize];
    
};

@end
