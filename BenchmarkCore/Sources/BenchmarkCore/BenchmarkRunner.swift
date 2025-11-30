import Foundation
import FoundationModels

// MARK: - Benchmark Runner

/// Executes benchmarks against the Foundation Models framework.
///
/// `BenchmarkRunner` is an actor that runs benchmarks by sending prompts to the
/// system language model and measuring performance metrics including token counts,
/// duration, and throughput.
///
/// ## Example
///
/// ```swift
/// let runner = BenchmarkRunner()
/// let result = try await runner.run { partialText in
///     print("Streaming: \(partialText)")
/// }
/// print("Tokens/sec: \(result.metrics.tokensPerSecond ?? 0)")
/// ```
public actor BenchmarkRunner {
    /// Errors that can occur when running a benchmark.
    public enum Error: Swift.Error, LocalizedError, Sendable {
        /// The system language model is unavailable for the specified reason.
        case modelUnavailable(SystemLanguageModel.Availability.UnavailableReason)

        /// The model returned an empty response.
        case emptyResponse

        public var errorDescription: String? {
            switch self {
            case .modelUnavailable(let reason):
                return "Apple Intelligence is unavailable: \(reason)"
            case .emptyResponse:
                return "The model did not return a response."
            }
        }
    }

    /// Default generation options used for benchmarks.
    ///
    /// These options use greedy sampling with a low temperature (0.1) to ensure
    /// consistent, deterministic results suitable for benchmarking.
    public static let defaultGenerationOptions = GenerationOptions(
        sampling: .greedy,
        temperature: 0.1
    )

    private let configuration: BenchmarkRunnerConfiguration

    /// Creates a new benchmark runner with the specified configuration.
    ///
    /// - Parameter configuration: The configuration to use for running benchmarks.
    ///   Defaults to a configuration with `.productDesign` prompt and default
    ///   generation options.
    public init(configuration: BenchmarkRunnerConfiguration = .init()) {
        self.configuration = configuration
    }

    /// Runs a benchmark with the configured prompt and options.
    ///
    /// This method measures performance metrics including time to first token,
    /// total duration, and token counts.
    ///
    /// - Returns: A `BenchmarkResult` containing the metrics, environment information,
    ///   and the complete response text.
    /// - Throws: `BenchmarkRunner.Error` if the model is unavailable or returns
    ///   an empty response.
    public func run() async throws -> BenchmarkResult {
        try ensureModelAvailability()

        let session = LanguageModelSession(
            instructions: Instructions(configuration.prompt.instructions)
        )

        let startDate = Date()
        var responseText = ""
        var firstTokenDate: Date?

        let stream = session.streamResponse(
            to: Prompt(configuration.prompt.userPrompt),
            options: configuration.options
        )

        for try await snapshot in stream {
            if firstTokenDate == nil {
                firstTokenDate = Date()
            }
            responseText = renderPartialText(from: snapshot)
        }

        guard !responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw Error.emptyResponse
        }

        let endDate = Date()
        let transcript = session.transcript

        let promptTokens = transcript.estimatedTokenCount(filter: { entry in
            if case .prompt = entry { return true }
            if case .instructions = entry { return true }
            return false
        })

        let responseTokens = transcript.estimatedTokenCount(filter: { entry in
            if case .response = entry { return true }
            return false
        })

        let metrics = BenchmarkMetrics(
            start: startDate,
            end: endDate,
            timeToFirstToken: firstTokenDate.map { $0.timeIntervalSince(startDate) },
            promptTokenEstimate: promptTokens,
            responseTokenEstimate: responseTokens
        )

        let result = BenchmarkResult(
            prompt: configuration.prompt,
            metrics: metrics,
            environment: .capture(),
            responseText: responseText
        )

        return result
    }

    private func ensureModelAvailability() throws {
        let availability = SystemLanguageModel.default.availability
        if case .unavailable(let reason) = availability {
            throw Error.modelUnavailable(reason)
        }
    }
}
