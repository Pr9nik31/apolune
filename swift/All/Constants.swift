import Foundation

public let ProxyHost = "127.0.0.1"
public let TunMtu: NSNumber = 1500

public let StartModelFile = "run/start.json"

public enum Constants {
    #if SYSTEM_EXTENSION
    public static let useSystemExtension = true
    #else
    public static let useSystemExtension = false
    #endif
}

private let teamAppGroupId = "2CKAULFA9J.dev.apolune.client"
private let groupAppGroupId = "group.dev.apolune.client"
private let seGroupAppGroupId = "group.dev.apolune.client.se"

public func appGroupId() -> String {
    #if os(iOS)
        return groupAppGroupId
    #elseif os(macOS)
        if Constants.useSystemExtension {
            return seGroupAppGroupId
        } else {
            return teamAppGroupId
        }
    #endif
}

private let tunId = "dev.apolune.client.tun"
private let seTunId = "dev.apolune.client.se.tun"

public func packetTunnelId() -> String {
    #if os(iOS)
        return tunId
    #elseif os(macOS)
        if Constants.useSystemExtension {
            return seTunId
        } else {
            return tunId
        }
    #endif
}

private let serverAddress = "Apolune"
private let seServerAddress = "ApoluneSE"

public func vpnServerAddress() -> String {
    #if os(iOS)
        return serverAddress
    #elseif os(macOS)
        if Constants.useSystemExtension {
            return seServerAddress
        } else {
            return serverAddress
        }
    #endif
}

public func extensionGroupContainerURL() -> URL? {
    #if os(macOS)
    if Constants.useSystemExtension {
        return URL(fileURLWithPath: "/private/var/root/Library/Group Containers/\(appGroupId())")
    }
    #endif
    return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId())
}
