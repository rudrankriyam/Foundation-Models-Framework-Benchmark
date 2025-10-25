# Benchmark App To‑Do List

## Shared Groundwork
- [ ] Define benchmarking goals, success metrics, and submission flow (reference `Samples/XcodeBenchmark/ReadMe.md` for structure).
- [x] Enumerate required environment data (device name, chip, RAM, OS, Xcode, Apple Intelligence availability) and create a shared `EnvironmentSnapshot` model.
- [x] Finalize the canonical benchmark instructions + prompt (multi-part narrative + JSON + SwiftUI pseudocode) and document rationale.

## BenchmarkCore Package
- [x] Scaffold a Swift package (`BenchmarkCore`) inside the repo and expose it to all app targets.
- [x] Port token-counting helpers from `Developer/Apps/Foundation-Models-Framework-Example/Foundation Lab/Extensions/Transcript+TokenCounting.swift` and adapt them for headless use.
- [x] Implement `BenchmarkPrompt` (instructions, user prompt, optional variants) seeded from `DefaultPrompts`.
- [x] Build `BenchmarkRunner` that wraps `LanguageModelSession`, streams responses, records TTFT/total duration, counts tokens, and calculates tokens-per-second.
- [x] Add `BenchmarkReport` capable of serializing run metadata + metrics to JSON/Markdown.

## macOS Benchmark App
- [ ] Create a SwiftUI macOS app target that links `BenchmarkCore`.
- [ ] Design UI with “Run Benchmark” button, live log output, and summary card (metrics + environment snapshot).
- [ ] Implement export workflow (save/share report) and persistent storage of past runs (`Application Support/BenchmarkResults`).

## iOS & iPadOS Benchmark App
- [ ] Add a universal SwiftUI app target (size-class aware layout) that reuses the macOS view model.
- [ ] Ensure “Run Benchmark” button gating, live progress, and token stats work on both iPhone and iPad simulators/devices.
- [ ] Provide share sheet / Files export so testers can submit JSON/Markdown logs.

## visionOS Benchmark App
- [ ] Create a visionOS target with a floating control panel (Run button, status, metrics).
- [ ] Validate streaming UI/UX within a window scene and ensure reporting uses the shared storage format.

## Telemetry & Validation
- [ ] Add optional diagnostic hooks (e.g., powermetrics on macOS, MetricKit on iOS/iPadOS) for advanced users.
- [ ] Create automated UI tests or previews that fire a mock benchmark to guard UI regressions without invoking the real model.

## Documentation & Tooling
- [ ] Update `README.md` with setup steps per platform, prompt details, and instructions for collecting/submitting results.
- [ ] Document scripts (if any) for gathering stored JSON files and aggregating them into a leaderboard.
- [ ] Plan future enhancements (multiple prompt suites, batch runs, visual comparisons) and capture them as stretch goals.
