import Foundation
import BenchmarkCore
import FoundationModels

@main
struct TokenTraceCLI {
    static func main() async {
        let arguments = CommandLine.arguments

        // Check if running with xctrace (will have "token-test" argument)
        let runWithXctrace = arguments.contains("token-test")

        if runWithXctrace {
            await runWithXctraceRecording()
        } else {
            await runNormalBenchmark()
        }
    }

    static func runNormalBenchmark() async {
        do {
            print("TokenTraceCLI - Foundation Models Benchmark")
            print(String(repeating: "=", count: 80))
            print("Using .productDesign prompt with greedy sampling (temp=0.1)")
            print()

            let runner = BenchmarkRunner()
            let result = try await runner.run()

            print("\nBenchmark completed successfully!")
            print("\nEstimated Metrics:")
            print("  Duration: \(String(format: "%.2fs", result.metrics.duration))")
            if let ttft = result.metrics.timeToFirstToken {
                print("  Time to First Token: \(String(format: "%.2fs", ttft))")
            }
            print("  Prompt Tokens (est.): \(result.metrics.promptTokenEstimate)")
            print("  Response Tokens (est.): \(result.metrics.responseTokenEstimate)")
            print("  Total Tokens (est.): \(result.metrics.totalTokenEstimate)")
            print("  Tokens/sec (est.): \(String(format: "%.2f", result.metrics.tokensPerSecond ?? 0))")

            print("\nResponse preview (first 200 chars):")
            let preview = String(result.responseText.prefix(200))
            print("  \(preview)...")
            print()

            print(String(repeating: "=", count: 80))
            print("To get ACTUAL token counts with xctrace:")
            print("   xctrace record --instrument 'Foundation Models' \\")
            print("     --output token-test.trace \\")
            print("     --launch -- ./TokenTraceCLI -- token-test")
            print()
            print("   Then export:")
            print("   xctrace export \\")
            print("     --input token-test.trace \\")
            print("     --xpath '/trace-toc/run[@number=\"1\"]/data/table[@schema=\"FoundationModelsTable\"]' \\")
            print("     > token-export.xml")
        } catch {
            print("Error: \(error)")
            exit(1)
        }
    }

    static func runWithXctraceRecording() async {
        do {
            print("Running benchmark with xctrace Foundation Models instrument recording...")
            print("Make sure xctrace is recording this process!")
            print()

            let runner = BenchmarkRunner()
            let result = try await runner.run()

            print("\nBenchmark completed!")
            print("\nEstimated Metrics:")
            print("  Duration: \(String(format: "%.2fs", result.metrics.duration))")
            if let ttft = result.metrics.timeToFirstToken {
                print("  Time to First Token: \(String(format: "%.2fs", ttft))")
            }
            print("  Prompt Tokens (est.): \(result.metrics.promptTokenEstimate)")
            print("  Response Tokens (est.): \(result.metrics.responseTokenEstimate)")
            print("  Total Tokens (est.): \(result.metrics.totalTokenEstimate)")
            print("  Tokens/sec (est.): \(String(format: "%.2f", result.metrics.tokensPerSecond ?? 0))")

            print("\n" + String(repeating: "=", count: 80))
            print("To extract actual token data, export the trace:")
            print("   xctrace export \\")
            print("     --input token-test.trace \\")
            print("     --xpath '/trace-toc/run[@number=\"1\"]/data/table[@schema=\"FoundationModelsTable\"]' \\")
            print("     > token-export.xml")
        } catch {
            print("Error: \(error)")
            exit(1)
        }
    }
}

