//
//  MIORestClient.swift
//  IIJMioKit
//
//  Created by Safx Developer on 2015/05/12.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation

extension Router {

    private static let baseURLString = "https://api.iijmio.jp"

    public var URLRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: Router.baseURLString + path)!)
        request.HTTPMethod = self.method

        let params = self.params
        if !params.isEmpty {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: [])
        }
        return request
    }
}


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

    private var session_: NSURLSession!
    private var session: NSURLSession {
        precondition(clientID != "" && redirectURI != "", "should be non-nil")
        if session_ == nil {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.timeoutIntervalForRequest = 30.0
            let headers: [NSObject : AnyObject] = [
                "X-IIJmio-Developer": clientID,
                "X-IIJmio-Authorization": accessToken!
            ]
            configuration.HTTPAdditionalHeaders = headers
            session_ = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }
        return session_
    }

    private var callback: OAuthCompletionClosure = { (err) in }

    private let accountStore = OAuth2AccountStore(serviceName: "IIJMioCouponAPI")


    public var authorized: Bool {
        return accessToken != nil
    }

    public func setUp(clientID: String, redirectURI: String, state: String) {
        self.clientID = clientID
        self.redirectURI = redirectURI
        self.state = state
    }

    public func loadAccessToken() -> KeychainResult {
        let result = accountStore.loadAccessToken()
        if let t = result.token {
            accessToken = t
        }
        return result.status
    }

    public func getCoupon(completion: (MIOCouponResponse?, NSError?) -> Void) {
        request(Router.GetCoupon, completion: completion)
    }

    public func getPacket(completion: (MIOPacketResponse?, NSError?) -> Void) {
        request(Router.GetPacket, completion: completion)
    }

    public func putCoupon(useCoupon: Bool, hdoServiceCode: String, completion: (MIOChangeCouponResponse?, NSError?) -> Void) {
        let info = [MIOCouponSwitchHdoInfo(hdoInfo: [MIOCouponUse(hdoServiceCode: hdoServiceCode, couponUse: useCoupon)])]
        request(Router.PutCoupon(couponInfo: info), completion: completion)
    }

    public func getMergedInfo(completion: (MIOCouponResponse?, NSError?) -> Void) {
        getCoupon { [weak self] (response1, error1) -> Void in
            if let r1 = response1 {
                self?.getPacket { (response2, error2) -> Void in
                    if let r2 = response2 {
                        completion(MIORestClient.merge(r1, packetResponse: r2), nil)
                    } else {
                        //completion(nil, error2 ?? NSError())
                    }
                }
            } else {
                //completion(nil, error1 ?? NSError())
            }
        }
    }

    private class func merge(couponResponse: MIOCouponResponse, packetResponse: MIOPacketResponse) -> MIOCouponResponse {
        for couponInfo in couponResponse.couponInfo ?? [] {
            let hdd = couponInfo.hddServiceCode
            let pli = (packetResponse.packetLogInfo ?? []).filter { $0.hddServiceCode == hdd }
            if let plix = pli.first {
                precondition(pli.count == 1, "only one element")
                for j in couponInfo.hdoInfo {
                    let hdo = j.hdoServiceCode
                    let phi = plix.hdoInfo.filter { $0.hdoServiceCode == hdo }
                    if let phix = phi.first {
                        j.packetLog = phix.packetLog;
                    }
                }
            }
        }

        return couponResponse
    }

    private func request<T where T: JSONDecodable, T == T.DecodedType>(router: Router, completion: (T?, NSError?) -> Void) {
        let task = session.dataTaskWithRequest(router.URLRequest) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if let d = data {
                let jsonObj = try! NSJSONSerialization.JSONObjectWithData(d, options: [])
                let m = try! T.parseJSON(jsonObj as! [String : AnyObject])
                completion(m, nil)
            } else {
                completion(nil, error ?? NSError(domain: "jp.blogspot.safx-dev.IIJMio", code: 10400, userInfo: nil))
            }
        }
        task?.resume()
    }
}

extension MIORestClient {

    private func authorizeRequest() -> NSURLRequest {
        precondition(clientID != "" && redirectURI != "" && state != "", "should be non-nil")

        let dic = [ "response_type":"token", "client_id":clientID, "redirect_uri":redirectURI, "state":state ]
        if let c = NSURLComponents(string: "https://api.iijmio.jp/mobile/d/v1/authorization/") {
            let kv = dic.map { (k, v) in "\(k)=\(v)" }
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
            params = frag.componentsSeparatedByString("&").reduce([:]) { (var a, e) in
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

    public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        callback(error)
    }
}

#endif

