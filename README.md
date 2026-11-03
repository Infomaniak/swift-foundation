# InfomaniakFoundation

Shared Foundation utilities for Infomaniak Swift projects.

## Installation

Add `https://github.com/Infomaniak/swift-foundation` as a Swift package dependency and link the
`InfomaniakFoundation` product to your target.

## Data chunking migration (breaking change)

Data chunking has moved here from [InfomaniakCore](https://github.com/Infomaniak/ios-core).
Import `InfomaniakFoundation` to use `DataRange`, `RangeProvider`, `RangeProvidable`,
`RangeProviderGuts`, `RangeProviderGutsable`, `ChunkReader`, `ChunkProvider`, and `ChunkProvidable`.
Their behavior and public API are preserved.

**This addition must be released as a breaking change.** It includes the `FileHandle.description`
override previously shipped in `ios-core`. Linking this version with an older `ios-core` that still
contains chunking causes duplicate symbols. Upgrade `ios-core` to the corresponding version that
removes chunking when adopting this version of `InfomaniakFoundation`.

## Validation

Run `swift build` and `swift test` for macOS. For iOS, run:

```sh
xcodebuild -scheme InfomaniakFoundation test -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
```
