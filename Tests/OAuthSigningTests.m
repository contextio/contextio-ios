//
//  OAuthSigningTests.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/6/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CIOAPIClient.h"

@interface OAuthSigningTests : XCTestCase

@property (nonatomic) CIOAPIClient *client;

@end

@implementation OAuthSigningTests

- (void)setUp {
    [super setUp];
    self.client = [[CIOAPIClient alloc] initWithConsumerKey:@"consumer_key" consumerSecret:@"consumer_secret"];
}

- (NSString *)extractSignature:(NSString *)oAuthHeader {
    NSString *stripped = [oAuthHeader stringByReplacingOccurrencesOfString:@"OAuth " withString:@""];
    NSArray *sections = [stripped componentsSeparatedByString:@", "];
    for (NSString *section in sections) {
        NSArray *split = [section componentsSeparatedByString:@"="];
        if (split.count > 1) {
            if ([split[0] isEqualToString:@"oauth_signature"]){
                return [split[1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            }
        }
    }
    return nil;
}

- (void)testTwoLeggedSigning {
    NSURLRequest *request = [self.client requestForPath:@"connect_tokens"
                                                 method:@"POST"
                                                 params:@{@"email": @"@gmail.com"}];

    NSString *authHeader = [request valueForHTTPHeaderField:@"Authorization"];
    NSString *signature = [self extractSignature:authHeader];
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
    NSString *signature = [self extractSignature:authHeader];
    XCTAssertNotNil(signature);
    XCTAssertEqualObjects(signature, @"M71dKyk6LLpHEYQNXEEBn8NCCIQ%3D");
}

@end
