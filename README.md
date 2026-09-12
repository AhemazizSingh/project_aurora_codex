# FinanceOS

FinanceOS is a native, offline-first personal finance app for iOS.

## Foundation status

The first module establishes the SwiftUI/SwiftData foundation and transaction
engine. Its business rules preserve the core financial distinction between
expenses, transfers, savings, investments, refunds, and loans.

## Remote validation

This repository includes an optional GitHub Actions workflow that generates the
Xcode project and runs Foundation tests on macOS. It is disabled by default, so
it consumes no GitHub Actions minutes. Enable it only when macOS validation is
explicitly wanted.

## Development

The project definition is in `project.yml`. On macOS, install XcodeGen and run
`xcodegen generate` before opening `FinanceOS.xcodeproj` in Xcode.

The `img/` folder contains visual reference material. It is included for design
direction only; FinanceOS should exceed that reference while following the
product design system in `docs/`.
