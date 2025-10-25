import Foundation
import FoundationModels

internal func renderPartialText(from snapshot: LanguageModelSession.ResponseStream<String>.Snapshot) -> String {
    if let value = try? snapshot.rawContent.value(String.self) {
        return value
    }

    let json = snapshot.rawContent.jsonString
    if let data = json.data(using: .utf8),
       let decoded = try? JSONDecoder().decode(String.self, from: data) {
        return decoded
    }

    return json
}

// MARK: - Transcript Token Utilities

extension Transcript.Entry {
    internal var benchmarkEstimatedTokenCount: Int {
        switch self {
        case .instructions(let instructions):
            return instructions.segments.reduce(0) { $0 + $1.estimatedTokenCount }
        case .prompt(let prompt):
            return prompt.segments.reduce(0) { $0 + $1.estimatedTokenCount }
        case .response(let response):
            return response.segments.reduce(0) { $0 + $1.estimatedTokenCount }
        case .toolCalls(let toolCalls):
            return toolCalls.reduce(0) { total, call in
                total
                + estimateTokens(call.toolName)
                + estimateTokens(for: call.arguments)
                + 5 // small fixed overhead
            }
        case .toolOutput(let output):
            return output.segments.reduce(0) { $0 + $1.estimatedTokenCount } + 3
        @unknown default:
            return 0
        }
    }
}

extension Transcript.Segment {
    fileprivate var estimatedTokenCount: Int {
        switch self {
        case .text(let textSegment):
            return estimateTokens(textSegment.content)
        case .structure(let structuredSegment):
            return estimateTokens(for: structuredSegment.content)
        @unknown default:
            return 0
        }
    }
}

extension Transcript {
    internal func estimatedTokenCount(filter: (Transcript.Entry) -> Bool) -> Int {
        reduce(0) { partialResult, entry in
            guard filter(entry) else { return partialResult }
            return partialResult + entry.benchmarkEstimatedTokenCount
        }
    }
}

private func estimateTokens(_ text: String) -> Int {
    guard !text.isEmpty else { return 0 }
    let tokensPerChar = 1.0 / 4.5
    return max(1, Int(ceil(Double(text.count) * tokensPerChar)))
}

private func estimateTokens(for content: GeneratedContent) -> Int {
    let jsonString = content.jsonString
    return estimateTokens(jsonString)
}
