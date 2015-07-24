//
//  AuthorizationRequestTests.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/13/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CIOAPIClientHeader.h"
#import "TestUtil.h"

@interface AuthorizationRequestTests : XCTestCase

@property (nonatomic) CIOAPIClient *client;

@end

@implementation AuthorizationRequestTests

- (void)setUp {
    [super setUp];
    self.client = [[CIOAPIClient alloc] initWithConsumerKey:@"consumer_key" consumerSecret:@"consumer_secret"];
}

- (void)tearDown {
    [super tearDown];
    [self.client clearCredentials];
}

- (void)testBeginAuthRequest {
    CIODictionaryRequest *request = [self.client beginAuthForProviderType:CIOEmailProviderTypeGmail
                                                        callbackURLString:@"cio-test-url"
                                                                   params:nil];
    NSURLRequest *urlRequest = [self.client requestForCIORequest:request];
    XCTAssertEqualObjects(urlRequest.URL.path, @"/2.0/connect_tokens");
    NSDictionary *params = [TestUtil parseRequestBody:urlRequest];
    XCTAssertEqualObjects(params[@"email"], @"%40gmail.com");
    XCTAssertEqualObjects(params[@"callback_url"], @"cio-test-url");
}

- (void)testExtractRedirectURL {
    NSDictionary *response = @{
                               @"access_token": @"access_token",
                               @"access_token_secret": @"access_token_secret",
                               @"browser_redirect_url": @"http://browser-redirect-url.com/redirect"
                               };
    NSURL *url = [self.client redirectURLFromResponse:response];
    XCTAssertEqualObjects(url.absoluteString, @"http://browser-redirect-url.com/redirect");
}

- (void)testFetchAccountRequest {
    NSDictionary *response = @{
                               @"access_token": @"access_token",
                               @"access_token_secret": @"access_token_secret",
                               @"browser_redirect_url": @"http://browser-redirect-url.com/redirect"
                               };
    [self.client redirectURLFromResponse:response];
    CIODictionaryRequest *request = [self.client fetchAccountWithConnectToken:@"connect-token"];
    NSURLRequest *urlRequest = [self.client requestForCIORequest:request];
    XCTAssertEqualObjects(urlRequest.URL.path, @"/2.0/connect_tokens/connect-token");
    NSString *authHeader = [TestUtil OAuthSignature:[urlRequest valueForHTTPHeaderField:@"Authorization"]];
    XCTAssertEqualObjects(authHeader, @"xt2xvlcbBpGbSP6JbjAxm3WPuws%3D");
}

- (void)testCompleteLoginSuccess {
    NSDictionary *testResponse = @{@"account":
                                       @{@"access_token": @"test-token",
                                         @"access_token_secret": @"test-secret",
                                         @"id": @"test-account-id"}
                                   };

    XCTAssertTrue([self.client completeLoginWithResponse:testResponse saveCredentials:NO]);
    XCTAssertTrue(self.client.isAuthorized);
    XCTAssertEqualObjects([self.client valueForKey:@"OAuthToken"], @"test-token");
    XCTAssertEqualObjects([self.client valueForKey:@"OAuthTokenSecret"], @"test-secret");
    XCTAssertEqualObjects([self.client valueForKey:@"accountID"], @"test-account-id");
}

- (void)testCompleteLoginFailure {
    NSDictionary *testResponse = @{@"account":
                                       @{@"access_token": @"test-token",
                                         @"id": @"test-account-id"}
                                   };

    XCTAssertFalse([self.client completeLoginWithResponse:testResponse saveCredentials:NO]);
    XCTAssertFalse(self.client.isAuthorized);
    XCTAssertNil([self.client valueForKey:@"OAuthToken"]);
    XCTAssertNil([self.client valueForKey:@"OAuthTokenSecret"]);
    XCTAssertNil([self.client valueForKey:@"accountID"]);
}

- (void)testSaveCredentials {
    NSDictionary *testResponse = @{@"account":
                                       @{@"access_token": @"test-token",
                                         @"access_token_secret": @"test-secret",
                                         @"id": @"test-account-id"}
                                   };
    XCTAssertTrue([self.client completeLoginWithResponse:testResponse saveCredentials:YES]);
    XCTAssertTrue(self.client.isAuthorized);
    CIOAPIClient *newClient = [[CIOAPIClient alloc] initWithConsumerKey:@"consumer_key" consumerSecret:@"consumer_secret"];
    XCTAssertTrue(newClient.isAuthorized);
}

@end
