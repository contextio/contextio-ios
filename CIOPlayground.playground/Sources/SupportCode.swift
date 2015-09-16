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
            if let queryItems = NSURLComponents(URL: url!, resolvingAgainstBaseURL: false)?.queryItems {
                for queryItem in queryItems {
                    if let value = queryItem.value where queryItem.name == "contextio_token" {
                        tokenHandler?(value)
                        decisionHandler(.Cancel)
                        return
                    }
                }
            }
        }
        decisionHandler(.Allow)
    }
}