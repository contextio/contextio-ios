//
//  CIOMessagesRequest.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/23/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOMessageRequests.h"

@implementation CIOMessagesRequest

+ (instancetype)requestForAccountId:(NSString *)accountID client:(CIOAPIClient *)client {
    return [self requestWithPath:[NSString pathWithComponents:@[@"accounts", accountID, @"messages"]]
                          method:@"GET"
                      parameters:nil
                          client:client];
}

@end

@implementation CIOThreadRequest
@end

@implementation CIOMessageRequest

@end

@implementation CIOMessageUpdateRequest

- (instancetype)init {
    if (self = [super init]) {
        self.flags = [[CIOMessageFlags alloc] init];
    }
    return self;
}

- (NSDictionary *)parameters {
    NSMutableDictionary *params = [[super parameters] mutableCopy];
    [params removeObjectForKey:@"flags"];
    NSDictionary *flagDictionary = [self.flags asDictionary];
    for (NSString *flag in flagDictionary) {
        params[[@"flag_" stringByAppendingString:flag]] = flagDictionary[flag];
    }
    return params;
}

@end

@implementation CIOFolderMessagesRequest

@end