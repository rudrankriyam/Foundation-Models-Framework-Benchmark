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
    var lastSavedURL: URL?
    var streamingPreview: String = ""

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
        streamingPreview = ""
        runCount += 1

        appendStatus("Run #\(runCount) started.")

        let configuration = BenchmarkRunnerConfiguration(
            prompt: prompt,
            options: generationOptions
        )

        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }

            let runner = BenchmarkRunner(configuration: configuration)

            do {
                let benchmarkResult = try await runner.run { [weak self] partial in
                    guard let self else { return }
                    await self.updateStreamingPreview(partial)
                }
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

    func copyMarkdownToClipboard() {
        guard let markdown = exportMarkdown() else { return }
#if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(markdown, forType: .string)
#else
        UIPasteboard.general.string = markdown
#endif
        appendStatus("Copied Markdown summary to clipboard.")
    }

    enum ExportFormat {
        case markdown
        case json(prettyPrinted: Bool)

        var fileExtension: String {
            switch self {
            case .markdown: return "md"
            case .json: return "json"
            }
        }
    }

    func saveReport(to format: ExportFormat) throws -> URL {
        guard let result else {
            throw ExportError.missingResult
        }

        let report = BenchmarkReport(result: result)
        let content: String
        switch format {
        case .markdown:
            content = report.markdownSummary()
        case .json(let prettyPrinted):
            content = try report.json(prettyPrinted: prettyPrinted)
        }

        let directory = try benchmarkDirectory()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        let filename = "benchmark-\(formatter.string(from: Date())).\(format.fileExtension)"
        let destination = directory.appendingPathComponent(filename, isDirectory: false)

        try content.data(using: .utf8)?.write(to: destination, options: .atomic)

        lastSavedURL = destination
        appendStatus("Saved \(format.fileExtension.uppercased()) report to \(destination.path).")
        return destination
    }

    private func benchmarkDirectory() throws -> URL {
        let fileManager = FileManager.default
        let base = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directory = base.appendingPathComponent("FoundationStudio/BenchmarkResults", isDirectory: true)
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    enum ExportError: LocalizedError {
        case missingResult

        var errorDescription: String? {
            switch self {
            case .missingResult:
                return "Run the benchmark before exporting."
            }
        }
    }

    // MARK: - Private Helpers

    private func handleSuccess(_ benchmarkResult: BenchmarkResult) {
        result = benchmarkResult
        streamingPreview = benchmarkResult.responseText
        let duration = String(format: "%.2f", benchmarkResult.metrics.duration)
        appendStatus("Completed successfully in \(duration)s.")
        isRunning = false
    }

    private func handleFailure(_ error: Error) {
        errorMessage = error.localizedDescription
        appendStatus("Failed: \(error.localizedDescription)")
        isRunning = false
        streamingPreview = ""
    }

    private func appendStatus(_ text: String) {
        statusMessages.append(StatusMessage(timestamp: Date(), text: text))
    }

    @MainActor
    private func updateStreamingPreview(_ text: String) {
        streamingPreview = text
    }
}
