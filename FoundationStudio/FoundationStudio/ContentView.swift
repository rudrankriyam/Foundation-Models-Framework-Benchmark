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
                    runSection
                    
                    Button(action: viewModel.runBenchmark) {
                        Label(viewModel.isRunning ? "Benchmark Running…" : "Run Benchmark",
                              systemImage: viewModel.isRunning ? "hourglass" : "play.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    }
                    .tint(.indigo)
                    .controlSize(.extraLarge)
                    .buttonStyle(.glassProminent)
                    .disabled(viewModel.isRunning)
                    
                    if let result = viewModel.result {
                        metricsSection(for: result)
                    }
                    logSection
                }
                .padding()
            }
            .navigationTitle("Foundation Benchmark")
        }
    }
    
    private var promptSection: some View {
            VStack(alignment: .leading, spacing: 12) {
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
    
    private var runSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.isRunning {
                    ProgressView("Streaming response…")
                        .progressViewStyle(.linear)
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.callout)
                        .foregroundStyle(.red)
            }
        }
    }
    
    private func metricsSection(for result: BenchmarkResult) -> some View {
            VStack(alignment: .leading, spacing: 12) {
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
    
    private var logSection: some View {
        Group {
            if viewModel.statusMessages.isEmpty {
                Text("No activity yet.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                    }
                }
            }
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
}

#Preview {
    ContentView()
}
