//
//  OAuthSigningTests.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/6/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CIOAPIClientHeader.h"
#import "TestUtil.h"

@interface OAuthSigningTests : XCTestCase

@property (nonatomic) CIOAPIClient *client;

@end

@implementation OAuthSigningTests

- (void)setUp {
    [super setUp];
    self.client = [[CIOAPIClient alloc] initWithConsumerKey:@"consumer_key" consumerSecret:@"consumer_secret"];
}

- (void)testTwoLeggedSigning {
    NSURLRequest *request = [self.client requestForPath:@"connect_tokens"
                                                 method:@"POST"
                                                 params:@{@"email": @"@gmail.com"}];

    NSString *authHeader = [request valueForHTTPHeaderField:@"Authorization"];
    NSString *signature = [TestUtil OAuthSignature:authHeader];
    XCTAssertNotNil(signature);
    XCTAssertEqualObjects(signature, @"2AaRHKvlFRrLVbRY7qFAJgP%2Bzjk%3D");
}

- (void)testThreeLeggedSigning {
    [self.client setValue:@"oauth_token" forKey:@"OAuthToken"];
    [self.client setValue:@"oauth_token_secret" forKey:@"OAuthTokenSecret"];
    [self.client setValue:@YES forKey:@"isAuthorized"];

    NSURLRequest *request = [self.client requestForPath:@"connect_tokens"
                                                 method:@"POST"
                                                 params:@{@"email": @"@gmail.com"}];

    NSString *authHeader = [request valueForHTTPHeaderField:@"Authorization"];
    NSString *signature = [TestUtil OAuthSignature:authHeader];
    XCTAssertNotNil(signature);
    XCTAssertEqualObjects(signature, @"M71dKyk6LLpHEYQNXEEBn8NCCIQ%3D");
}

- (void)testJSONBody {
    CIODictionaryRequest *request = [CIODictionaryRequest
                                     requestWithPath:@"accounts/anAccountId/messages/aMessageID/folders"
                                     method:@"PUT"
                                     parameters:nil
                                     client:self.client];
    request.requestBody = @[@{@"name": @"my personal label"},
                            @{@"name": @"parent folder/child folder"},
                            @{@"symbolic_name": @"\\Starred"}
                            ];
    NSURLRequest *urlRequest = [self.client requestForCIORequest:request];
    XCTAssertEqualObjects(urlRequest.HTTPBody, [NSJSONSerialization dataWithJSONObject:request.requestBody options:0 error:nil]);
    XCTAssertEqualObjects([urlRequest valueForHTTPHeaderField:@"Content-Type"], @"application/json");
    XCTAssertEqualObjects(urlRequest.URL, [NSURL URLWithString:@"https://api.context.io/2.0/accounts/anAccountId/messages/aMessageID/folders"]);
}

@end
