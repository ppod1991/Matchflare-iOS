//
//  Match.m
//  Matchflare
//
//  Created by Piyush Poddar on 12/24/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import "Match.h"

@implementation Match

- (id)init {
    if (self = [super init])  {
        self.wasEdited = false;
    }
    return self;
}

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end
