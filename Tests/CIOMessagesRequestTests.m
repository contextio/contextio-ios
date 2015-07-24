//
//  CIOMessagesRequestTests.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/23/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CIOMessageRequests.h"

@interface CIOMessagesRequestTests : XCTestCase

@end

@implementation CIOMessagesRequestTests

- (void)testBasicInstance {
    CIOMessagesRequest *request = [CIOMessagesRequest requestForAccountId:@"12AB" client:nil];
    XCTAssertEqualObjects(request.path, @"accounts/12AB/messages");
    XCTAssertEqualObjects(request.method, @"GET");
}

- (void)testParameters {
    CIOMessagesRequest *request = [CIOMessagesRequest requestForAccountId:@"12AB" client:nil];
    request.subject = @"puppies";
    XCTAssertEqualObjects(request.subject, @"puppies");
    request.file_size_min = @100;
    XCTAssertEqual(request.file_size_min, @100);
    XCTAssertEqualObjects(request.parameters[@"subject"], @"puppies");
    XCTAssertEqualObjects(request.parameters[@"file_size_min"], @100);
}

@end

@interface CIOMessageUpdateRequestTests : XCTestCase
@end

@implementation CIOMessageUpdateRequestTests

- (void)testFlags {
    CIOMessageUpdateRequest *request = [CIOMessageUpdateRequest requestWithPath:@"" method:@"PUT" parameters:@{@"dst_folder": @"destination"} client:nil];
    request.flags.seen = @YES;
    request.flags.flagged = @NO;
    request.move = true;
    NSDictionary *params = request.parameters;
    XCTAssertEqualObjects(params, (@{@"flag_seen": @YES,
                                     @"flag_flagged": @NO,
                                     @"move": @YES,
                                     @"dst_folder": @"destination"
                                     }));
}

@end

