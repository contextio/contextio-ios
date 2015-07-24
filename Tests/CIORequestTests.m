//
//  CIORequestTests.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/20/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CIORequest.h"

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

@end
