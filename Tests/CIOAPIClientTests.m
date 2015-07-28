//
//  CIOAPIClientTests.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/24/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOAPIClientHeader.h"
#import <XCTest/XCTest.h>

@interface CIOAPIClientTests : XCTestCase

@property (nonatomic) CIOAPIClient *client;

@end

@implementation CIOAPIClientTests

- (void)setUp {
    [super setUp];
    self.client = [[CIOAPIClient alloc] initWithConsumerKey:@"consumer_key" consumerSecret:@"consumer_secret"];
    [self.client setValue:@"anAccountId" forKey:@"accountID"];
}

- (void)tearDown {
    [super tearDown];
    [self.client clearCredentials];
}

#define AssertRequestPathTypeMethod(request, requestPath, type, requestMethod) \
    do { \
        CIORequest *_req = (request); \
        if (![_req isKindOfClass:[type class]]) { \
            XCTFail(@"%@ is wrong type", _req); \
        } \
        XCTAssertEqualObjects(_req.path, (requestPath)); \
        XCTAssertEqualObjects(_req.method, (requestMethod)); \
    } while (0)

#pragma mark Account

- (void)testGetAccount {
    AssertRequestPathTypeMethod([self.client getAccount], @"accounts/anAccountId", CIODictionaryRequest, @"GET");
}

- (void)testDeleteAccount {
    AssertRequestPathTypeMethod([self.client deleteAccount], @"accounts/anAccountId", CIODictionaryRequest, @"DELETE");
}

- (void)testAccountUpdateRequest {
    CIODictionaryRequest *request = [self.client updateAccountWithFirstName:@"Joe" lastName:@"Bob"];
    AssertRequestPathTypeMethod(request, @"accounts/anAccountId", CIODictionaryRequest, @"PUT");
    XCTAssertEqualObjects(request.parameters, (@{@"first_name": @"Joe", @"last_name": @"Bob"}));
    request = [self.client updateAccountWithFirstName:nil lastName:@"last"];
    XCTAssertEqualObjects(request.parameters, (@{@"last_name": @"last"}));
}

#pragma mark Contacts

- (void)testGetContacts {
    AssertRequestPathTypeMethod([self.client getContacts], @"accounts/anAccountId/contacts", CIODictionaryRequest, @"GET");
}

- (void)testGetContactsWithEmail {
    AssertRequestPathTypeMethod([self.client getContactWithEmail:@"joe@example.com"],
                                @"accounts/anAccountId/contacts/joe@example.com",
                                CIODictionaryRequest,
                                @"GET");
}

- (void)testGetFilesForContact {
    AssertRequestPathTypeMethod([self.client getFilesForContactWithEmail:@"joe@example.com"],
                                @"accounts/anAccountId/contacts/joe@example.com/files",
                                CIOArrayRequest,
                                @"GET");
}

- (void)testGetMessagesForContact {
    AssertRequestPathTypeMethod([self.client getMessagesForContactWithEmail:@"joe@example.com"],
                                @"accounts/anAccountId/contacts/joe@example.com/messages",
                                CIOArrayRequest,
                                @"GET");
}

- (void)testGetThreadsForContact {
    AssertRequestPathTypeMethod([self.client getThreadsForContactWithEmail:@"joe@example.com"],
                                @"accounts/anAccountId/contacts/joe@example.com/threads",
                                CIOArrayRequest,
                                @"GET");
}

#pragma mark Email Addresses

- (void)testGetEmailAddresses {
    AssertRequestPathTypeMethod([self.client getEmailAddresses],
                                @"accounts/anAccountId/email_addresses",
                                CIOArrayRequest,
                                @"GET");
}

- (void)testAddEmailAddresses {
    CIODictionaryRequest *request = [self.client addEmailAddress:@"test@example.com"];
    AssertRequestPathTypeMethod(request,
                                @"accounts/anAccountId/email_addresses",
                                CIODictionaryRequest,
                                @"POST");
    XCTAssertEqualObjects(request.parameters[@"email_address"], @"test@example.com");
}

- (void)testModifyEmailAddresses {
    CIODictionaryRequest *request = [self.client updateEmailAddressWithEmail:@"joe@example.com" primary:YES];
    AssertRequestPathTypeMethod(request,
                                @"accounts/anAccountId/email_addresses/joe@example.com",
                                CIODictionaryRequest,
                                @"POST");
    XCTAssertEqualObjects(request.parameters[@"primary"], @YES);
}

- (void)testDeleteEmailAddress {
    AssertRequestPathTypeMethod([self.client deleteEmailAddressWithEmail:@"test@example.com"],
                                @"accounts/anAccountId/email_addresses/test@example.com",
                                CIODictionaryRequest,
                                @"DELETE");
}

#pragma mark Files

- (void)testGetFiles {
    AssertRequestPathTypeMethod([self.client getFiles],
                                @"accounts/anAccountId/files",
                                CIOFilesRequest,
                                @"GET");
}

- (void)testGetFileDetails {
    AssertRequestPathTypeMethod([self.client getDetailsOfFileWithID:@"aFileId"],
                                @"accounts/anAccountId/files/aFileId",
                                CIODictionaryRequest,
                                @"GET");
}

- (void)testGetFileChanges {
    AssertRequestPathTypeMethod([self.client getChangesForFileWithID:@"aFileId"],
                                @"accounts/anAccountId/files/aFileId/changes",
                                CIOArrayRequest,
                                @"GET");
}

- (void)testGetFileContents {
    CIOStringRequest *request = [self.client getContentsURLForFileWithID:@"aFileId"];
    AssertRequestPathTypeMethod(request,
                                @"accounts/anAccountId/files/aFileId/content",
                                CIOStringRequest,
                                @"GET");
    XCTAssertEqualObjects(request.parameters[@"as_link"], @YES);
}

- (void)testGetFile {
    CIORequest *request = [self.client downloadContentsOfFileWithID:@"aFileId"];
    AssertRequestPathTypeMethod(request,
                                @"accounts/anAccountId/files/aFileId/content",
                                CIORequest,
                                @"GET");
    XCTAssertTrue(request.parameters.count == 0);
}

- (void)testGetRelatedFiles {
    AssertRequestPathTypeMethod([self.client getRelatedForFileWithID:@"aFileId"],
                                @"accounts/anAccountId/files/aFileId/related",
                                CIOArrayRequest,
                                @"GET");
}

- (void)testGetFileRevisions {
    AssertRequestPathTypeMethod([self.client getRevisionsForFileWithID:@"aFileId"],
                                @"accounts/anAccountId/files/aFileId/revisions",
                                CIOArrayRequest,
                                @"GET");
}

#pragma mark Messages

- (void)testGetMessages {
    AssertRequestPathTypeMethod([self.client getMessages],
                                @"accounts/anAccountId/messages",
                                CIOMessagesRequest,
                                @"GET");
}

- (void)testGetMessageWithID {
    AssertRequestPathTypeMethod([self.client getMessageWithID:@"aMessageID"],
                                @"accounts/anAccountId/messages/aMessageID",
                                CIOMessageRequest,
                                @"GET");
}

- (void)testUpdateMessage {
    CIOMessageUpdateRequest *request = [self.client updateMessageWithID:@"aMessageID" destinationFolder:@"folder1"];
    AssertRequestPathTypeMethod(request,
                                @"accounts/anAccountId/messages/aMessageID",
                                CIOMessageUpdateRequest,
                                @"POST");
    XCTAssertEqualObjects(request.parameters[@"dst_folder"], @"folder1");
}

- (void)testDeleteMessage {
    AssertRequestPathTypeMethod([self.client deleteMessageWithID:@"aMessageID"],
                                @"accounts/anAccountId/messages/aMessageID",
                                CIODictionaryRequest,
                                @"DELETE");
}

- (void)testGetBodyForMessage {
    CIOArrayRequest *request = [self.client getBodyForMessageWithID:@"aMessageID" type:@"text/plain"];
    AssertRequestPathTypeMethod(request,
                                @"accounts/anAccountId/messages/aMessageID/body",
                                CIOArrayRequest,
                                @"GET");
    XCTAssertEqualObjects(request.parameters[@"type"], @"text/plain");
}

#pragma mark Message Flags

- (void)testGetMessageFlags {
    AssertRequestPathTypeMethod([self.client getFlagsForMessageWithID:@"aMessageID"],
                                @"accounts/anAccountId/messages/aMessageID/flags",
                                CIODictionaryRequest,
                                @"GET");
}

- (void)testSetMessageFlags {
    CIOMessageFlags *flags = [[CIOMessageFlags alloc] init];
    flags.draft = @YES;
    flags.seen = @NO;
    CIODictionaryRequest *request = [self.client updateFlagsForMessageWithID:@"aMessageID" flags:flags];
    AssertRequestPathTypeMethod(request,
                                @"accounts/anAccountId/messages/aMessageID/flags",
                                CIODictionaryRequest,
                                @"POST");
    XCTAssertEqualObjects(request.parameters, (@{@"draft": @YES, @"seen": @NO}));
}

#pragma mark Folders

- (void)testGetMessageFolders {
    AssertRequestPathTypeMethod([self.client getFoldersForMessageWithID:@"aMessageID"],
                                @"accounts/anAccountId/messages/aMessageID/folders",
                                CIOArrayRequest,
                                @"GET");
}

- (void)testUpdateMessageFolders {
    CIORequest *request = [self.client updateFoldersForMessageWithID:@"aMessageID" addToFolder:@"todo" removeFromFolder:nil];
    AssertRequestPathTypeMethod(request,
                                @"accounts/anAccountId/messages/aMessageID/folders",
                                CIODictionaryRequest,
                                @"POST");
    XCTAssertEqualObjects(request.parameters, @{@"add": @"todo"});
}

- (void)testSetMessageFolders {
    CIORequest *request = [self.client setFoldersForMessageWithID:@"aMessageID"
                                                      folderNames:@[@"my personal label", @"parent folder/child folder"]
                                              symbolicFolderNames:@[@"\\Starred"]];
    AssertRequestPathTypeMethod(request,
                                @"accounts/anAccountId/messages/aMessageID/folders",
                                CIODictionaryRequest,
                                @"PUT");
    XCTAssertEqualObjects(request.requestBody, (@[@{@"name": @"my personal label"},
                                                  @{@"name": @"parent folder/child folder"},
                                                  @{@"symbolic_name": @"\\Starred"}
                                                  ]));
}

#pragma mark Headers

- (void)testGetMessageHeaders {
    AssertRequestPathTypeMethod([self.client getHeadersForMessageWithID:@"aMessageID"],
                                @"accounts/anAccountId/messages/aMessageID/headers",
                                CIODictionaryRequest,
                                @"GET");
}

- (void)testGetRawHeaders {
    AssertRequestPathTypeMethod([self.client getRawHeadersForMessageWithID:@"aMessageID"],
                                @"accounts/anAccountId/messages/aMessageID/headers",
                                CIOStringRequest,
                                @"GET");
}

#pragma mark Message Source

- (void)testGetMessageSource {
    AssertRequestPathTypeMethod([self.client getSourceForMessageWithID:@"aMessageID"],
                                @"accounts/anAccountId/messages/aMessageID/source",
                                CIORequest,
                                @"GET");
}

#pragma mark Message Thread

- (void)testGetMessageThread {
    AssertRequestPathTypeMethod([self.client getThreadForMessageWithID:@"aMessageID"],
                                @"accounts/anAccountId/messages/aMessageID/thread",
                                CIOMessageThreadRequest,
                                @"GET");
}

#pragma mark Sources

- (void)testGetSources {
    AssertRequestPathTypeMethod([self.client getSources],
                                @"accounts/anAccountId/sources",
                                CIOSourcesRequest,
                                @"GET");
}

- (void)testGetSource {
    AssertRequestPathTypeMethod([self.client getSourceWithLabel:@"aSourceLabel"],
                                @"accounts/anAccountId/sources/aSourceLabel",
                                CIODictionaryRequest,
                                @"GET");
}

- testDeleteSourceWithLabel {
    AssertRequestPathTypeMethod([self.client deleteSourceWithLabel:@"aSourceLabel"],
                                @"accounts/anAccountId/sources/aSourceLabel",
                                CIODictionaryRequest,
                                @"DELETE");
}

- (void)testCreateSource {
    CIOSourceCreateRequest *req = [self.client createSourceWithEmail:@"joe@example.com"
                                                              server:@"imap.gmail.com"
                                                            username:@"joe@google"
                                                              useSSL:YES
                                                                port:775
                                                                type:@"IMAP"];
    AssertRequestPathTypeMethod(req,
                                @"accounts/anAccountId/sources",
                                CIOSourceCreateRequest,
                                @"POST");
    NSDictionary *params = @{@"email": @"joe@example.com",
                             @"server": @"imap.gmail.com",
                             @"username": @"joe@google",
                             @"use_ssl": @YES,
                             @"port": @775,
                             @"type": @"IMAP"};
    for (NSString *key in params) {
        XCTAssertEqualObjects(req.parameters[key], params[key]);
    }
}

- (void)testUpdateSource {
    AssertRequestPathTypeMethod([self.client updateSourceWithLabel:@"sourceLabel"],
                                @"accounts/anAccountId/sources/sourceLabel",
                                CIOSourceModifyRequest,
                                @"POST");
}

- (void)testSourceFolders {
    CIOArrayRequest *req = [self.client getFoldersForSourceWithLabel:@"0"
                                                      includeExtendedCounts:NO
                                                                    noCache:NO];
    AssertRequestPathTypeMethod(req,
                                @"accounts/anAccountId/sources/0/folders",
                                CIOArrayRequest,
                                @"GET");
    NSDictionary *params =@{@"include_extended_counts": @0, @"no_cache": @0};
    for (NSString *key in params) {
        XCTAssertEqualObjects(req.parameters[key], params[key]);
    }
}

- (void)testSourceFolderPath {
    CIODictionaryRequest *req = [self.client getFolderWithPath:@"Inbox/Stuff"
                                              sourceLabel:@"0"
                                    includeExtendedCounts:NO
                                                    delim:nil];
    AssertRequestPathTypeMethod(req,
                                @"accounts/anAccountId/sources/0/folders/Inbox/Stuff",
                                CIODictionaryRequest,
                                @"GET");
    XCTAssertEqualObjects(req.parameters, @{@"include_extended_counts": @NO});
}

- (void)testCreateSourceFolder {
    CIODictionaryRequest *request = [self.client createFolderWithPath:@"Inbox.Lulz" sourceLabel:@"0" delim:@"."];
    AssertRequestPathTypeMethod(request,
                                @"accounts/anAccountId/sources/0/folders/Inbox.Lulz",
                                CIODictionaryRequest,
                                @"PUT");
    XCTAssertEqualObjects(request.parameters, @{@"delim": @"."});
}

- (void)testDeleteSourceFolder {
    AssertRequestPathTypeMethod([self.client deleteFolderWithPath:@"Inbox/Lulz" sourceLabel:@"0"],
                                @"accounts/anAccountId/sources/0/folders/Inbox/Lulz",
                                CIODictionaryRequest,
                                @"DELETE");
}

- (void)testSourceExpunge {
    AssertRequestPathTypeMethod([self.client expungeFolderWithPath:@"Inbox" sourceLabel:@"0"],
                                @"accounts/anAccountId/sources/0/folders/Inbox/expunge",
                                CIODictionaryRequest,
                                @"POST");

}

- (void)testFolderMessages {
    AssertRequestPathTypeMethod([self.client getMessagesForFolderWithPath:@"Inbox" sourceLabel:@"0"],
                                @"accounts/anAccountId/sources/0/folders/Inbox/messages",
                                CIOFolderMessagesRequest,
                                @"GET");
}

#pragma mark Source Sync

- (void)testSourceSyncStatus {
    AssertRequestPathTypeMethod([self.client getSyncStatusForSourceWithLabel:@"0"],
                                @"accounts/anAccountId/sources/0/sync",
                                CIODictionaryRequest,
                                @"GET");
}

- (void)testSourceForceSync {
    AssertRequestPathTypeMethod([self.client forceSyncForSourceWithLabel:@"0"],
                                @"accounts/anAccountId/sources/0/sync",
                                CIODictionaryRequest,
                                @"POST");
}

- (void)testSyncStatus {
    AssertRequestPathTypeMethod([self.client getSyncStatusForAllSources],
                                @"accounts/anAccountId/sync",
                                CIODictionaryRequest,
                                @"GET");
}

- (void)testForceSync {
    AssertRequestPathTypeMethod([self.client forceSyncForAllSources],
                                @"accounts/anAccountId/sync",
                                CIODictionaryRequest,
                                @"POST");
}

#pragma mark Threads

- (void)testListThreads {
    AssertRequestPathTypeMethod([self.client getThreads],
                                @"accounts/anAccountId/threads",
                                CIOThreadsRequest,
                                @"GET");
}


- (void)testGetThread {
    AssertRequestPathTypeMethod([self.client getThreadWithID:@"threadID"],
                                @"accounts/anAccountId/threads/threadID",
                                CIOThreadRequest,
                                @"GET");
}

- (void)testDeleteThread {
    AssertRequestPathTypeMethod([self.client deleteThreadWithID:@"threadID"],
                                @"accounts/anAccountId/threads/threadID",
                                CIODictionaryRequest,
                                @"DELETE");
}

- (void)testUpdateThreadFolders {
    CIORequest *request = [self.client updateFoldersForThreadWithID:@"aThreadID" addToFolder:@"todo" removeFromFolder:nil];
    AssertRequestPathTypeMethod(request,
                                @"accounts/anAccountId/threads/aThreadID/folders",
                                CIODictionaryRequest,
                                @"POST");
    XCTAssertEqualObjects(request.parameters, @{@"add": @"todo"});
}

- (void)testSetThreadFolders {
    CIORequest *request = [self.client setFoldersForThreadWithID:@"aThreadID"
                                                     folderNames:@[@"my personal label", @"parent folder/child folder"]
                                             symbolicFolderNames:@[@"\\Starred"]];
    AssertRequestPathTypeMethod(request,
                                @"accounts/anAccountId/threads/aThreadID/folders",
                                CIODictionaryRequest,
                                @"PUT");
    XCTAssertEqualObjects(request.requestBody, (@[@{@"name": @[@"my personal label", @"parent folder/child folder"]},
                                                  @{@"symbolic_name": @[@"\\Starred"]}
                                                  ]));
}


@end
