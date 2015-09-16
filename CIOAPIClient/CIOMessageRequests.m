//
//  CIOMessagesRequest.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/23/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOMessageRequests.h"

@implementation CIOMessageRequestBase
@end

@implementation CIOMessagesRequest
@end

@implementation CIOMessageThreadRequest
@end

@implementation CIOThreadRequest
@end

@implementation CIOMessageRequest
@end

@implementation CIOLiteMessageRequest
@end

@implementation CIOLiteFolderMessagesRequest
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