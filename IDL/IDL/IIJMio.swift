//
//  IIJMio.swift
//  IDL
//
//  Created by Safx Developer on 2015/05/12.
//  Copyright (c) 2015年 Safx Developers. All rights reserved.
//

import Foundation

protocol ClassDefault: ClassInit, JSONDecodable, JSONEncodable, Printable {}
protocol EnumDefault: JSONDecodable, JSONEncodable, Printable {}

protocol ClassInit {}
protocol Printable {}
protocol JSONEncodable {}
protocol JSONDecodable {}
protocol URLRequestHelper {}
protocol EnumStaticInit {}

public enum Router: URLRequestHelper, Printable {
    case GetCoupon                                       // router:",/mobile/d/v1/coupon/"
    case GetPacket                                       // router:",/mobile/d/v1/log/packet/"
    case PutCoupon(couponInfo: [MIOCouponSwitchHdoInfo]) // router:"PUT,/mobile/d/v1/coupon/"
}

public class MIOCouponSwitchHdoInfo: ClassInit, JSONEncodable {
    public let hdoInfo: [MIOCouponUse] = []
}

public class MIOCouponUse: ClassInit, JSONEncodable {
    public let hdoServiceCode: String = ""
    public let couponUse: Bool = true
}

public enum MIOPlan: String {
    case FamilyShare = "Family Share"
    case MinimumStart = "Minimum Start"
    case LightStart = "Light Start"
}

public class MIOCouponResponse {
    public let returnCode: String
    public let couponInfo: [MIOCouponInfo]?
    init() { fatalError() }
}

public class MIOPacketResponse {
    public let returnCode: String
    public let packetLogInfo: [MIOPacketLogInfo]?
    init() { fatalError() }
}

public class MIOChangeCouponResponse {
    public let returnCode: String
    init() { fatalError() }
}


public class MIOCouponInfo {
    public let hddServiceCode: String
    public let plan: MIOPlan
    public let hdoInfo: [MIOCouponHdoInfo]
    public let coupon: [MIOCoupon]
    init() { fatalError() }
}

public class MIOCouponHdoInfo {
    public let hdoServiceCode: String
    public let number: String
    public let iccid: String
    public let regulation: Bool
    public let sms: Bool
    public let voice: Bool
    public var couponUse: Bool
    public let coupon: [MIOCoupon]

    public var packetLog: [MIOPacketLog] = [] // json:"-" // assgined from MIOPacketLogInfo
    init() { fatalError() }
}

public class MIOCoupon {
    public let volume: UInt
    public let expire: String?
    public let type: String
    init() { fatalError() }
}

public class MIOPacketLogInfo {
    public let hddServiceCode: String
    public let plan: MIOPlan
    public let hdoInfo: [MIOPacketHdoInfo]
    init() { fatalError() }
}

public class MIOPacketHdoInfo {
    public let hdoServiceCode: String
    public let packetLog: [MIOPacketLog]
    init() { fatalError() }
}

public class MIOPacketLog {
    public let date: NSDate
    public let withCoupon: UInt
    public let withoutCoupon: UInt
    init() { fatalError() }
}
