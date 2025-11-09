import Foundation

// MARK: - Environment Snapshot

/// A snapshot of the execution environment at the time of a benchmark run.
///
/// `EnvironmentSnapshot` captures device information, system version, locale,
/// and application metadata. Use this to understand the context in which a
/// benchmark was executed.
///
/// ## Example
///
/// ```swift
/// let environment = EnvironmentSnapshot.capture()
/// print("Running on \(environment.deviceName) with \(environment.systemName) \(environment.systemVersion)")
/// ```
public struct EnvironmentSnapshot: Codable, Sendable {
    /// The name of the device where the benchmark was run.
    public let deviceName: String

    /// The name of the operating system (e.g., "macOS", "iOS", "visionOS").
    public let systemName: String

    /// The version of the operating system.
    public let systemVersion: String

    /// The locale identifier (e.g., "en_US").
    public let localeIdentifier: String

    /// The application version string, if available.
    public let appVersion: String?

    /// The application build number, if available.
    public let buildNumber: String?

    /// The hardware model identifier, if available.
    public let hardwareModel: String?

    /// The timestamp when the snapshot was captured.
    public let timestamp: Date

    /// Creates a new environment snapshot with the specified values.
    ///
    /// - Parameters:
    ///   - deviceName: The name of the device.
    ///   - systemName: The name of the operating system (e.g., "macOS", "iOS").
    ///   - systemVersion: The version of the operating system.
    ///   - localeIdentifier: The locale identifier (e.g., "en_US").
    ///   - appVersion: The application version string, if available.
    ///   - buildNumber: The application build number, if available.
    ///   - hardwareModel: The hardware model identifier, if available.
    ///   - timestamp: The timestamp for the snapshot. Defaults to the current date.
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

    /// Captures the current execution environment.
    ///
    /// This method automatically detects device information, system version,
    /// locale, and application metadata from the current process and bundle.
    ///
    /// - Parameter bundle: The bundle to read application metadata from.
    ///   Defaults to `.main`.
    /// - Returns: An `EnvironmentSnapshot` containing the current environment
    ///   information.
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
