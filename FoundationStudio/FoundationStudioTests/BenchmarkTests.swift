import XCTest
import BenchmarkCore
import FoundationModels

final class BenchmarkTests: XCTestCase {

    func testProductDesignBenchmark() async throws {
        print("\n" + String(repeating: "=", count: 80))
        print("FOUNDATION MODELS BENCHMARK - Product Design Prompt")
        print(String(repeating: "=", count: 80))
        print()

        let runner = BenchmarkRunner()
        let result = try await runner.run()

        printBenchmarkResult(result)

        XCTAssertGreaterThan(result.metrics.promptTokenEstimate, 0)
        XCTAssertGreaterThan(result.metrics.responseTokenEstimate, 1000)
        XCTAssertGreaterThan(result.metrics.tokensPerSecond ?? 0, 10)
    }

    func testMultipleBenchmarkRuns() async throws {
        print("\n" + String(repeating: "=", count: 80))
        print("MULTIPLE BENCHMARK RUNS (3 iterations)")
        print(String(repeating: "=", count: 80))
        print()

        var results: [BenchmarkResult] = []
        for i in 1...3 {
            print("Run #\(i)")
            print(String(repeating: "-", count: 40))

            let runner = BenchmarkRunner()
            let result = try await runner.run()
            results.append(result)

            print("Duration: \(String(format: "%.2fs", result.metrics.duration))")
            print("Time to First Token: \(result.metrics.timeToFirstToken.map { String(format: "%.2fs", $0) } ?? "n/a")")
            print("Total Tokens: \(result.metrics.totalTokenEstimate)")
            print("Tokens/sec: \(String(format: "%.2f", result.metrics.tokensPerSecond ?? 0))")
            print()

            XCTAssertGreaterThan(result.metrics.tokensPerSecond ?? 0, 10)
        }

        print("Summary")
        print(String(repeating: "-", count: 40))
        let tokenRates = results.map { $0.metrics.tokensPerSecond ?? 0 }
        let avgTPS = tokenRates.reduce(0, +) / Double(results.count)
        print("Average Tokens/sec: \(String(format: "%.2f", avgTPS))")

        let minTPS = tokenRates.min() ?? 0
        let maxTPS = tokenRates.max() ?? 0
        print("Min Tokens/sec: \(String(format: "%.2f", minTPS))")
        print("Max Tokens/sec: \(String(format: "%.2f", maxTPS))")
        print("Variance: \(String(format: "%.2f", maxTPS - minTPS))")
        print()
    }

    func testCustomPromptBenchmark() async throws {
        print("\n" + String(repeating: "=", count: 80))
        print("CUSTOM PROMPT BENCHMARK")
        print(String(repeating: "=", count: 80))
        print()

        let customPrompt = BenchmarkPrompt(
            instructions: "You are a helpful assistant.",
            userPrompt: "Explain how neural networks work in 5 paragraphs with examples."
        )

        let config = BenchmarkRunnerConfiguration(prompt: customPrompt)
        let runner = BenchmarkRunner(configuration: config)
        let result = try await runner.run()

        print("Custom Prompt Results:")
        print("Duration: \(String(format: "%.2fs", result.metrics.duration))")
        print("Prompt Tokens: \(result.metrics.promptTokenEstimate)")
        print("Response Tokens: \(result.metrics.responseTokenEstimate)")
        print("Total Tokens: \(result.metrics.totalTokenEstimate)")
        print("Tokens/sec: \(String(format: "%.2f", result.metrics.tokensPerSecond ?? 0))")
        print()

        XCTAssertGreaterThan(result.metrics.responseTokenEstimate, 100)
        XCTAssertGreaterThan(result.metrics.tokensPerSecond ?? 0, 5)

        print("Response Preview:")
        print(String(repeating: "-", count: 40))
        let preview = String(result.responseText.prefix(300))
        print(preview)
        print("...")
        print()
    }

    private func printBenchmarkResult(_ result: BenchmarkResult) {
        print("Environment")
        print(String(repeating: "-", count: 40))
        print("Device: \(result.environment.deviceName)")
        print("OS: \(result.environment.systemName) \(result.environment.systemVersion)")
        print("Locale: \(result.environment.localeIdentifier)")
        print("Timestamp: \(result.environment.timestamp)")
        print()

        print("Performance Metrics")
        print(String(repeating: "-", count: 40))
        print("Duration: \(String(format: "%.2fs", result.metrics.duration))")
        print("Time to First Token: \(result.metrics.timeToFirstToken.map { String(format: "%.2fs", $0) } ?? "n/a")")
        print("Prompt Tokens (est.): \(result.metrics.promptTokenEstimate)")
        print("Response Tokens (est.): \(result.metrics.responseTokenEstimate)")
        print("Total Tokens (est.): \(result.metrics.totalTokenEstimate)")
        print("Tokens/sec: \(String(format: "%.2f", result.metrics.tokensPerSecond ?? 0))")
        print()

        print("Response Preview")
        print(String(repeating: "-", count: 40))
        let preview = String(result.responseText.prefix(300))
        print(preview)
        print("...")
        print()

        print(String(repeating: "=", count: 80))
        print()
    }
}
