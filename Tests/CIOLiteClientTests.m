//
//  CIOLiteClientTests.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/28/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOLiteClient.h"
#import "TestUtil.h"
#import <XCTest/XCTest.h>

@interface CIOLiteClientTests : XCTestCase

@property (nonatomic) CIOLiteClient *client;

@end

@implementation CIOLiteClientTests

- (void)setUp {
    [super setUp];
    self.client = [[CIOLiteClient alloc] initWithConsumerKey:@"consumer_key" consumerSecret:@"consumer_secret"];
    [self.client setValue:@"anAccountId" forKey:@"accountID"];
}

- (void)tearDown {
    [super tearDown];
    [self.client clearCredentials];
}

#pragma mark User

- (void)testGetUser {
    AssertRequestPathTypeMethod([self.client getUser], @"users/anAccountId", CIODictionaryRequest, @"GET");
}

- (void)testDeleteUser {
    AssertRequestPathTypeMethod([self.client deleteUser], @"users/anAccountId", CIODictionaryRequest, @"DELETE");
}

- (void)testUserUpdateRequest {
    CIODictionaryRequest *request = [self.client updateUserWithFirstName:@"Joe" lastName:@"Bob"];
    AssertRequestPathTypeMethod(request, @"users/anAccountId", CIODictionaryRequest, @"PUT");
    XCTAssertEqualObjects(request.parameters, (@{@"first_name": @"Joe", @"last_name": @"Bob"}));
    request = [self.client updateUserWithFirstName:nil lastName:@"last"];
    XCTAssertEqualObjects(request.parameters, (@{@"last_name": @"last"}));
}

#pragma mark Email Accounts

- (void)testGetEmailAccounts {
    CIOArrayRequest *request = [self.client getEmailAccountsWithStatus:CIOAccountStatusOK statusOK:@YES];
    AssertRequestPathTypeMethod(request,
                                @"users/anAccountId/email_accounts",
                                CIOArrayRequest,
                                @"GET");
    XCTAssertEqualObjects(request.parameters[@"status"], @"OK");
    XCTAssertEqualObjects(request.parameters[@"status_ok"], @YES);
}


@end
