//
//  CIORequestTests.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/20/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CIORequest.h"

@interface CIORequestTests : XCTestCase

@end

@implementation CIORequestTests

- (void)testValidateGenericResponse {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.context.io/account/messages"]];
    CIORequest *request = [CIORequest withURLRequest:urlRequest client:nil];
    XCTAssertNil([request validateResponseObject:@{}]);
    XCTAssertNil([request validateResponseObject:@[]]);
    XCTAssertNil([request validateResponseObject:@""]);
    XCTAssertNil([request validateResponseObject:@{@"success": @YES}]);
    XCTAssertNil([request validateResponseObject:nil]);
    XCTAssertNotNil([request validateResponseObject:@{@"success": @NO}]);
}

- (void)testValidateArrayResponse {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.context.io/account/messages"]];
    CIOArrayRequest *request = [CIOArrayRequest withURLRequest:urlRequest client:nil];
    XCTAssertNil([request validateResponseObject:@[]]);
    XCTAssertNotNil([request validateResponseObject:@""]);
    XCTAssertNotNil([request validateResponseObject:@{}]);
    XCTAssertNotNil([request validateResponseObject:nil]);
    XCTAssertNotNil([request validateResponseObject:@{@"success": @NO}]);
    XCTAssertNotNil([request validateResponseObject:@{@"success": @YES}]);
}

- (void)testValidateDictionaryResponse {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.context.io/account/messages"]];
    CIODictionaryRequest *request = [CIODictionaryRequest withURLRequest:urlRequest client:nil];
    XCTAssertNil([request validateResponseObject:@{}]);
    XCTAssertNotNil([request validateResponseObject:@[]]);
    XCTAssertNotNil([request validateResponseObject:@""]);
    XCTAssertNotNil([request validateResponseObject:nil]);
    XCTAssertNotNil([request validateResponseObject:@{@"success": @NO}]);
    XCTAssertNil([request validateResponseObject:@{@"success": @YES}]);
}

- (void)testValidateStringResponse {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.context.io/account/messages"]];
    CIOStringRequest *request = [CIOStringRequest withURLRequest:urlRequest client:nil];
    XCTAssertNotNil([request validateResponseObject:@{}]);
    XCTAssertNotNil([request validateResponseObject:@[]]);
    XCTAssertNotNil([request validateResponseObject:nil]);
    XCTAssertNotNil([request validateResponseObject:@{@"success": @NO}]);
    XCTAssertNotNil([request validateResponseObject:@{@"success": @YES}]);
    XCTAssertNil([request validateResponseObject:@""]);
}

@end
