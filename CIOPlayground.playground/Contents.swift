//: Playground - noun: a place where people can play

import CIOAPIClient
import XCPlayground
import WebKit

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
                        s.completeLoginWithResponse(responseDict, saveCredentials: true)
                        block(s)
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
                    }, failure: { error in
                        print(error)
                })
        } else {
            block(session)
        }
    }
}

XCPSetExecutionShouldContinueIndefinitely(true)

let liteSession = CIOLiteClient(consumerKey: "", consumerSecret: "")
if liteSession.valueForKey("OAuthConsumerKey") as? String == "" {
    assertionFailure("Please provide your consumer key and consumer secret.")
}
// Uncomment this line and let the playground execute to clear previous
// credentials and authenticate with a new email account:
//liteSession.clearCredentials()

CIOAuthenticator(session: liteSession).withAuthentication{ session in
    session.getEmailAccounts().executeWithSuccess({ response in
        response
        print(response)
        }, failure: { (error) -> Void in
            print(error)
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

