//
//  OAuth2AccountStore.swift
//  IIJMioKit
//
//  Created by Safx Developer on 2014/09/22.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import Foundation


public enum KeychainResult: String {
    case Success               = "No error."
    case Unimplemented         = "Function or operation not implemented."
    case Param                 = "One or more parameters passed to the function were not valid."
    case Allocate              = "Failed to allocate memory."
    case NotAvailable          = "No trust results are available."
    case AuthFailed            = "Authorization/Authentication failed."
    case DuplicateItem         = "The item already exists."
    case ItemNotFound          = "The item cannot be found."
    case InteractionNotAllowed = "Interaction with the Security Server is not allowed."
    case Decode                = "Unable to decode the provided data."
    case Unknown               = "Unknown error."

    public init(status: OSStatus) {
        switch status {
        case OSStatus(errSecSuccess)               : self = .Success
        case OSStatus(errSecUnimplemented)         : self = .Unimplemented
        case OSStatus(errSecParam)                 : self = .Param
        case OSStatus(errSecAllocate)              : self = .Allocate
        case OSStatus(errSecNotAvailable)          : self = .NotAvailable
        case OSStatus(errSecAuthFailed)            : self = .AuthFailed
        case OSStatus(errSecDuplicateItem)         : self = .DuplicateItem
        case OSStatus(errSecItemNotFound)          : self = .ItemNotFound
        case OSStatus(errSecInteractionNotAllowed) : self = .InteractionNotAllowed
        case OSStatus(errSecDecode)                : self = .Decode
        default                                    : self = .Unknown
        }
    }
}


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

    public func loadAccessToken() -> (status: KeychainResult, token: String?) {
        var attrs = attributes
        attrs[kSecReturnAttributes as String] = kCFBooleanTrue

        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) { SecItemCopyMatching(attrs, UnsafeMutablePointer($0)) }

        if status == OSStatus(errSecSuccess) {
            let q = result as! NSDictionary
            let k = String(kSecAttrGeneric)
            if let data = q[k] as? NSString {
                return (KeychainResult(status: status), data as String)
            } else {
                return (.Unknown, nil)
            }
        }
        return (KeychainResult(status: status), nil)
    }

    public func removeAccessToken() -> KeychainResult {
        return KeychainResult(status: SecItemDelete(attributes))
    }
    
    public func saveAccessToken(token: String) -> KeychainResult {
        var attrs = attributes
        attrs[kSecAttrGeneric as String] = token as NSString

        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) { SecItemAdd(attrs, UnsafeMutablePointer($0)) }

        if status != OSStatus(errSecDuplicateItem) {
            return KeychainResult(status: status)
        }

        return KeychainResult(status: SecItemUpdate(attributes, attrs))
    }
}