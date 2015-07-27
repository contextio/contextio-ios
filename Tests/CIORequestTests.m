//
//  CIORequestTests.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/20/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CIORequest.h"
#import "CIOSearchRequest.h"
#import "CIOSourceRequests.h"

@interface CIORequestTests : XCTestCase

@end

@implementation CIORequestTests

- (void)testValidateGenericResponse {
    CIORequest *request = [CIORequest requestWithPath:@"account/messages" method:@"GET" parameters:nil client:nil];
    XCTAssertNil([request validateResponseObject:@{}]);
    XCTAssertNil([request validateResponseObject:@[]]);
    XCTAssertNil([request validateResponseObject:@""]);
    XCTAssertNil([request validateResponseObject:@{@"success": @YES}]);
    XCTAssertNil([request validateResponseObject:nil]);
    XCTAssertNotNil([request validateResponseObject:@{@"success": @NO}]);
}

- (void)testValidateArrayResponse {
    CIOArrayRequest *request = [CIOArrayRequest requestWithPath:@"account/messages" method:@"GET" parameters:nil client:nil];
    XCTAssertNil([request validateResponseObject:@[]]);
    XCTAssertNotNil([request validateResponseObject:@""]);
    XCTAssertNotNil([request validateResponseObject:@{}]);
    XCTAssertNotNil([request validateResponseObject:nil]);
    XCTAssertNotNil([request validateResponseObject:@{@"success": @NO}]);
    XCTAssertNotNil([request validateResponseObject:@{@"success": @YES}]);
}

- (void)testValidateDictionaryResponse {
    CIODictionaryRequest *request = [CIODictionaryRequest requestWithPath:@"account/messages" method:@"GET" parameters:nil client:nil];
    XCTAssertNil([request validateResponseObject:@{}]);
    XCTAssertNotNil([request validateResponseObject:@[]]);
    XCTAssertNotNil([request validateResponseObject:@""]);
    XCTAssertNotNil([request validateResponseObject:nil]);
    XCTAssertNotNil([request validateResponseObject:@{@"success": @NO}]);
    XCTAssertNil([request validateResponseObject:@{@"success": @YES}]);
}

- (void)testValidateStringResponse {
    CIOStringRequest *request = [CIOStringRequest requestWithPath:@"account/messages" method:@"GET" parameters:nil client:nil];
    XCTAssertNotNil([request validateResponseObject:@{}]);
    XCTAssertNotNil([request validateResponseObject:@[]]);
    XCTAssertNotNil([request validateResponseObject:nil]);
    XCTAssertNotNil([request validateResponseObject:@{@"success": @NO}]);
    XCTAssertNotNil([request validateResponseObject:@{@"success": @YES}]);
    XCTAssertNil([request validateResponseObject:@""]);
}

- (void)testSortOrder {
    CIOSearchRequest *request = [CIOSearchRequest new];
    request.sort_order = CIOSortOrderDescending;
    XCTAssertEqualObjects(request.parameters[@"sort_order"], @"desc");
    request.sort_order = CIOSortOrderAscending;
    XCTAssertEqualObjects(request.parameters[@"sort_order"], @"asc");
    request.sort_order = CIOSortOrderUnspecified;
    XCTAssertNil(request.parameters[@"sort_order"]);
}

- (void)testDateParameter {
    NSTimeInterval unixTime = 1438026186;
    CIOSearchRequest *request = [CIOSearchRequest new];
    request.indexed_after = [NSDate dateWithTimeIntervalSince1970:unixTime];
    XCTAssertEqualObjects(request.parameters[@"indexed_after"], @(unixTime));
}

- (void)testSourcesRequest {
    CIOSourcesRequest *request = [CIOSourcesRequest requestWithPath:@"account/sources" method:@"GET" parameters:nil client:nil];
    request.status = CIOAccountStatusInvalidCredentials;
    XCTAssertEqualObjects(request.parameters[@"status"], @"INVALID_CREDENTIALS");
    request.status = CIOAccountStatusNull;
    XCTAssertNil(request.parameters[@"status"]);
}

@end
