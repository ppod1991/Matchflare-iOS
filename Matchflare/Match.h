//
//  Match.h
//  Matchflare
//
//  Created by Piyush Poddar on 12/24/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import "JSONModel.h"
#import "Person.h"

@protocol Match
@end

@interface Match : JSONModel

@property (strong, nonatomic) Person *first_matchee;
@property (strong, nonatomic) Person *second_matchee;
@property (strong, nonatomic) Person *matcher;

@property (strong, nonatomic) NSString *match_status;
@property int pair_id;
@property int chat_id;
@property BOOL is_anonymous;
@property (strong, nonatomic) NSString *created_at;
@property BOOL has_unseen;
@property BOOL wasEdited;

+(BOOL)propertyIsOptional:(NSString*)propertyName;


@end
