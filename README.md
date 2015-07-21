Build awesome things with email! We take the pain out of syncing email data with your app so you can focus on what makes your product great.

CIOAPIClient is an easy to use iOS and OS X library for communicating with the Context.IO 2.0 API. It is built upon [NSURLSession](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSession_class/index.html) and provides convenient asynchronous block based methods for interacting with the API.

## Getting Started

* Sign up for a developer account at [Context.IO](http://context.io)
* [Submit a request](http://support.context.io/hc/en-us/requests/new) for a 3-legged OAuth Token. This library only supports 3-legged tokens to ensure end-users of your application can only access their own account
* [Download CIOAPIClient](https://github.com/contextio/contextio-ios) and check out the included iOS example app. It is also available as a [CocoaPod](http://cocoapods.org/) to make it even easier to add to your project
* View the full [Context.IO API documentation](http://context.io/docs/2.0) to better familiarize yourself with the API

## Using [CocoaPods](https://cocoapods.org)

To use `CIOAPIClient` in your project:

* If you don't have a podfile, run `pod init` to create one
* Add the following to your `Podfile`:<br>

```ruby
pod 'CIOAPIClient', '~> 0.9'
```

* Run `pod install` to install `CIOAPIClient` and its dependencies, then make sure to open the `.xcworkspace` file instead of `.xcodeproj` if you weren't using it already

[podfile]: https://guides.cocoapods.org/using/the-podfile.html

## Building the Example App

After cloning the git repository, make sure to install cocoapods used by the example app:

* `cd <repository path>/Example`
* `pod install`
* `open "Context.IO iOS Example App.xcworkspace"`

To run the example application, you will need to insert your Context.IO consumer key and secret in `CIOAppDelegate.m`.

## Exploring the API in a Playground

There is a pre-configured Xcode Playground (currently targeting Xcode 6.4 + Swift 1.2) in the `CIOPlayground` directory. Playgrounds with library dependencies are slightly finicky with Xcode 6.4, follow these steps to get it working:

* `cd CIOPlayground `
* `pod install`
* Open `CIOPlayground.xcworkspace`
* Select the `CIOAPIClient` Scheme in the Xcode scheme selection dropdown (it should have a dynamic framework yellow toolbox icon)
* Build the scheme (⌘B)
* Select `CIOPlayground.playground` from the `CIOPlayground` project in the Project navigator left sidebar
* Add your consumer key and consumer secret to the line
```swift
let s: CIOAPISession = CIOAPISession(consumerKey: "", consumerSecret: "")
```
* At this point the playground will execute and an authentication WebView will appear in the bottom left corner of your screen
* Authorize an email account using the Context.IO auth flow in the WebView
    - The first time the code executes after authentication it may fail. Edit the playground to try again.
* Add any code you wish to try to the `authenticator.withAuthentication() { session in` block in the playground

## Example Usage

Use `CIOAPISession` to construct and execute signed [`NSURLRequests`][nsurl] against the Context.IO API.

[nsurl]: https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSURLRequest_Class/index.html

### Beginning an API Session

Initialize `CIOAPISession` with your API key consumer key and consumer secret:

``` objective-c
CIOAPISession *session = [[CIOAPISession alloc] initWithConsumerKey:@"your-consumer-key"
                                                     consumerSecret:@"your-consumer-secret"];
```

### Authentication

`CIOAPISession` uses [Connect Tokens][ct] to authorize individual user's email accounts. Please see the example application for an overview of the authentication process. Feel free to re-use or subclass [`CIOAuthViewController`][cioauth] in your own project - it takes care of the details of authentication and should work out of the box for most purposes.

[cioauth]: https://github.com/contextio/contextio-ios/blob/master/Example/Classes/Controllers/CIOAuthViewController.m
[ct]: https://context.io/docs/2.0/connect_tokens

### [Retrieve Messages](https://context.io/docs/2.0/accounts/messages)

``` objective-c
[[session getMessagesWithParams:nil]
 executeWithSuccess:^(NSArray *responseArray) {
     self.messagesArray = responseArray;
 } failure:^(NSError *error) {
     NSLog(@"error getting messages: %@", error);
 }];
```

### [Add a Message to an Existing Folder/Label](https://context.io/docs/2.0/accounts/messages/folders)

``` objective-c
[[session updateFoldersForMessageWithID:message[@"message_id"]
                                 params:@{@"add": @"Test Label"}]
 executeWithSuccess:^(NSDictionary *response) {
     NSLog(@"Response: %@", response);
 } failure:^(NSError *error) {
     NSLog(@"error moving message: %@", error);
 }];
```

### [List Folders/Labels For An Account](https://context.io/docs/2.0/accounts/sources/folders#get)
```objective-c
// 0 is an alias for the first source of an account
[[session getFoldersForSourceWithLabel:@"0" params:nil]
 executeWithSuccess:^void(NSArray *folders) {
     NSLog(@"Folders: %@", folders);
 } failure:^void(NSError *error) {
     NSLog(@"Error getting folders: %@", error);
 }];
```

### [Download A Message Attachment](https://context.io/docs/2.0/accounts/files/content)

``` objective-c
NSDictionary *file = [message[@"files"] firstObject];
CIODownloadRequest *downloadRequest = [session downloadContentsOfFileWithID:file[@"file_id"]];
// Save file with attachment's filename in NSDocumentDirectory
NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                              inDomains:NSUserDomainMask] lastObject];
NSURL *fileURL = [documentsURL URLByAppendingPathComponent:file[@"file_name"]];
[session downloadRequest:downloadRequest
               toFileURL:fileURL
                 success:^{
                     NSLog(@"File downloaded: %@", [fileURL path]);
                 }
                 failure:^(NSError *error) {
                     NSLog(@"Download error: %@", error);
                 }
                progress:^(int64_t bytesRead, int64_t totalBytesRead, int64_t totalBytesExpected){
                    NSLog(@"Download progress: %0.2f%%",
                          ((double)totalBytesExpected / (double)totalBytesRead) * 100);
                }];

```

## Requirements

`CIOAPIClient` requires either iOS 7.0 and above or Mac OS 10.9 or above.

## Acknowledgements

Thanks to [Kevin Lord](https://github.com/lordkev) who wrote the original version of this library, [Sam Soffes](https://github.com/soffes) for [sskeychain](https://github.com/soffes/sskeychain), and TweetDeck for [TDOAuth](https://github.com/tweetdeck/tdoauth) which is used for the OAuth signature generation in CIOAPIClient.

## License

`CIOAPIClient` is licensed under the MIT License. See the `LICENSE` file for details.
