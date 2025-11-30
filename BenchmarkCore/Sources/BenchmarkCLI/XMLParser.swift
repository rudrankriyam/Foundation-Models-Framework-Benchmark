import Foundation

// MARK: - XML Parsing for xctrace Foundation Models data

// Helper function to print comparison between estimated and actual values
private func printComparison(name: String, estimated: Int, actual: Int) {
    print("\(name):")
    print("  Estimated:  \(estimated)")
    print("  Actual:     \(actual)")
    let diff = actual - estimated
    let percent = estimated > 0 ? Double(diff) / Double(estimated) * 100 : 0
    print("  Difference: \(diff >= 0 ? "+" : "")\(diff) (\(String(format: "%.1f", percent))%)")
    print("")
}

struct TokenRow {
    let promptTokens: String?
    let responseTokens: String?
    let totalTokens: String?
}

struct FoundationModelsTable {
    let row: TokenRow?
}

enum XMLParseError: Error {
    case noData
    case invalidFormat
}

final class TokenXMLParser: NSObject, XMLParserDelegate {
    private var currentElement: String = ""
    private var currentRow: [String: String] = [:]
    private var foundRows: [[String: String]] = []
    private var currentValue: String = ""

    func parseXML(at path: String) throws -> FoundationModelsTable {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            throw XMLParseError.noData
        }

        let parser = XMLParser(data: data)
        parser.delegate = self
        let success = parser.parse()

        guard success else {
            throw XMLParseError.invalidFormat
        }

        let rowData = foundRows.first.map { dict in
            TokenRow(
                promptTokens: dict["promptTokens"],
                responseTokens: dict["responseTokens"],
                totalTokens: dict["totalTokens"]
            )
        }

        return FoundationModelsTable(row: rowData)
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName

        if elementName == "row" {
            currentRow = [:]
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !currentElement.isEmpty {
            currentValue = trimmed
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "row" {
            foundRows.append(currentRow)
            currentRow = [:]
        } else if elementName == "promptTokens" || elementName == "responseTokens" || elementName == "totalTokens" {
            currentRow[elementName] = currentValue
        }

        currentElement = ""
        currentValue = ""
    }
}

// MARK: - CLI Helper Functions

func parseTokenExportXML(_ xmlPath: String) {
    do {
        let parser = TokenXMLParser()
        let table = try parser.parseXML(at: xmlPath)

        guard let row = table.row else {
            print("No data found in XML")
            exit(1)
        }

        let actualPrompt = Int(row.promptTokens ?? "0") ?? 0
        let actualResponse = Int(row.responseTokens ?? "0") ?? 0
        let actualTotal = Int(row.totalTokens ?? "0") ?? 0

        print("ACTUAL Token Counts (from xctrace Foundation Models instrument):")
        print("=" + String(repeating: "=", count: 79))
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
            print("=" + String(repeating: "=", count: 79))
            print("")

            printComparison(name: "Prompt Tokens", estimated: estPrompt, actual: actualPrompt)
            printComparison(name: "Response Tokens", estimated: estResponse, actual: actualResponse)
            printComparison(name: "Total Tokens", estimated: estTotal, actual: actualTotal)

            print("Performance:")
            let actualTPS = Double(actualTotal) / duration
            let estimatedTPS = result.metrics.tokensPerSecond ?? 0
            print("  Duration:              \(String(format: "%.2fs", duration))")
            print("  Tokens/sec (est.):     \(String(format: "%.2f", estimatedTPS))")
            print("  Tokens/sec (actual):   \(String(format: "%.2f", actualTPS))")
            print("")

            if actualTPS > 0 {
                let tpsDiff = actualTPS - estimatedTPS
                let tpsPercent = estimatedTPS > 0 ? tpsDiff / estimatedTPS * 100 : 0
                print("  TPS Difference:        \(tpsDiff >= 0 ? "+" : "")\(String(format: "%.2f", tpsDiff)) (\(String(format: "%.1f", tpsPercent))%)")
            }

            print("")
            print("=" + String(repeating: "=", count: 79))
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
}
