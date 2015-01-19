//
//  Person.h
//  Matchflare
//
//  Created by Piyush Poddar on 12/24/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import "JSONModel.h"

@protocol Person
@end

@interface Person : JSONModel <NSMutableCopying>

@property (nonatomic, strong) NSString *guessed_full_name;
@property (nonatomic, strong) NSString *raw_phone_number;
@property (nonatomic, strong) NSNumber *contact_id;
@property (nonatomic, strong) NSString *guessed_gender;
@property BOOL verified;
@property (nonatomic, strong) NSString *image_url;
@property (nonatomic, strong) NSString *registration_id;
@property (nonatomic, strong) NSString *apn_device_token;
@property (nonatomic, strong) NSString *contact_status;
@property int matcher_chat_id;
@property (nonatomic, strong) NSMutableArray *gender_preferences;
@property (nonatomic, strong) NSString *access_token;
@property int age;
@property (nonatomic, strong) NSMutableArray <Person> *contact_objects;
@property (nonatomic, strong) NSMutableArray *contacts;

+(BOOL)propertyIsOptional:(NSString*)propertyName;
- (id) mutableCopyWithZone:(NSZone *)zone;

@end
