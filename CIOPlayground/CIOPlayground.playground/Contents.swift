//: Playground - noun: a place where people can play

import CIOAPIClient
import XCPlayground
import WebKit

final class CIOAuthenticator {
    let delegate = WebViewDelegate()
    var session: CIOAPISession
    var window: NSWindow?

    init(session: CIOAPISession) {
        self.session = session
    }

    func withAuthentication(block: CIOAPISession -> Void) {
        if !session.isAuthorized {
            let app = NSApplication.sharedApplication()
            app.setActivationPolicy(.Regular)
            let s = session
            delegate.tokenHandler = { token in
                s.fetchAccountWithConnectToken(token).executeWithSuccess(
                    { responseDict in
                        self.window?.close()
                        self.window = nil
                        s.completeLoginWithResponse(responseDict, saveCredentials: true)
                        block(s)
                    }, failure: { error in
                        println("token fetch failure: \(error)")
                })
            }
            s.beginAuthForProviderType(.Gmail, callbackURLString: "cio-api-auth://", params: nil)
                .executeWithSuccess({ responseDict in
                    let redirectURL = s.redirectURLFromResponse(responseDict)

                    let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 400, height: 600))
                    let window = NSWindow(contentRect: webView.bounds, styleMask: NSTitledWindowMask | NSClosableWindowMask, backing: .Buffered, defer: false)

                    let request = NSURLRequest(URL: redirectURL)
                    webView.loadRequest(request)
                    webView.navigationDelegate = self.delegate

                    window.title = "Authenticate With Context.IO"
                    window.contentView.addSubview(webView)
                    window.makeKeyAndOrderFront(nil)
                    self.window = window
                    }, failure: { error in
                        println(error)
                })
        } else {
            block(session)
        }
    }
}

XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: true)

let s: CIOAPISession = CIOAPISession(consumerKey: "", consumerSecret: "")
if s.valueForKey("OAuthConsumerKey") as? String == "" {
    assertionFailure("Please provide your consumer key and consumer secret.")
}

// Uncomment this line and let the playground execute to clear previous
// credentials and authenticate with a new email account:
//s.clearCredentials()
let authenticator = CIOAuthenticator(session: s)

authenticator.withAuthentication() { session in
    let request = session.getContactsWithParams(nil)
    request.executeWithSuccess({ responseDict in
            println(responseDict)
            let contactsArray = responseDict["matches"] as! [[NSObject: AnyObject]]
            let names = contactsArray.map { $0["name"] as! String }
            names
        },
        failure: { error in
            println("\(error)")
    })
}

