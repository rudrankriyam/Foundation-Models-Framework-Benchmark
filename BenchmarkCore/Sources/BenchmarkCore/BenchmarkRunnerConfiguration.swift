import Foundation
import FoundationModels

// MARK: - Benchmark Runner Configuration

/// Configuration options for running a benchmark with the Foundation Models framework.
///
/// Use `BenchmarkRunnerConfiguration` to customize the prompt and generation options
/// used when executing a benchmark. The configuration determines what prompt is sent
/// to the language model and how the model generates its response.
///
/// ## Example
///
/// ```swift
/// let configuration = BenchmarkRunnerConfiguration(
///     prompt: .productDesign,
///     options: BenchmarkRunner.defaultGenerationOptions
/// )
/// let runner = BenchmarkRunner(configuration: configuration)
/// let result = try await runner.run()
/// ```
public struct BenchmarkRunnerConfiguration: Sendable {
    /// The prompt to use for the benchmark.
    ///
    /// This includes both the system instructions and the user prompt that will be
    /// sent to the language model.
    public let prompt: BenchmarkPrompt

    /// The generation options that control how the model generates its response.
    ///
    /// These options include sampling strategy, temperature, and other parameters
    /// that affect the model's output.
    public let options: GenerationOptions

    /// Creates a new benchmark runner configuration.
    ///
    /// - Parameters:
    ///   - prompt: The prompt to use for the benchmark. Defaults to `.productDesign`.
    ///   - options: The generation options for the model. Defaults to
    ///     `BenchmarkRunner.defaultGenerationOptions`.
    public init(
        prompt: BenchmarkPrompt = .productDesign,
        options: GenerationOptions = BenchmarkRunner.defaultGenerationOptions
    ) {
        self.prompt = prompt
        self.options = options
    }
}
