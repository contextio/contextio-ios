//
//  CIOAccountsRequest.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/24/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOSourceRequests.h"

@implementation CIOSourcesRequest

- (NSString *)nameForAccountStatus:(CIOAccountStatus)status {
    switch (status) {
        case CIOAccountStatusInvalidCredentials:
            return @"INVALID_CREDENTIALS";
        case CIOAccountStatusConnectionImpossible:
            return @"CONNECTION_IMPOSSIBLE";
        case CIOAccountStatusNoAccessToAllMail:
            return @"NO_ACCESS_TO_ALL_MAIL";
        case CIOAccountStatusOK:
            return @"OK";
        case CIOAccountStatusTempDisabled:
            return @"TEMP_DISABLED";
        case CIOAccountStatusDisabled:
            return @"DISABLED";
        case CIOAccountStatusNull:
        default:
            return nil;
    }
}

- (NSDictionary *)parameters {
    NSMutableDictionary *params = [[super parameters] mutableCopy];
    NSNumber *status = params[@"status"];
    if (status) {
        NSString *statusString = [self nameForAccountStatus:[status integerValue]];
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