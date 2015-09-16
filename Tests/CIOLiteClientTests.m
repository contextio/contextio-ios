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

- (void)testAddMailbox {
    CIOAddMailboxRequest *request = [self.client addMailboxWithEmail:@"joe@example.com"
                                                              server:@"imap.gmail.com"
                                                            username:@"joe@google"
                                                              useSSL:YES
                                                                port:775
                                                                type:@"IMAP"];
    AssertRequestPathTypeMethod(request,
                                @"users/anAccountId/email_accounts",
                                CIOAddMailboxRequest,
                                @"POST");
    NSDictionary *params = @{@"email": @"joe@example.com",
                             @"server": @"imap.gmail.com",
                             @"username": @"joe@google",
                             @"use_ssl": @YES,
                             @"port": @775,
                             @"type": @"IMAP"};
    for (NSString *key in params) {
        XCTAssertEqualObjects(request.parameters[key], params[key]);
    }
}

- (void)testStatusForAccount {
    CIODictionaryRequest *request = [self.client statusForEmailAccountWithLabel:@"tacos"];
    AssertRequestPathTypeMethod(request,
                                @"users/anAccountId/email_accounts/tacos",
                                CIODictionaryRequest,
                                @"GET");
}

- (void)testModifyAccount {
    AssertRequestPathTypeMethod([self.client modifyEmailAccountWithLabel:@"tacos"],
                                @"users/anAccountId/email_accounts/tacos",
                                CIOMailboxModifyRequest,
                                @"POST");
}

- (void)testDeleteAccount {
    AssertRequestPathTypeMethod([self.client deleteEmailAccountWithLabel:@"tacos"],
                                @"users/anAccountId/email_accounts/tacos",
                                CIODictionaryRequest,
                                @"DELETE");

}

#pragma mark - Account Folders

- (void)testGetFolders {
    CIOArrayRequest *request = [self.client getFoldersForAccountWithLabel:@"tacos" includeNamesOnly:false];
    AssertRequestPathTypeMethod(request, @"users/anAccountId/email_accounts/tacos/folders",
                                CIOArrayRequest,
                                @"GET");
}

- (void)testGetFolder {
    CIODictionaryRequest *request = [self.client getFolderNamed:@"queso" forAccountWithLabel:@"tacos" delimiter:nil];
    AssertRequestPathTypeMethod(request, @"users/anAccountId/email_accounts/tacos/folders/queso",
                                CIODictionaryRequest,
                                @"GET");
}

- (void)testAddFolder {
    CIODictionaryRequest *request = [self.client addFolderNamed:@"cilantro" forAccountWithLabel:@"tacos" delimiter:nil];
    AssertRequestPathTypeMethod(request, @"users/anAccountId/email_accounts/tacos/folders/cilantro",
                                CIODictionaryRequest,
                                @"POST");
}

#pragma mark - Email Account Folder Messages

- (void)testGetMessagesInFolder {
    CIOLiteFolderMessagesRequest *request = [self.client getMessagesForFolderWithPath:@"queso" accountLabel:@"tacos"];
    AssertRequestPathTypeMethod(request,
                                @"users/anAccountId/email_accounts/tacos/folders/queso/messages",
                                CIOLiteFolderMessagesRequest,
                                @"GET");
}

- (void)testGetMessageWithID {
    CIOLiteMessageRequest *request = [self.client getMessageWithID:@"cilantro" inFolder:@"queso" accountLabel:nil];
    AssertRequestPathTypeMethod(request,
                                @"users/anAccountId/email_accounts/0/folders/queso/messages/cilantro",
                                CIOLiteMessageRequest,
                                @"GET");
}

- (void)testMoveMessage {
    CIODictionaryRequest *request = [self.client moveMessageWithID:@"cilantro" inFolder:@"queso" accountLabel:nil toFolder:@"coriander" delimiter:nil];
    AssertRequestPathTypeMethod(request,
                                @"users/anAccountId/email_accounts/0/folders/queso/messages/cilantro",
                                CIODictionaryRequest,
                                @"PUT");
    XCTAssertEqualObjects(request.parameters[@"new_folder_id"], @"coriander");
}


@end
