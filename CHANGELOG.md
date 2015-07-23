# CIOAPIClient CHANGELOG

## 0.9.1

* Documentation improvements
* Carthage support
* Improved cocoapods metadata

## 0.9.0

* SDK redesign
    - Refactor `CIOAPIClient` in to `CIOAPIClient`, `CIOAPISession`, and `CIORequest`
    - `CIOAPIClient` constructs `CIORequests`
    - `CIOAPISession` executes `CIORequests` in an internal `NSURLSession`
    - Success and Error handling are centralized in `CIOAPISession` rather than being specially typed for each request
    - For convenience, `CIORequests` constructed by an instance of `CIOAPISession` retain a reference to the session and can be executed directly
* Remove `AFNetworking` dependency
* Modernize OAuth handling via [TDOAuth](https://github.com/tweetdeck/tdoauth) library
    - This fixes a compilation issue on 64 bit architectures
* Use of `NSURLSession` necessitates dropping support for versions of iOS prior to 7.0, and OS X prior to 10.9

## 0.8.0 - 0.8.9

* See the [github changelog](https://github.com/contextio/contextio-ios/commits/0.8.9)