//
//  OAuthSigningTests.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/6/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CIOAPIClient.h"
#import "OAuth.h"

@interface DeterministicOAuth : OAuth

@end


@implementation DeterministicOAuth

- (NSString *)oauth_timestamp {
    return @"1456789012";
}

- (NSString *)oauth_nonce {
    return @"static-nonce-for-testing";
}

@end

@interface OAuthSigningTests : XCTestCase

@property (nonatomic) CIOAPIClient *client;

@end

@implementation OAuthSigningTests

- (void)setUp {
    [super setUp];
    self.client = [[CIOAPIClient alloc] initWithConsumerKey:@"consumer_key" consumerSecret:@"consumer_secret"];
    [self.client setValue:[[DeterministicOAuth alloc] initWithConsumerKey:@"consumer_key" andConsumerSecret:@"consumer_secret"]
                   forKey:@"OAuthGenerator"];
}

- (void)testTwoLeggedSigning {
    NSURLRequest *request = [self.client requestForPath:@"connect_tokens"
                                                 method:@"POST"
                                                 params:@{@"email": @"@gmail.com"}];

    NSString *authHeader = [request valueForHTTPHeaderField:@"Authorization"];
    XCTAssertEqualObjects(authHeader, @"OAuth realm=\"\", oauth_timestamp=\"1456789012\", oauth_nonce=\"static-nonce-for-testing\", oauth_signature_method=\"HMAC-SHA1\", oauth_consumer_key=\"consumer_key\", oauth_version=\"1.0\", email=\"%40gmail.com\", oauth_signature=\"Ejjxthf%2FkLf5q83G%2FXWBLhZotU4%3D\"");
}

- (void)testThreeLeggedSigning {
    [self.client setValue:@"oauth_token" forKey:@"OAuthToken"];
    [self.client setValue:@"oauth_token_secret" forKey:@"OAuthTokenSecret"];
    [self.client setValue:@YES forKey:@"isAuthorized"];

    NSURLRequest *request = [self.client requestForPath:@"connect_tokens"
                                                 method:@"POST"
                                                 params:@{@"email": @"@gmail.com"}];

    NSString *authHeader = [request valueForHTTPHeaderField:@"Authorization"];
    XCTAssertEqualObjects(authHeader, @"OAuth realm=\"\", oauth_timestamp=\"1456789012\", oauth_nonce=\"static-nonce-for-testing\", oauth_signature_method=\"HMAC-SHA1\", oauth_consumer_key=\"consumer_key\", oauth_version=\"1.0\", oauth_token=\"oauth_token\", email=\"%40gmail.com\", oauth_signature=\"P7%2Be0k40MTzRkMVV9CaGF4YGtok%3D\"");
}

@end
