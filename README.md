# Foundation Models Framework Benchmark

This repo measures Foundation Models performance across macOS, iOS, iPadOS, and visionOS using unit tests.

## Requirements

- Xcode 26.0 or newer (SDKs for macOS 26, iOS 26, iPadOS 26, visionOS 26).
- Apple Intelligence enabled on the test device.

## Running the Benchmark

### Using Xcode

1. Open the project in Xcode
2. Select your target device (iPhone, iPad, Mac, or simulator) from the device dropdown
3. Press **Cmd+U** to run all tests, or **Cmd+Shift+K** to run just the benchmark test

### Using Command Line

Run on your local Mac:

```bash
xcodebuild test -project FoundationStudio.xcodeproj -scheme FoundationStudioTests -destination "platform=macOS"
```

Run on a specific iOS device:

```bash
xcodebuild test -project FoundationStudio.xcodeproj -scheme FoundationStudioTests -destination "platform=iOS,name=Rudrank 17 Pro"
```

Run on a simulator:

```bash
xcodebuild test -project FoundationStudio.xcodeproj -scheme FoundationStudioTests -destination "platform=iOS Simulator,name=iPhone 17 Pro"
```

### What You'll See

The test will display an ASCII "FOUNDATION STUDIO" banner followed by detailed hardware information and benchmark results in the Xcode console:

```
╔═══════════════════════════════════════════════════════════════════════════════════════════════╗
║                                                                                               ║
║    ███████╗ ██████╗ ██╗   ██╗███╗   ██╗██████╗  █████╗ ████████╗██╗ ██████╗ ███╗   ██╗        ║
║    ██╔════╝██╔═══██╗██║   ██║████╗  ██║██╔══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║        ║
║    █████╗  ██║   ██║██║   ██║██╔██╗ ██║██║  ██║███████║   ██║   ██║██║   ██║██╔██╗ ██║        ║
║    ██╔══╝  ██║   ██║██║   ██║██║╚██╗██║██║  ██║██╔══██║   ██║   ██║██║   ██║██║╚██╗██║        ║
║    ██║     ╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║        ║
║    ╚═╝      ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝        ║
║                                                                                               ║
║                    ███████╗████████╗██╗   ██╗██████╗ ██╗ ██████╗                              ║
║                    ██╔════╝╚══██╔══╝██║   ██║██╔══██╗██║██╔═══██╗                             ║
║                    ███████╗   ██║   ██║   ██║██║  ██║██║██║   ██║                             ║
║                    ╚════██║   ██║   ██║   ██║██║  ██║██║██║   ██║                             ║
║                    ███████║   ██║   ╚██████╔╝██████╔╝██║╚██████╔╝                             ║
║                    ╚══════╝   ╚═╝    ╚═════╝ ╚═════╝ ╚═╝ ╚═════╝                              ║
║                                                                                               ║
║                         Foundation Models Benchmarking Tool                                   ║
║                                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════════════════════╝

Environment
----------------------------------------
Device: Rudrank 17 Pro
CPU: A18 Pro 6-core
GPU: Apple GPU
RAM: 10 GB
OS: iOS 18.1
Locale: en_US

========================================
RUNNING FOUNDATION MODELS BENCHMARK
========================================

Benchmark completed successfully!

Estimated Metrics:
  Duration: 17.53s
  Time to First Token: 0.45s
  Prompt Tokens (est.): 125
  Response Tokens (est.): 1,069
  Total Tokens (est.): 1,194
  Tokens/sec (est.): 68.13

Response preview (first 200 chars):
The product design is clean and modern...
```

## macOS Results

| Device | CPU | GPU | RAM | OS | Input Tokens | Output Tokens | Total Tokens | Duration | Tokens/sec |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MacBook Pro 14" (2025) | Apple M5 10‑core | Apple M5 10‑core | 32 GB | macOS 26.0 | 125 | 1,069 | 1,194 | 14.41s | **82.86** |
| MacBook Pro 14" (2024) | Apple M4 10‑core | Apple M4 10‑core | 16 GB | macOS 26.1 | 125 | 1,069 | 1,194 | 15.64s | **76.33** |
| MacBook Air 15" (2025) | Apple M4 10‑core | Apple M4 10‑core | 24 GB | macOS 26.1 | 144 | 887 | 1,031 | 15.23s | **58.24** |

## iOS Results

| Device | CPU | GPU | RAM | OS | Input Tokens | Output Tokens | Total Tokens | Duration | Tokens/sec |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| iPhone 17 Pro | Apple A19 Pro 6‑core | Apple GPU | 12 GB | iOS 26.1 | 125 | 1,069 | 1,194 | 11.93s | **100.08** |
| iPhone 16 Pro Max | Apple A18 Pro 6‑core | Apple GPU | 8 GB | iOS 26.2 | 125 | 1,069 | 1,194 | 17.53s | **68.13** |
| Rudrank 17 Pro | Apple A18 Pro 6‑core | Apple GPU | 10 GB | iOS 18.1 | 125 | 1,069 | 1,194 | 17.53s | **68.13** |

## iPadOS Results

| Device | CPU | GPU | RAM | OS | Input Tokens | Output Tokens | Total Tokens | Duration | Tokens/sec |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| iPad Pro 13" (M4) | Apple M4 10‑core | Apple GPU | 16 GB | iPadOS 18.1 | TBD | TBD | TBD | TBD | TBD |

## visionOS Results

| Device | CPU | GPU | RAM | OS | Input Tokens | Output Tokens | Total Tokens | Duration | Tokens/sec |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Apple Vision Pro (M2) | Apple M2 8‑core (4P + 4E) | Apple GPU | 16 GB | visionOS 2.0 | TBD | TBD | TBD | TBD | TBD |
| Apple Vision Pro (M5) | Apple M5 10‑core (4P + 6E) | Apple GPU | 16 GB | visionOS 26.0 | TBD | TBD | TBD | TBD | TBD |

**Note:** GPU information is displayed as "Apple GPU" on iOS/iPadOS/visionOS due to platform limitations. On macOS, the specific GPU model is shown.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Contributions welcome!
