# TokenTraceCLI - Foundation Models Benchmark with xctrace

A command-line tool for benchmarking Foundation Models with **actual token counts** from the xctrace Foundation Models instrument.

## Overview

This CLI uses the same benchmarking system as BenchmarkCore (with the `.productDesign` prompt and greedy sampling) but integrates with `xctrace` to capture **actual token counts** from Apple's Foundation Models framework, rather than relying on character-based estimates.

## What It Does

1. **Runs a benchmark** using the Foundation Models framework with:
   - `.productDesign` prompt (25-paragraph comprehensive response)
   - Greedy sampling (temperature 0.1)
   - Same setup as the BenchmarkCore package

2. **Records with xctrace** to capture actual token metrics from the Foundation Models instrument

3. **Exports trace data** to XML format for analysis

4. **Compares estimated vs actual** token counts to measure estimation accuracy

## Quick Start

### Run Benchmark Normally (No xctrace)

```bash
./.build/debug/TokenTraceCLI
```

This will:
- Run the benchmark
- Display estimated token counts
- Show you how to enable xctrace recording

### Run with xctrace (Manual Workflow)

**Step 1:** Record the benchmark
```bash
xctrace record \
  --instrument 'Foundation Models' \
  --output token-test.trace \
  --launch -- ./.build/debug/TokenTraceCLI -- token-test
```

**Step 2:** Export the data
```bash
xctrace export \
  --input token-test.trace \
  --xpath '/trace-toc/run[@number="1"]/data/table[@schema="FoundationModelsTable"]' \
  > token-export.xml
```

**Step 3:** Parse the XML (optional)
```bash
swift parsexc.swift token-export.xml
```

### Run with Automated Script

Use the provided shell script for a fully automated workflow:

```bash
./run-trace.sh
```

This script will:
1. Build the CLI if needed
2. Clean up old trace files
3. Record with xctrace
4. Export to XML
5. Parse and compare (if parsexc.swift is available)

## Files

- `Sources/main.swift` - Main CLI executable
- `run-trace.sh` - Automated xctrace workflow script
- `parsexc.swift` - XML parsing and comparison script
- `Package.swift` - Swift package configuration

## Requirements

- **macOS 26.0+** (for Foundation Models framework)
- **Xcode Command Line Tools** (for xctrace)
- Swift 6.2+

## The Foundation Models Instrument

The xctrace Foundation Models instrument captures:
- **Prompt Tokens**: Tokens in the input prompt/instructions
- **Response Tokens**: Tokens in the generated response
- **Total Tokens**: Combined total of prompt + response

This gives us the **ground truth** for token counts, which we can compare against our character-based estimates.

## Why Use This?

The BenchmarkCore package estimates tokens based on character count, which may not be accurate for actual tokenization. By using xctrace with the Foundation Models instrument, we can:

1. **Validate token estimation accuracy**
2. **Measure actual throughput** (tokens/second) based on real token counts
3. **Compare estimation vs reality** to improve our benchmarks
4. **Get precise performance metrics** for the Foundation Models framework

## Output Example

```
TokenTraceCLI - Foundation Models Benchmark
================================================================================
Using .productDesign prompt with greedy sampling (temp=0.1)

[benchmark runs...]

Benchmark completed successfully!

Estimated Metrics:
  Duration: 12.34s
  Time to First Token: 0.23s
  Prompt Tokens (est.): 125
  Response Tokens (est.): 1069
  Total Tokens (est.): 1194
  Tokens/sec (est.): 96.81

Response preview (first 200 chars):
  You are a helpful assistant. CRITICAL RULE: You MUST write extremely detailed...

================================================================================
To get ACTUAL token counts with xctrace:
   xctrace record --instrument 'Foundation Models' \
     --output token-test.trace \
     --launch -- ./TokenTraceCLI -- token-test
```

## XML Export Format

The xctrace export creates an XML file with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<trace-toc>
  <run number="1">
    <data>
      <table schema="FoundationModelsTable">
        <row promptTokens="XXX" responseTokens="YYY" totalTokens="ZZZ"/>
      </table>
    </data>
  </run>
</trace-toc>
```

Where:
- `promptTokens` = actual tokens in the prompt
- `responseTokens` = actual tokens in the response
- `totalTokens` = actual total tokens

## Comparison with parsexc.swift

When you run `parsexc.swift token-export.xml` alongside a benchmark result JSON, it will show:

```
COMPARISON (Estimated vs Actual):
================================================================================

Prompt Tokens:
  Estimated:  125
  Actual:     118
  Difference: -7 (-5.6%)

Response Tokens:
  Estimated:  1069
  Actual:     1142
  Difference: +73 (+6.8%)

Total Tokens:
  Estimated:  1194
  Actual:     1260
  Difference: +66 (+5.5%)

Performance:
  Duration:              12.34s
  Tokens/sec (est.):     96.81
  Tokens/sec (actual):   102.11
  TPS Difference:        +5.30 (+5.5%)

Excellent! Estimation is within 5% of actual token count.
```

## Building

```bash
cd TokenTraceCLI
swift build
```

This will create the executable at `.build/debug/TokenTraceCLI`

## Troubleshooting

### Model Unavailable Error

If you see "Apple Intelligence is unavailable", make sure:
- You're on macOS 26.0+
- Foundation Models framework is available
- System Language Model is configured

### xctrace Command Not Found

Install Xcode Command Line Tools:
```bash
xcode-select --install
```

### Permission Errors

When running xctrace, you may need to grant permissions in:
- System Settings -> Privacy & Security -> Developer Tools

## License

This tool is part of the Foundation Models Framework Benchmark project.
