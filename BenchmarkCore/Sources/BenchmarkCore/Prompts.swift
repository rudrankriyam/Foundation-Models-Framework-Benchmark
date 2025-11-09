import Foundation

// MARK: - Prompt Definition

/// A prompt configuration for running benchmarks.
///
/// `BenchmarkPrompt` encapsulates both the system instructions and user prompt
/// that are sent to the language model during a benchmark run. The prompts are
/// automatically trimmed of leading and trailing whitespace.
///
/// ## Example
///
/// ```swift
/// let prompt = BenchmarkPrompt(
///     instructions: "You are a helpful assistant.",
///     userPrompt: "Explain quantum computing."
/// )
/// ```
public struct BenchmarkPrompt: Hashable, Codable, Sendable {
    /// The system instructions that define the model's behavior.
    public let instructions: String

    /// The user prompt that is sent to the model.
    public let userPrompt: String

    /// Creates a new benchmark prompt.
    ///
    /// Both the instructions and user prompt are automatically trimmed of
    /// leading and trailing whitespace.
    ///
    /// - Parameters:
    ///   - instructions: The system instructions for the model.
    ///   - userPrompt: The user prompt to send to the model.
    public init(instructions: String, userPrompt: String) {
        self.instructions = instructions.trimmingCharacters(in: .whitespacesAndNewlines)
        self.userPrompt = userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public extension BenchmarkPrompt {
    /// Canonical prompt designed to stress narrative, structured JSON, and SwiftUI reasoning.
    static let productDesign: BenchmarkPrompt = .init(
        instructions: """
        You are a senior product architect helping a multidisciplinary team evaluate a next-generation
        productivity companion.
        You think aloud, justify tradeoffs, and keep responses professional.
        """,
        userPrompt: """
        We are designing "Waypoint", a cross-platform productivity companion that runs on Mac, iPad, iPhone,
        and Vision Pro.
        In a single response, please:
        1. Summarize the product vision in exactly 5 tight paragraphs.
        2. Provide exactly 10 features in detail, including platform-specific affordances.
        3. Describe exactly 5 target personas and 5 launches risks directly in prose.
        """
    )
}
