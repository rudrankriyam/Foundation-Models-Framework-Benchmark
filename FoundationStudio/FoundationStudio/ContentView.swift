//
//  ContentView.swift
//  FoundationStudio
//
//  Created by Rudrank Riyam on 10/25/25.
//

import BenchmarkCore
import SwiftUI

struct ContentView: View {
    @State private var viewModel = BenchmarkViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    promptSection
                    executionSection
                    if let result = viewModel.result {
                        metricsSection(for: result)
                        exportSection
                    }
                    logSection
                    if viewModel.isRunning || !viewModel.streamingPreview.isEmpty {
                        streamingSection
                    }
                }
                .padding()
            }
            .navigationTitle("Foundation Benchmark")
        }
    }
    
    private var promptSection: some View {
        sectionCard(title: "Benchmark Prompt") {
            Text("Instructions")
                .font(.headline)
            Text(viewModel.prompt.instructions)
                .font(.body)
            
            Divider()
            
            Text("User Prompt")
                .font(.headline)
            Text(viewModel.prompt.userPrompt)
                .font(.body)
        }
    }
    
    private var executionSection: some View {
        sectionCard(title: "Execution") {
            Button(action: viewModel.runBenchmark) {
                Label(viewModel.isRunning ? "Benchmark Running…" : "Run Benchmark",
                      systemImage: viewModel.isRunning ? "hourglass" : "play.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
            }
            .tint(.indigo)
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isRunning)
            
            if viewModel.isRunning {
                ProgressView("Streaming response…")
                    .progressViewStyle(.linear)
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.callout)
                    .foregroundStyle(.red)
            } else if viewModel.result == nil {
                Text("Tap the button to measure Apple Intelligence throughput on this device.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func metricsSection(for result: BenchmarkResult) -> some View {
        sectionCard(title: "Latest Result") {
            metricsGrid(for: result)
            Divider()
            Text("Environment")
                .font(.headline)
            Text("\(result.environment.deviceName) • \(result.environment.systemName) \(result.environment.systemVersion)")
                .font(.body)
            if let appVersion = result.environment.appVersion, let build = result.environment.buildNumber {
                Text("App \(appVersion) (\(build))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text("Locale: \(result.environment.localeIdentifier)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private func metricsGrid(for result: BenchmarkResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            metricRow(title: "Duration", value: format(seconds: result.metrics.duration))
            metricRow(title: "Time to First Token", value: formatOptional(seconds: result.metrics.timeToFirstToken))
            metricRow(title: "Tokens / Second", value: formatOptional(number: result.metrics.tokensPerSecond))
            metricRow(title: "Prompt Tokens (est.)", value: "\(result.metrics.promptTokenEstimate)")
            metricRow(title: "Response Tokens (est.)", value: "\(result.metrics.responseTokenEstimate)")
            metricRow(title: "Total Tokens (est.)", value: "\(result.metrics.totalTokenEstimate)")
        }
    }
    
    private func metricRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(value)
                .bold()
        }
    }
    
    private var streamingSection: some View {
        sectionCard(title: viewModel.isRunning ? "Streaming Output" : "Last Response") {
            if viewModel.streamingPreview.isEmpty {
                Text("Awaiting tokens…")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    Text(viewModel.streamingPreview)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 220)
            }
        }
    }
    
    private var exportSection: some View {
        sectionCard(title: "Export & Share") {
            VStack(spacing: 12) {
                HStack {
                    Button {
                        viewModel.copyMarkdownToClipboard()
                    } label: {
                        Label("Copy Markdown", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        trySaveReport(format: .json(prettyPrinted: true))
                    } label: {
                        Label("Save JSON", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(.bordered)
                }
                
                HStack {
                    Button {
                        trySaveReport(format: .markdown)
                    } label: {
                        Label("Save Markdown", systemImage: "square.and.arrow.down.on.square")
                    }
                    .buttonStyle(.bordered)
                    
                    if let url = viewModel.lastSavedURL {
                        ShareLink(item: url) {
                            Label("Share Last Export", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.borderedProminent)
                    } else if let summary = viewModel.exportMarkdown() {
                        ShareLink(item: summary) {
                            Label("Share Summary", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }
    
    private var logSection: some View {
        sectionCard(title: "Status Log") {
            if viewModel.statusMessages.isEmpty {
                Text("No activity yet.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.statusMessages) { message in
                        HStack(alignment: .top, spacing: 8) {
                            Text(message.formattedTimestamp)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 110, alignment: .leading)
                            Text(message.text)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
    
    private func trySaveReport(format: BenchmarkViewModel.ExportFormat) {
        do {
            _ = try viewModel.saveReport(to: format)
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }
    
    private func format(seconds: TimeInterval) -> String {
        String(format: "%.2fs", seconds)
    }
    
    private func formatOptional(seconds: TimeInterval?) -> String {
        guard let seconds else { return "n/a" }
        return format(seconds: seconds)
    }
    
    private func formatOptional(number: Double?) -> String {
        guard let number else { return "n/a" }
        return String(format: "%.2f", number)
    }
    
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .bold()
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.secondary.opacity(0.08))
        )
    }
}

#Preview {
    ContentView()
}
