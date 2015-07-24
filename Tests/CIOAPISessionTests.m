//
//  CIOAPISessionTests.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/14/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOAPISession.h"
#import <XCTest/XCTest.h>

@interface CIOAPISessionTests : XCTestCase

@property (nonatomic) CIOAPISession *session;

@end

@implementation CIOAPISessionTests

- (void)setUp {
    [super setUp];
    self.session = [[CIOAPISession alloc] initWithConsumerKey:@"consumer_key" consumerSecret:@"consumer_secret"];
}

- (void)testParseResponse {
    NSData *successData = [NSJSONSerialization dataWithJSONObject:@{ @"account": @{@"id": @1}} options:0 error:nil];
    NSURL *url = [NSURL URLWithString:@"https://api.context.io/2.0/account/12"];
    NSDictionary *header = @{@"Content-Type": @"application/json"};
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:200 HTTPVersion:@"1.1" headerFields:header];
    NSError *error = nil;
    NSDictionary *responseObject = [self.session parseResponse:response data:successData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(response);
    XCTAssertTrue([responseObject isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects([responseObject valueForKeyPath:@"account.id"], @1);
}

- (void)testErrorResponse {
    NSData *errorData = [NSJSONSerialization dataWithJSONObject:@{ @"type": @"error", @"value": @"error string"} options:0 error:nil];
    NSURL *url = [NSURL URLWithString:@"https://api.context.io/2.0/account/12"];
    NSDictionary *header = @{@"Content-Type": @"application/json"};
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:402 HTTPVersion:@"1.1" headerFields:header];
    NSError *error = nil;
    NSDictionary *responseObject = [self.session parseResponse:response data:errorData error:&error];
    XCTAssertNotNil(error);
    XCTAssertNotNil(responseObject);
    XCTAssertEqualObjects(error.localizedDescription, @"error string");
}

- (void)testEmptyDataSuccess {
    NSURL *url = [NSURL URLWithString:@"https://api.context.io/2.0/account/12"];
    NSDictionary *header = @{@"Content-Type": @"application/json"};
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:200 HTTPVersion:@"1.1" headerFields:header];
    NSError *error = nil;
    NSDictionary *responseObject = [self.session parseResponse:response data:[NSData data] error:&error];
    XCTAssertNil(error);
    XCTAssertNil(responseObject);
}

- (void)testEmptyDataError {
    NSURL *url = [NSURL URLWithString:@"https://api.context.io/2.0/account/12"];
    NSDictionary *header = @{@"Content-Type": @"application/json"};
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:503 HTTPVersion:@"1.1" headerFields:header];
    NSError *error = nil;
    NSDictionary *responseObject = [self.session parseResponse:response data:[NSData data] error:&error];
    XCTAssertNotNil(error);
    XCTAssertNil(responseObject);
}

- (void)testErrorForResponse {
    NSURL *url = [NSURL URLWithString:@"https://api.context.io/2.0/account/12"];
    NSDictionary *header = @{@"Content-Type": @"application/json"};
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:401 HTTPVersion:@"1.1" headerFields:header];
    NSError *error = [self.session errorForResponse:response responseObject:nil];
    XCTAssertNotNil(error);
    NSString *expectedError = [NSString stringWithFormat:@"Invalid server response: %@ (401)", [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]];
    XCTAssertEqualObjects(error.localizedDescription, expectedError);
}


@end
