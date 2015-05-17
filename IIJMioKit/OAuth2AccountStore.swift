//
//  OAuth2AccountStore.swift
//  IIJMioKit
//
//  Created by Safx Developer on 2014/09/22.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import Foundation

public class OAuth2AccountStore {
    private let serviceName: String
    
    init(serviceName: String) {
        self.serviceName = serviceName
    }
    
    private var attributes: [String:AnyObject] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
        ]
    }
    
    public func queryAccessToken() -> String? {
        var attrs = attributes
        attrs[kSecReturnAttributes as String] = kCFBooleanTrue

        var result: AnyObject?
        var status = withUnsafeMutablePointer(&result) { SecItemCopyMatching(attrs, UnsafeMutablePointer($0)) }

        if status == OSStatus(errSecSuccess) {
            let q = result as! NSDictionary
            let k = String(kSecAttrGeneric)
            if let data = q[k] as? NSString {
                return data as String
            }
        } else if status != OSStatus(errSecItemNotFound) {
            //
        }
        
        return nil
    }

    public func removeAccessToken() -> Bool {
        return SecItemDelete(attributes) == OSStatus(errSecSuccess)
    }
    
    public func saveAccessToken(token: String) -> Bool {
        var attrs = attributes
        attrs[kSecAttrGeneric as String] = token as NSString

        var result: AnyObject?
        var status = withUnsafeMutablePointer(&result) { SecItemAdd(attrs, UnsafeMutablePointer($0)) }

        if status != OSStatus(errSecDuplicateItem) {
            return status == OSStatus(errSecSuccess)
        }

        return SecItemUpdate(attributes, attrs) == OSStatus(errSecSuccess)
    }
}