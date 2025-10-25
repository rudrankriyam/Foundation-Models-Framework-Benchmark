import Foundation
import FoundationModels

// MARK: - Runner

public actor BenchmarkRunner {
    public struct Configuration: Sendable {
        public let prompt: BenchmarkPrompt
        public let options: GenerationOptions

        public init(
            prompt: BenchmarkPrompt = .productDesign,
            options: GenerationOptions = BenchmarkRunner.defaultGenerationOptions
        ) {
            self.prompt = prompt
            self.options = options
        }
    }

    public enum Error: Swift.Error, LocalizedError, Sendable {
        case modelUnavailable(SystemLanguageModel.Availability.UnavailableReason)
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

    public static let defaultGenerationOptions = GenerationOptions(
        sampling: .greedy,
        temperature: 0.1
    )

    private let configuration: Configuration

    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
    }

    public func run(onPartial: (@Sendable (String) async -> Void)? = nil) async throws -> BenchmarkResult {
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
            if let onPartial {
                await onPartial(responseText)
            }
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
