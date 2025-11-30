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
            return instructions.segments.reduce(0) { $0 + $1.estimatedInputTokenCount }
        case .prompt(let prompt):
            return prompt.segments.reduce(0) { $0 + $1.estimatedInputTokenCount }
        case .response(let response):
            return response.segments.reduce(0) { $0 + $1.estimatedOutputTokenCount }
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

extension Transcript.Segment {
    /// Estimates tokens for INPUT text (instructions/prompts) using a more conservative ratio
    /// Based on xctrace data: actual 235 vs estimated 228 (very accurate with 4.5 ratio)
    fileprivate var estimatedInputTokenCount: Int {
        switch self {
        case .text(let textSegment):
            return estimateInputTokens(textSegment.content)
        case .structure(let structuredSegment):
            return estimateInputTokens(structuredSegment.content.jsonString)
        @unknown default:
            return 0
        }
    }

    /// Estimates tokens for OUTPUT text (responses) using a more generous ratio
    /// Based on xctrace data: shows ~6.0 chars/token for responses
    fileprivate var estimatedOutputTokenCount: Int {
        switch self {
        case .text(let textSegment):
            return estimateOutputTokens(textSegment.content)
        case .structure(let structuredSegment):
            return estimateOutputTokens(structuredSegment.content.jsonString)
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
    // Default estimation: 6.0 chars per token (good for general use)
    let tokensPerChar = 1.0 / 6.0
    return max(1, Int(ceil(Double(text.count) * tokensPerChar)))
}

/// Estimates tokens for INPUT text (instructions/prompts)
/// Uses dynamic calibration based on measured data from xctrace
/// For the .productDesign prompt: 235 actual tokens from 1057 chars = 4.493 chars/token
private func estimateInputTokens(_ text: String) -> Int {
    guard !text.isEmpty else { return 0 }

    // Direct ratio: 235 tokens / 1057 chars = 0.2223 tokens/char
    let tokensPerChar = 235.0 / 1057.0
    return max(1, Int(ceil(Double(text.count) * tokensPerChar)))
}

/// Estimates tokens for OUTPUT text (responses)
/// Uses dynamic calibration based on measured data from xctrace
/// For the .productDesign response: 2276 actual tokens from 13680 chars = 6.0106 chars/token
private func estimateOutputTokens(_ text: String) -> Int {
    guard !text.isEmpty else { return 0 }

    // Direct ratio: 2276 tokens / 13680 chars = 0.1664 tokens/char
    let tokensPerChar = 2276.0 / 13680.0
    return max(1, Int(ceil(Double(text.count) * tokensPerChar)))
}

private func estimateTokens(for content: GeneratedContent) -> Int {
    let jsonString = content.jsonString
    return estimateTokens(jsonString)
}
