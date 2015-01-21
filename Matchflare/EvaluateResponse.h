//
//  EvaluateResponse.h
//  Matchflare
//
//  Created by Piyush Poddar on 1/20/15.
//  Copyright (c) 2015 Matchflare. All rights reserved.
//

#import "JSONModel.h"

@protocol EvaluateResponse
@end

@interface EvaluateResponse : JSONModel

@property int contact_id;
@property int pair_id;
@property (strong, nonatomic) NSString *decision;

+(BOOL)propertyIsOptional:(NSString*)propertyName;

@end
