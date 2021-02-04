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
    case address = "add"
    case port
    case id
    case aid
    case net
    case type
    case host
    case path
    case tls
    case level
    case security

    var name: String {
        switch self {
        case .version:
            return "version"
        case .address:
            return "address"
        case .aid:
            return "alterID"
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
        case .security:
            return ["aes-128-gcm", "chacha20-poly1305", "auto", "none"]
        default:
            return nil
        }
    }

    var defaultValue: String? {
        switch self {
        case .version:
            return "2"
        case .aid:
            return "0"
        case .port:
            return "443"
        case .net:
            return "ws"
        case .type:
            return "none"
        case .tls:
            return "tls"
        case .path:
            return "/"
        case .level:
            return "0"
        case .security:
            return "auto"
        default:
            return nil
        }
    }
}
