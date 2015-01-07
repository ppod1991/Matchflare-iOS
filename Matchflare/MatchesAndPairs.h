//
//  MatchesAndPairs.h
//  Matchflare
//
//  Created by Piyush Poddar on 12/29/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import "JSONModel.h"
#import "Match.h"
#import "Person.h"

@protocol MatchesAndPairs
@end

@interface MatchesAndPairs : JSONModel

@property (strong, nonatomic) NSMutableArray <Match> *matches;
@property (strong, nonatomic) NSMutableArray <Person> *contact_objects;

+(BOOL)propertyIsOptional:(NSString*)propertyName;

@end
