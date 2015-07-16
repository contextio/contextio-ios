//: Playground - noun: a place where people can play

import CIOAPIClient
import XCPlayground
import WebKit

final class CIOAuthenticator {
    let delegate = WebViewDelegate()
    var session: CIOAPISession
    var window: NSWindow?
    var webView: WKWebView?

    init(session: CIOAPISession) {
        self.session = session
    }

    func withAuthentication(block: CIOAPISession -> Void) {
        if !session.isAuthorized {
            let app = NSApplication.sharedApplication()
            app.setActivationPolicy(.Regular)
            let s = session
            delegate.tokenHandler = { token in
                s.executeDictionaryRequest(s.fetchAccountWithConnectToken(token),
                    success: { responseDict in
                        s.completeLoginWithResponse(responseDict, saveCredentials: true)
                        block(s)
                    },
                    failure: { error in
                        println("token fetch failure: \(error)")
                })
            }
            let authRequest = s.beginAuthForProviderType(.Gmail, callbackURLString: "cio-api-auth://", params: nil)
            s.executeDictionaryRequest(authRequest, success: { responseDict in
                let redirectURL = s.redirectURLFromResponse(responseDict)
                println("Redirect url: \(redirectURL)")

                self.webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 400, height: 600))
                let request = NSURLRequest(URL: redirectURL)
                self.webView?.loadRequest(request)
                self.webView?.navigationDelegate = self.delegate

                self.window = NSWindow(contentRect: self.webView!.bounds, styleMask: NSTitledWindowMask | NSClosableWindowMask, backing: .Buffered, defer: false)
                self.window?.title = "Authenticate With Context.IO"
                self.window?.contentView.addSubview(self.webView!)
                self.window?.makeKeyAndOrderFront(nil)

                }, failure: { error in
                    println(error)
            })
        } else {
            block(session)
        }
    }
}

XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: true)

assertionFailure("Please provide your consumer key and consumer secret and comment out this line.")
let s: CIOAPISession = CIOAPISession(consumerKey: "", consumerSecret: "")
let authenticator = CIOAuthenticator(session: s)

authenticator.withAuthentication() { session in
    session.executeDictionaryRequest(session.getContactsWithParams(nil),
        success: { responseDict in
            let contactsArray = responseDict["matches"] as! [[NSObject: AnyObject]]
            let names = contactsArray.map { $0["name"] as! String }
            names
        },
        failure: { error in
            error
            println("\(error)")
    })
}

