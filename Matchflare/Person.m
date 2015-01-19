//
//  Person.m
//  Matchflare
//
//  Created by Piyush Poddar on 12/24/14.
//  Copyright (c) 2014 Matchflare. All rights reserved.
//

#import "Person.h"

@implementation Person


+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    Person *newPerson = [[Person allocWithZone:zone] init];
    newPerson.guessed_full_name = [self.guessed_full_name copyWithZone:zone];
    newPerson.raw_phone_number = [self.raw_phone_number copyWithZone:zone];
    newPerson.contact_id = [self.contact_id copyWithZone:zone];
    newPerson.guessed_gender = [self.guessed_gender copyWithZone:zone];
    newPerson.verified = self.verified;
    newPerson.image_url = [self.image_url copyWithZone:zone];
    newPerson.registration_id = [self.registration_id copyWithZone:zone];
    newPerson.contact_status = [self.contact_status copyWithZone:zone];
    newPerson.matcher_chat_id = self.matcher_chat_id;
    newPerson.gender_preferences = [self.gender_preferences copyWithZone:zone];
    newPerson.access_token = [self.access_token copyWithZone:zone];
    newPerson.age = self.age;;
    newPerson.contact_objects = [self.contact_objects copyWithZone:zone];
    newPerson.contacts = [self.contacts copyWithZone:zone];
    newPerson.apn_device_token = [self.apn_device_token copyWithZone:zone];
    return newPerson;
}

@end
