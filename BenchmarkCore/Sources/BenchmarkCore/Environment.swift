import Foundation

// MARK: - Environment Snapshot

public struct EnvironmentSnapshot: Codable, Sendable {
    public let deviceName: String
    public let systemName: String
    public let systemVersion: String
    public let localeIdentifier: String
    public let appVersion: String?
    public let buildNumber: String?
    public let hardwareModel: String?
    public let timestamp: Date

    public init(
        deviceName: String,
        systemName: String,
        systemVersion: String,
        localeIdentifier: String,
        appVersion: String?,
        buildNumber: String?,
        hardwareModel: String?,
        timestamp: Date = Date()
    ) {
        self.deviceName = deviceName
        self.systemName = systemName
        self.systemVersion = systemVersion
        self.localeIdentifier = localeIdentifier
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.hardwareModel = hardwareModel
        self.timestamp = timestamp
    }

    public static func capture(bundle: Bundle = .main) -> EnvironmentSnapshot {
        let processInfo = ProcessInfo.processInfo
        let osVersion = processInfo.operatingSystemVersion
        let versionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        let localeIdentifier = Locale.current.identifier
        let deviceName = processInfo.hostName

        let hardwareModel = processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"]

        #if os(macOS)
        let systemName = "macOS"
        #elseif os(iOS)
        let systemName = "iOS"
        #elseif os(visionOS)
        let systemName = "visionOS"
        #else
        let systemName = processInfo.operatingSystemVersionString
        #endif

        let shortVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let buildNumber = bundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String

        return EnvironmentSnapshot(
            deviceName: deviceName,
            systemName: systemName,
            systemVersion: versionString,
            localeIdentifier: localeIdentifier,
            appVersion: shortVersion,
            buildNumber: buildNumber,
            hardwareModel: hardwareModel,
            timestamp: Date()
        )
    }
}
