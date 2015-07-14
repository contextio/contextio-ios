//
//  TestUtil.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/13/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "TestUtil.h"

@implementation TestUtil

+ (NSDictionary *)parseRequestBody:(NSURLRequest *)request {
    NSString *bodyString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    NSArray *components = [bodyString componentsSeparatedByString:@"&"];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:components.count];
    for (NSString *component in components) {
        NSArray *pair = [component componentsSeparatedByString:@"="];
        if (pair.count > 1) {
            result[pair[0]] = pair[1];
        }
    }
    return result;
}

+ (NSString *)OAuthSignature:(NSString *)oAuthHeader {
    NSString *stripped = [oAuthHeader stringByReplacingOccurrencesOfString:@"OAuth " withString:@""];
    NSArray *sections = [stripped componentsSeparatedByString:@", "];
    for (NSString *section in sections) {
        NSArray *split = [section componentsSeparatedByString:@"="];
        if (split.count > 1) {
            if ([split[0] isEqualToString:@"oauth_signature"]){
                return [split[1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
        }
    }
    return nil;
}

@end
