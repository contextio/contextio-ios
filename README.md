CIOAPIClient is an easy to use iOS and OS X library for communicating with the Context.IO 2.0 API. It is built upon [NSURLSession](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSession_class/index.html) and provides convenient asynchronous block based methods for interacting with the API.
## Getting Started

- Sign up for a developer account at [Context.IO](http://context.io).
- [Submit a request](http://support.context.io/hc/en-us/requests/new) for a 3-legged OAuth Token. This library only supports 3-legged tokens to ensure end-users of your application can only access their own account.
- [Download CIOAPIClient](https://github.com/contextio/contextio-ios) and check out the included iOS example app. It is also available as a [CocoaPod](http://cocoapods.org/) to make it even easier to add to your project.
- View the full [Context.IO API documentation](http://context.io/docs/2.0) to better familiarize yourself with the API.

## Building

After cloning the git repository, make sure to install cocoapods used by the example app:

```
cd <repository path>/Example
pod install
```

To run the example application, you will need to insert your Context.IO consumer key and secret in `CIOAppDelegate.m`.

## Example Usage

Use `CIOAPISession` to construct and execute signed [`NSURLRequests`][nsurl] against the Context.IO API.

[nsurl]: https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSURLRequest_Class/index.html

### Beginning an API Session

Initialize `CIOAPISession` with your API key consumer key and consumer secret:
``` objective-c
CIOAPISession *session = [[CIOAPISession alloc] initWithConsumerKey:@"your-consumer-key" consumerSecret:@"your-consumer-secret"];
```

### Authentication

`CIOAPISession` uses [Connect Tokens][ct] to authorize individual user's email accounts. Please see the example application for an overview of the authentication process. Feel free to re-use or subclass `CIOAuthViewController` in your own projects - it takes care of the details of authentication and should work out of the box for most purposes.

[ct]: https://context.io/docs/2.0/connect_tokens

### Retrieving Contacts

Once a user has completed authentication, retrieve information from their authenticated email account:

``` objective-c
CIODictionaryRequest *request = [session getContactsWithParams:nil];
[session executeDictionaryRequest:request success:^(NSDictionary *responseDict) {
    NSArray *contactsArray = responseDict[@"matches"];
} failure:^(NSError *error) {
    NSLog(@"error getting contacts: %@", error);
}];
```

### Retrieving Messages

``` objective-c
[session executeDictionaryRequest:[session getMessagesWithParams:nil] success:^(NSArray *responseArray) {
    NSArray *messagesArray = responseArray;
} failure:^(NSError *error) {
    NSLog(@"error getting messages: %@", error);
}];
```

### Retrieving Messages for a Particular Contact

``` objective-c
[session executeArrayRequest:[session getMessagesForContactWithEmail:@"example@example.com" params:nil] success:^(NSArray *responseArray) {
    NSArray *messagesArray = responseArray;
} failure:^(NSError *error) {
    NSLog(@"error getting messages: %@", error);
}];
```

### Downloading A Message Attachment

``` objective-c
NSDictionary *file = [message[@"files"] firstObject];
CIODownloadRequest *download = [session downloadContentsOfFileWithID:file[@"file_id"]];
// Save file with attachment's filename in NSDocumentDirectory
NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
NSURL *fileURL = [documentsURL URLByAppendingPathComponent:file[@"file_name"]];
[session downloadFileWithRequest:download
                       saveToURL:fileURL
                         success:^{
                             NSLog(@"File downloaded: %@", [fileURL path]);
                         }
                         failure:^(NSError *error) {
                             NSLog(@"Download error: %@", error);
                         }
                        progress:^(int64_t bytesRead, int64_t totalBytesRead, int64_t totalBytesExpected){
                            NSLog(@"Download progress: %0.2f%%", ((double)totalBytesExpected / (double)totalBytesRead) * 100);
                        }];
```

## Requirements

`CIOAPIClient` requires either iOS 7.0 and above, or Mac OS 10.9.

## Acknowledgements

Thanks to [Kevin Lord](https://github.com/lordkev) who wrote the original version of thislibrary, [Sam Soffes](https://github.com/soffes) for [sskeychain](https://github.com/soffes/sskeychain), and TweetDeck for [TDOAuth](https://github.com/tweetdeck/tdoauth) which is used for the OAuth signature generation in CIOAPIClient.

## License

CIOAPIClient is licensed under the MIT License. See the LICENSE file for details.
