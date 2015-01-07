//
//  Contacts.h
//  Matchflare
//
//  Created by Piyush Poddar on 12/29/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import "JSONModel.h"
#import "Person.h"

@protocol Contacts
@end

@interface Contacts : JSONModel

@property (strong, nonatomic) NSArray <Person> *contacts;

+(BOOL)propertyIsOptional:(NSString*)propertyName;


@end
