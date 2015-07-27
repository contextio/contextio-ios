//
// This file (and all other Swift source files in the Sources directory of this playground) will be precompiled into a framework which is automatically made available to CIOPlayground.playground.
//

import Cocoa
import WebKit

public final class WebViewDelegate: NSObject, WKNavigationDelegate {
    public var tokenHandler: (String -> Void)? = nil

    public func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.URL
        if url?.scheme == "cio-api-auth" {
            if let components = NSURLComponents(URL: url!, resolvingAgainstBaseURL: false) {
                for queryItem in components.queryItems as! [NSURLQueryItem] {
                    if queryItem.name == "contextio_token" {
                        println("token: \(queryItem.value())")
                        tokenHandler?(queryItem.value()!)
                        decisionHandler(.Cancel)
                        return
                    }
                }
            }
        }
        decisionHandler(.Allow)
    }
}