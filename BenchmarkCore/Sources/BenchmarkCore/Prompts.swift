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
        You are a senior product architect helping a multidisciplinary team evaluate a next-generation productivity companion. You think aloud, justify tradeoffs, and keep responses professional.
        """,
        userPrompt: """
        We are designing "Waypoint", a cross-platform productivity companion that runs on Mac, iPad, iPhone, and Vision Pro. In a single response, please:
        1. Summarize the product vision in 2 tight paragraphs.
        2. Provide a Markdown table with at least 5 features, including platform-specific affordances.
        3. Describe three target personas and three launches risks directly in prose (no JSON).
        4. Finish with annotated SwiftUI pseudocode (wrapped in ```swift) for a cross-platform dashboard view that highlights one shared component and one visionOS-only component. Favor deterministic, grounded language and keep the entire answer under 1000 words.
        """
    )
}
