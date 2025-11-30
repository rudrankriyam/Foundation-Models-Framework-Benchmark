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
    /// Canonical prompt designed to stress throughput with maximum token output.
    static let productDesign: BenchmarkPrompt = .init(
        instructions: "You are a helpful assistant. Write detailed, thorough responses.",
        userPrompt: """
        Describe the benefits of morning routines for productivity.

        Write 25 detailed paragraphs covering:
        - Why morning routines matter (5 paragraphs)
        - Physical health benefits (5 paragraphs)
        - Mental health benefits (5 paragraphs)
        - Productivity benefits (5 paragraphs)
        - How to build a morning routine (5 paragraphs)

        Each paragraph should be 4-5 sentences long. Write in detail.
        """
    )
}
