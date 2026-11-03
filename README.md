# InfomaniakFoundation

Shared Foundation utilities for Infomaniak Swift projects.

## Installation

Add `https://github.com/Infomaniak/swift-foundation` as a Swift package dependency and link the
`InfomaniakFoundation` product to your target.

## Validation

Run `swift build` and `swift test` for macOS. For iOS, run:

```sh
xcodebuild -scheme InfomaniakFoundation test -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
```
