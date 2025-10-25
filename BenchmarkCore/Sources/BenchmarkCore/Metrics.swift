import Foundation

// MARK: - Metrics & Reporting

public struct BenchmarkMetrics: Codable, Sendable {
    public let start: Date
    public let end: Date
    public let duration: TimeInterval
    public let timeToFirstToken: TimeInterval?
    public let promptTokenEstimate: Int
    public let responseTokenEstimate: Int
    public let totalTokenEstimate: Int
    public let tokensPerSecond: Double?

    public init(
        start: Date,
        end: Date,
        timeToFirstToken: TimeInterval?,
        promptTokenEstimate: Int,
        responseTokenEstimate: Int
    ) {
        self.start = start
        self.end = end
        self.duration = end.timeIntervalSince(start)
        self.timeToFirstToken = timeToFirstToken
        self.promptTokenEstimate = promptTokenEstimate
        self.responseTokenEstimate = responseTokenEstimate
        self.totalTokenEstimate = promptTokenEstimate + responseTokenEstimate
        if duration > 0 {
            self.tokensPerSecond = Double(totalTokenEstimate) / duration
        } else {
            self.tokensPerSecond = nil
        }
    }
}

public struct BenchmarkResult: Codable, Sendable {
    public let prompt: BenchmarkPrompt
    public let metrics: BenchmarkMetrics
    public let environment: EnvironmentSnapshot
    public let responseText: String
}

public struct BenchmarkReport: Codable, Sendable {
    public let result: BenchmarkResult

    public init(result: BenchmarkResult) {
        self.result = result
    }

    public func json(prettyPrinted: Bool = true) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = prettyPrinted ? [.prettyPrinted, .sortedKeys] : []
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(result)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw CocoaError(.coderInvalidValue)
        }
        return jsonString
    }

    public func markdownSummary() -> String {
        """
        # Foundation Models Benchmark

        **Timestamp:** \(result.environment.timestamp)
        **Device:** \(result.environment.deviceName) • \(result.environment.systemName) \
        \(result.environment.systemVersion)
        **Locale:** \(result.environment.localeIdentifier)

        ## Metrics
        - Duration: \(String(format: "%.2fs", result.metrics.duration))
        - Time to First Token: \(formattedInterval(result.metrics.timeToFirstToken))
        - Prompt Tokens (est.): \(result.metrics.promptTokenEstimate)
        - Response Tokens (est.): \(result.metrics.responseTokenEstimate)
        - Total Tokens (est.): \(result.metrics.totalTokenEstimate)
        - Tokens / sec: \(formattedTPS(result.metrics.tokensPerSecond))

        ## Response
        \(result.responseText)
        """
    }

    private func formattedInterval(_ interval: TimeInterval?) -> String {
        guard let interval else { return "n/a" }
        return String(format: "%.2fs", interval)
    }

    private func formattedTPS(_ value: Double?) -> String {
        guard let value else { return "n/a" }
        return String(format: "%.2f", value)
    }
}
