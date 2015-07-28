//
//  CIOAccountsRequest.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/24/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOSourceRequests.h"

@implementation CIOSourcesRequest

- (NSDictionary *)parameters {
    NSMutableDictionary *params = [[super parameters] mutableCopy];
    NSNumber *status = params[@"status"];
    if (status) {
        NSString *statusString = [CIORequest nameForAccountStatus:[status integerValue]];
        if (statusString) {
            params[@"status"] = statusString;
        } else {
            [params removeObjectForKey:@"status"];
        }
    }
    return params;
}

@end

@implementation CIOSourceCreateRequest

@end

@implementation CIOSourceModifyRequest

@end