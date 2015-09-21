//: Playground - noun: a place where people can play

import CIOAPIClient
import XCPlayground
import WebKit

XCPSetExecutionShouldContinueIndefinitely(true)

let liteSession = CIOLiteClient(consumerKey: "", consumerSecret: "")
if liteSession.valueForKey("OAuthConsumerKey") as? String == "" {
    assertionFailure("Please provide your consumer key and consumer secret.")
}
// Uncomment this line and let the playground execute to clear previous
// credentials and authenticate with a new email account:
//liteSession.clearCredentials()

// Load the first email in the current account's inbox, and display it in a WKWebView.
// Open the assistant navigator to the Timeline display to see the webview.
CIOAuthenticator(session: liteSession).withAuthentication{ session in
    let folderName = "INBOX"
    session.getMessagesForFolderWithPath(folderName, accountLabel: nil).executeWithSuccess({ response in
        guard let firstMessage = response.first as? [String: AnyObject] else { return }
        guard let messageID = firstMessage["message_id"] as? String else { return }
        let request = session.requestForMessageWithID(messageID,
            inFolder: folderName, accountLabel: nil, delimiter: nil)
        request.include_body = true
        request.include_headers = "1"
        request.executeWithSuccess({ response in
                response
                response["headers"]
            guard let bodies = response["bodies"] as? [[NSObject: AnyObject]] else { return }
            for body in bodies {
                if (body["type"] as? String) == "text/html" {
                    let htmlContent = body["content"] as! String
                    let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 500, height: 800))
                    webView.loadHTMLString(htmlContent, baseURL: nil)
                    XCPShowView("webView", view: webView)
                }
            }
            }, failure: { error in
                print("Message load error: \(error)")
        })
        },

        failure: { error in
            print("Error: \(error)")
    })
}

// Uncomment the following to use Context.IO API V2 rather than lite:

//let s = CIOV2Client(consumerKey: "", consumerSecret: "")
//if s.valueForKey("OAuthConsumerKey") as? String == "" {
//    assertionFailure("Please provide your consumer key and consumer secret.")
//}
//
//// Uncomment this line and let the playground execute to clear previous
//// credentials and authenticate with a new email account:
////s.clearCredentials()
//let authenticator = CIOAuthenticator(session: s)
//
//authenticator.withAuthentication() { session in
//    session.getContacts().executeWithSuccess({ responseDict in
//            print(responseDict)
//            let contactsArray = responseDict["matches"] as! [[NSObject: AnyObject]]
//            let names = contactsArray.map { $0["name"] as! String }
////            String(format: "Contacts: %@", names.join)
//        },
//        failure: { error in
//            print("\(error)")
//    })
//}
//


///////

// Utility classes for authenticating with the CIO API via an OS X WebKit View

final class CIOAuthenticator<Client: CIOAPIClient> {
    let delegate = WebViewDelegate()
    var session: Client
    var window: NSWindow?

    init(session: Client) {
        self.session = session
    }

    func withAuthentication(block: Client -> Void) {
        if !session.isAuthorized {
            let app = NSApplication.sharedApplication()
            app.setActivationPolicy(.Regular)
            let s = session
            delegate.tokenHandler = { token in
                s.fetchAccountWithConnectToken(token).executeWithSuccess(
                    { responseDict in
                        self.window?.close()
                        self.window = nil
                        if s.completeLoginWithResponse(responseDict, saveCredentials: true) {
                            block(s)
                        }
                    }, failure: { error in
                        print("token fetch failure: \(error)")
                })
            }
            s.beginAuthForProviderType(.Gmail, callbackURLString: "cio-api-auth://", params: nil)
                .executeWithSuccess({ responseDict in
                    let redirectURL = s.redirectURLFromResponse(responseDict)

                    let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 400, height: 600))
                    let window = NSWindow(contentRect: webView.bounds,
                        styleMask: NSTitledWindowMask | NSClosableWindowMask,
                        backing: .Buffered,
                        `defer`: false)

                    let request = NSURLRequest(URL: redirectURL)
                    webView.loadRequest(request)
                    webView.navigationDelegate = self.delegate

                    window.title = "Authenticate With Context.IO"
                    window.contentView?.addSubview(webView)
                    window.makeKeyAndOrderFront(nil)
                    self.window = window
                    },
                    failure: { error in
                        print(error)
                })
        } else {
            block(session)
        }
    }
}

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
