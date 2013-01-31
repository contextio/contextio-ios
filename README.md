CIOAPIClient is an easy to use iOS and OS X library for communicating with the Context.IO API. It is built upon [AFNetworking](http://github.com/AFNetworking/AFNetworking/) and provides convenient asynchronous block based methods for interacting with the API. If you are already using [AFNetworking](http://github.com/AFNetworking/AFNetworking/), many of the conventions and patterns should already feel familiar.

## Getting Started

- Sign up for a developer account at [Context.IO](http://context.io).
- [Download CIOAPIClient](https://github.com/contextio/contextio-ios) and check out the included iOS example app. It is also available as a [CocoaPod](http://cocoapods.org/) to make it even easier to add to your project.
- Browse the [full documentation](http://context.io/) for a comprehensive look at all of the methods provided by the client.
- View the full [Context.IO API documentation](http://context.io/docs/2.0) to better familiarize yourself with the API.

## Building

After cloning the git repository, make sure to download the submodules as well:

```
cd <repository path>
git submodule init
git submodule update
```

To run the example application, you will need to insert your Context.IO consumer key and secret in CIOExampleAPIClient.h.

## Example Usage

### Authentication

Please see the example application for an overview of the authentication process. Feel free to re-use or subclass CIOAuthViewController in your own projects - it should work out of the box for most purposes.

### Retrieving Contacts

``` objective-c
[[CIOExampleAPIClient sharedClient] getContactsWithParams:nil success:^(NSDictionary *responseDict) {
    NSArray *contactsArray = [responseDict valueForKey:@"matches"];;
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"error getting contacts: %@", error);
}];
```

### Retrieving Messages

``` objective-c
[[CIOExampleAPIClient sharedClient] getMessagesWithParams:nil success:^(NSArray *responseArray) {
    NSArray *messagesArray = responseArray;
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"error getting messages: %@", error);
}];
```

### Retrieving Messages for a Particular Contact

``` objective-c
[[CIOExampleAPIClient sharedClient] getMessagesForContactWithEmail:@"example@example.com" params:nil success:^(NSArray *responseArray) {
    NSArray *messagesArray = responseArray;
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"error getting messages: %@", error);
}];
```

## Requirements

CIOAPIClient requires either iOS 5.0 and above, or Mac OS 10.7 (64-bit with modern Cocoa runtime) and above.

## ARC

CIOAPIClient and its dependencies all require ARC.

If you are using CIOAPIClient in a non-ARC project, you will need to set a -fobjc-arc compiler flag on all of the CIOAPIClient, AFNetworking, and sskeychain source files.

To set a compiler flag in Xcode, go to your active target and select the "Build Phases" tab. Now select all relevate source files, press Enter, insert -fobjc-arc, and then "Done" to enable ARC.

## Acknowledgements

CIOAPIClient would not be possible without the wonderful networking library [AFNetworking](https://github.com/AFNetworking/AFNetworking) - many thanks to [Mattt Thompson](https://github.com/mattt/) and [Scott Raymond](https://github.com/sco/)!

Thanks as well to [Sam Soffes](https://github.com/soffes) for [sskeychain](https://github.com/soffes/sskeychain), and [Jaanus Kase](https://github.com/jaanus) for  [PlainOAuth](https://github.com/jaanus/PlainOAuth) which was used in part for the OAuth signature generation in CIOAPIClient.

## License

CIOAPIClient is licensed under the MIT License. See the LICENSE file for details.