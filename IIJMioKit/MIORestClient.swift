//
//  MIORestClient.swift
//  IIJMioKit
//
//  Created by Safx Developer on 2015/05/12.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation

@objc public class MIORestClient: NSObject, NSURLSessionDelegate {
    public typealias OAuthCompletionClosure = (NSError? -> Void)

    public class var sharedClient : MIORestClient {
        struct Static {
            static let instance = MIORestClient()
        }
        return Static.instance
    }


    private var clientID   : String = ""
    private var redirectURI: String = ""
    private var state      : String = ""

    private var accessToken: String?

    private var session: NSURLSession!
    private var callback: OAuthCompletionClosure = { (err) in }

    private let accountStore = OAuth2AccountStore(serviceName: "IIJMioCouponAPI")


    public var authorized: Bool {
        return accessToken != nil
    }

    private override init() {
        accessToken = accountStore.queryAccessToken()
        super.init()
    }

    public func setUp(clientID: String, redirectURI: String, state: String) {
        self.clientID = clientID
        self.redirectURI = redirectURI
        self.state = state
    }


    public func getCoupon(completion: (MIOCouponResponse?, NSError?) -> Void) {
        request(createRequest("https://api.iijmio.jp/mobile/d/v1/coupon/"), completion: completion)
    }

    public func getPacket(completion: (MIOPacketResponse?, NSError?) -> Void) {
        request(createRequest("https://api.iijmio.jp/mobile/d/v1/log/packet/"), completion: completion)
    }

    public func putCoupon(useCoupon: Bool, hdoServiceCode: String, completion: (MIOChangeCouponResponse?, NSError?) -> Void) {
        var req = createRequest("https://api.iijmio.jp/mobile/d/v1/coupon/")
        req.HTTPMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = "{\"couponInfo\":[{\"hdoInfo\":[{\"hdoServiceCode\":\"\(hdoServiceCode)\",\"couponUse\":\(useCoupon)}]}]}"
        req.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        request(req, completion: completion)
    }

    private func request<T where T: JSONDecodable, T == T.DecodedType>(request: NSURLRequest, completion: (T?, NSError?) -> Void) {
        let task = session.dataTaskWithRequest(request) { [weak self] (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if data != nil {
                let m = MIORestClient.convert(data, nil as T?)
                completion(m)
            } else {
                // completion(nil, error)
                // FIXME: compilation error in release mode
                completion(nil, NSError())
            }
        }
        task.resume()
    }

    private static func convert<T where T: JSONDecodable, T == T.DecodedType>(data: NSData, _: T? = nil) -> (T?, NSError?) {
        var error: NSError? = nil
        let jsonObj: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error)
        if error != nil { return (nil, error) }

        let json: [String : AnyObject] = jsonObj as! [String : AnyObject]
        let (ret, err) = T.parseJSON(json)

        if ret != nil && err == nil {
            return (ret, nil)
        } else {
            return (nil, NSError(domain: "com.blogspot.safx-dev.IIJMioKit", code: 400, userInfo: [NSLocalizedDescriptionKey: err ?? "JSON decode Error"]))
        }
    }

    private func createRequest(urlString: String) -> NSMutableURLRequest {
        initializeSession()
        return NSMutableURLRequest(URL: NSURL(string: urlString)!)
    }

    private func initializeSession() {
        precondition(clientID != "" && accessToken != nil, "should be non-nil")
        if session == nil {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.timeoutIntervalForRequest = 15.0
            let headers: [NSObject : AnyObject] = [
                "X-IIJmio-Developer": clientID,
                "X-IIJmio-Authorization": accessToken!
            ]
            configuration.HTTPAdditionalHeaders = headers
            session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }
    }
}

extension MIORestClient {

    private func authorizeRequest() -> NSURLRequest {
        precondition(clientID != "" && redirectURI != "" && state != "", "should be non-nil")

        let dic = [ "response_type":"token", "client_id":clientID, "redirect_uri":redirectURI, "state":state ]
        if let c = NSURLComponents(string: "https://api.iijmio.jp/mobile/d/v1/authorization/") {
            let kv = map(dic) { (k, v) in "\(k)=\(v)" }
            c.query = "&".join(kv)
            if let url = c.URL {
                return NSURLRequest(URL: url)
            }
        }
        fatalError()
    }

    private func checkAccessToken(url: NSURL) -> Bool {
        let params: [String: String]
        if let frag = url.fragment {
            params = reduce(frag.componentsSeparatedByString("&"), [:]) { (var a, e) in
                let kv = e.componentsSeparatedByString("=")
                a[kv[0]] = kv[1]
                return a
            }
        } else {
            params = [:]
        }

        let s = (state as NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        if let ss = params["state"], token = params["access_token"] where ss == s {
            accessToken = token
            accountStore.saveAccessToken(token)
            return true
        }
        return false
    }
}


#if os(iOS)

extension MIORestClient {

    public func authorizeInView(view: UIView, closure: OAuthCompletionClosure) {
        callback = closure
        dispatch_async(dispatch_get_main_queue()) { () in
            let webView = UIWebView()
            webView.delegate = self
            webView.loadRequest(self.authorizeRequest())

            view.addSubview(webView)
            webView.frame = view.frame
        }
    }
}

extension MIORestClient: UIWebViewDelegate {
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let rq = request.URL, rd = NSURL(string:redirectURI) where rq.host == rd.host {
            if checkAccessToken(rq) {
                dispatch_async(dispatch_get_main_queue()) { () in
                    webView.removeFromSuperview()
                }
                callback(nil)
            }
        }
        return true
    }

    public func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        callback(error)
    }
}

#endif

