//
//  StringResponse.h
//  Matchflare
//
//  Created by Piyush Poddar on 1/12/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import "JSONModel.h"

@protocol StringResponse
@end

@interface StringResponse : JSONModel

@property (nonatomic, strong) NSString *response;

+(BOOL)propertyIsOptional:(NSString*)propertyName;

@end

