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
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
@Observable
final class BenchmarkViewModel {

    // MARK: - Published State

    var isRunning = false
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
    }

    // MARK: - Actions

    func runBenchmark() {
        guard !isRunning else { return }

        isRunning = true
        errorMessage = nil
        result = nil
        runCount += 1

        let configuration = BenchmarkRunnerConfiguration(
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

    func copyMarkdownToClipboard() {
        guard let markdown = exportMarkdown() else { return }
#if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(markdown, forType: .string)
#else
        UIPasteboard.general.string = markdown
#endif
    }

    // MARK: - Private Helpers

    private func handleSuccess(_ benchmarkResult: BenchmarkResult) {
        result = benchmarkResult
        isRunning = false
    }

    private func handleFailure(_ error: Error) {
        errorMessage = error.localizedDescription
        isRunning = false
    }
}
