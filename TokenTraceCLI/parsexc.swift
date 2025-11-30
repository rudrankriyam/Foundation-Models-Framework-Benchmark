#!/usr/bin/env swift
import Foundation
import XMLCoder

// MARK: - XML Structures

struct FoundationModelsTable: Decodable {
    let row: [TokenRow]?
}

struct TokenRow: Decodable {
    let promptTokens: String?
    let responseTokens: String?
    let totalTokens: String?

    enum CodingKeys: String, CodingKey {
        case promptTokens = "promptTokens"
        case responseTokens = "responseTokens"
        case totalTokens = "totalTokens"
    }
}

// MARK: - Main

guard CommandLine.arguments.count > 1 else {
    print("Usage: parsexc.swift <export.xml>")
    exit(1)
}

let xmlPath = CommandLine.arguments[1]

guard let xmlData = try? Data(contentsOf: URL(fileURLWithPath: xmlPath)) else {
    print("Failed to read XML file: \(xmlPath)")
    exit(1)
}

do {
    let decoder = XMLDecoder()
    let table = try decoder.decode(FoundationModelsTable.self, from: xmlData)

    guard let row = table.row?.first else {
        print("No data found in XML")
        exit(1)
    }

    let actualPrompt = Int(row.promptTokens ?? "0") ?? 0
    let actualResponse = Int(row.responseTokens ?? "0") ?? 0
    let actualTotal = Int(row.totalTokens ?? "0") ?? 0

    print("ACTUAL Token Counts (from xctrace Foundation Models instrument):")
    print("=" * 80)
    print("  Prompt Tokens:      \(actualPrompt)")
    print("  Response Tokens:    \(actualResponse)")
    print("  Total Tokens:       \(actualTotal)")
    print("")

    // If we have a benchmark result JSON, compare
    let jsonPath = "benchmark-result.json"
    if FileManager.default.fileExists(atPath: jsonPath),
       let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) {

        struct BenchmarkResult: Codable {
            let metrics: BenchmarkMetrics
        }

        struct BenchmarkMetrics: Codable {
            let promptTokenEstimate: Int
            let responseTokenEstimate: Int
            let totalTokenEstimate: Int
            let duration: Double
            let tokensPerSecond: Double?
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(BenchmarkResult.self, from: jsonData)

        let estPrompt = result.metrics.promptTokenEstimate
        let estResponse = result.metrics.responseTokenEstimate
        let estTotal = result.metrics.totalTokenEstimate
        let duration = result.metrics.duration

        print("COMPARISON (Estimated vs Actual):")
        print("=" * 80)
        print("")
        print("Prompt Tokens:")
        print("  Estimated:  \(estPrompt)")
        print("  Actual:     \(actualPrompt)")
        let promptDiff = actualPrompt - estPrompt
        let promptPercent = estPrompt > 0 ? Double(promptDiff) / Double(estPrompt) * 100 : 0
        print("  Difference: \(promptDiff >= 0 ? "+" : "")\(promptDiff) (\(String(format: "%.1f", promptPercent))%)")
        print("")
        print("Response Tokens:")
        print("  Estimated:  \(estResponse)")
        print("  Actual:     \(actualResponse)")
        let responseDiff = actualResponse - estResponse
        let responsePercent = estResponse > 0 ? Double(responseDiff) / Double(estResponse) * 100 : 0
        print("  Difference: \(responseDiff >= 0 ? "+" : "")\(responseDiff) (\(String(format: "%.1f", responsePercent))%)")
        print("")
        print("Total Tokens:")
        print("  Estimated:  \(estTotal)")
        print("  Actual:     \(actualTotal)")
        let totalDiff = actualTotal - estTotal
        let totalPercent = estTotal > 0 ? Double(totalDiff) / Double(estTotal) * 100 : 0
        print("  Difference: \(totalDiff >= 0 ? "+" : "")\(totalDiff) (\(String(format: "%.1f", totalPercent))%)")
        print("")

        print("Performance:")
        let actualTPS = Double(actualTotal) / duration
        print("  Duration:              \(String(format: "%.2fs", duration))")
        print("  Tokens/sec (est.):     \(String(format: "%.2f", result.metrics.tokensPerSecond ?? 0))")
        print("  Tokens/sec (actual):   \(String(format: "%.2f", actualTPS))")
        print("")

        if actualTPS > 0 {
            let tpsDiff = actualTPS - (result.metrics.tokensPerSecond ?? 0)
            let tpsPercent = (result.metrics.tokensPerSecond ?? 0) > 0 ?
                tpsDiff / (result.metrics.tokensPerSecond ?? 1) * 100 : 0
            print("  TPS Difference:        \(tpsDiff >= 0 ? "+" : "")\(String(format: "%.2f", tpsDiff)) (\(String(format: "%.1f", tpsPercent))%)")
        }

        print("")
        print("=" * 80)
        print("Comparison complete!")

        // Accuracy assessment
        let accuracy = 100.0 - abs(totalPercent)
        print("")
        if accuracy >= 95 {
            print("Excellent! Estimation is within 5% of actual token count.")
        } else if accuracy >= 90 {
            print("Good! Estimation is within 10% of actual token count.")
        } else if accuracy >= 80 {
            print("Estimation is off by more than 10%. Consider improving token estimation.")
        } else {
            print("Significant difference! Actual tokenization differs greatly from estimation.")
        }
    }

} catch {
    print("Failed to parse XML: \(error)")
    exit(1)
}
