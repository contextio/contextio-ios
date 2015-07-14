//
//  AuthorizationRequestTests.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/13/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CIOAPIClient.h"
#import "TestUtil.h"

@interface AuthorizationRequestTests : XCTestCase

@property (nonatomic) CIOAPIClient *client;

@end

@implementation AuthorizationRequestTests

- (void)setUp {
    [super setUp];
    self.client = [[CIOAPIClient alloc] initWithConsumerKey:@"consumer_key" consumerSecret:@"consumer_secret"];
}

- (void)testBeginAuthRequest {
    CIODictionaryRequest *request = [self.client beginAuthForProviderType:CIOEmailProviderTypeGmail
                                                callbackURLString:@"cio-test-url"
                                                           params:nil];
    XCTAssertEqualObjects(request.urlRequest.URL.path, @"/2.0/connect_tokens");
    NSDictionary *params = [TestUtil parseRequestBody:request.urlRequest];
    XCTAssertEqualObjects(params[@"email"], @"%40gmail.com");
    XCTAssertEqualObjects(params[@"callback_url"], @"cio-test-url");
}

- (void)textExtractRedirectURL {
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
    XCTAssertEqualObjects(request.urlRequest.URL.path, @"/2.0/connect_tokens/connect-token");
    NSString *authHeader = [TestUtil OAuthSignature:[request.urlRequest valueForHTTPHeaderField:@"Authorization"]];
    XCTAssertEqualObjects(authHeader, @"xt2xvlcbBpGbSP6JbjAxm3WPuws%3D");
}

@end
