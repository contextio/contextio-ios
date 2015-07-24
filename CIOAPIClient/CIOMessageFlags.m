//
//  CIOMessageFlags.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/24/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOMessageFlags.h"

@implementation CIOMessageFlags

- (NSDictionary *)asDictionary {
    NSMutableDictionary *dict = [[self dictionaryWithValuesForKeys:@[@"seen", @"answered", @"flagged", @"deleted", @"draft"]] mutableCopy];
    for (NSString *key in [dict allKeys]) {
        if (dict[key] == [NSNull null]) {
            [dict removeObjectForKey:key];
        }
    }
    return dict;
}

@end
