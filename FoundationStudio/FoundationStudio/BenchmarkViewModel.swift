//
//  BenchmarkViewModel.swift
//  FoundationStudio
//
//  Created by AI Assistant on 10/25/25.
//

import BenchmarkCore
import Foundation
import FoundationModels
import Observation

@MainActor
@Observable
final class BenchmarkViewModel {

    struct StatusMessage: Identifiable, Equatable {
        let id = UUID()
        let timestamp: Date
        let text: String

        var formattedTimestamp: String {
            Self.formatter.string(from: timestamp)
        }

        private static let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            return formatter
        }()
    }

    // MARK: - Published State

    var isRunning = false
    var statusMessages: [StatusMessage] = []
    var result: BenchmarkResult?
    var errorMessage: String?

    // MARK: - Prompt / Options

    let prompt: BenchmarkPrompt
    private let generationOptions: GenerationOptions
    private var runCount = 0

    init(
        prompt: BenchmarkPrompt = .productDesign,
        options: GenerationOptions = BenchmarkRunner.defaultGenerationOptions
    ) {
        self.prompt = prompt
        self.generationOptions = options
        appendStatus("Benchmark ready. Tap Run Benchmark to start.")
    }

    // MARK: - Actions

    func runBenchmark() {
        guard !isRunning else { return }

        isRunning = true
        errorMessage = nil
        result = nil
        runCount += 1

        appendStatus("Run #\(runCount) started.")

        let configuration = BenchmarkRunner.Configuration(
            prompt: prompt,
            options: generationOptions
        )

        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }

            let runner = BenchmarkRunner(configuration: configuration)

            do {
                let benchmarkResult = try await runner.run()
                await self.handleSuccess(benchmarkResult)
            } catch {
                await self.handleFailure(error)
            }
        }
    }

    func exportMarkdown() -> String? {
        guard let result else { return nil }
        return BenchmarkReport(result: result).markdownSummary()
    }

    func exportJSON(prettyPrinted: Bool = true) -> String? {
        guard let result else { return nil }
        return try? BenchmarkReport(result: result).json(prettyPrinted: prettyPrinted)
    }

    // MARK: - Private Helpers

    private func handleSuccess(_ benchmarkResult: BenchmarkResult) {
        result = benchmarkResult
        let duration = String(format: "%.2f", benchmarkResult.metrics.duration)
        appendStatus("Completed successfully in \(duration)s.")
        isRunning = false
    }

    private func handleFailure(_ error: Error) {
        errorMessage = error.localizedDescription
        appendStatus("Failed: \(error.localizedDescription)")
        isRunning = false
    }

    private func appendStatus(_ text: String) {
        statusMessages.append(StatusMessage(timestamp: Date(), text: text))
    }
}
