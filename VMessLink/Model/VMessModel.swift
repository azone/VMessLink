//
//  VMessModel.swift
//  vmesslink
//
//  Created by 王要正 on 2021/1/18.
//

import Foundation

enum VMessField: String, Codable, Hashable, CaseIterable {
    case version = "v"
    case ps
    case address = "addr"
    case port
    case id
    case aid
    case net
    case type
    case host
    case path
    case tls

    var name: String {
        switch self {
        case .version:
            return "version"
        case .address:
            return "address"
        default:
            return rawValue
        }
    }

    var options: [String]? {
        switch self {
        case .net:
            return ["tcp", "kcp", "ws", "h2", "quic"]
        case .type:
            return ["none", "http", "srtp", "utp", "wechat-video"]
        case .tls:
            return ["tls"]
        default:
            return nil
        }
    }

    var defaultValue: String? {
        switch self {
        case .version:
            return "2"
        case .net:
            return "ws"
        case .type:
            return "none"
        case .tls:
            return "tls"
        default:
            return nil
        }
    }
}
