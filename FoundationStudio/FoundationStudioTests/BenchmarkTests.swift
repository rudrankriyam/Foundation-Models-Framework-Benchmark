//
//  BenchmarkTests.swift
//  FoundationStudio
//
//  Created by Rudrank Riyam on 12/1/25.
//


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

    private func printBenchmarkResult(_ result: BenchmarkResult) {
        print("Environment")
        print(String(repeating: "-", count: 40))
        print("Device: \(result.environment.deviceName)")

        // Display hardware information if available
        if let cpuModel = result.environment.cpuModel {
            let cores = result.environment.cpuCores ?? 0
            print("CPU: \(cpuModel) \(cores)-core")
        }

        if let gpuModel = result.environment.gpuModel {
            print("GPU: \(gpuModel)")
        }

        if let totalMemory = result.environment.totalMemory {
            let memoryGB = Double(totalMemory) / (1024.0 * 1024.0 * 1024.0)
            print("RAM: \(String(format: "%.0f GB", memoryGB))")
        }

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
