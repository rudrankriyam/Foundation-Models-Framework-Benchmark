import Foundation

// MARK: - Prompt Definition

public struct BenchmarkPrompt: Hashable, Codable, Sendable {
    public let instructions: String
    public let userPrompt: String

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
