# InfomaniakFoundation

Shared Foundation utilities and file chunking for Infomaniak Swift projects, exposed as two independent libraries.

## Installation

Add `https://github.com/Infomaniak/swift-foundation` as a Swift package dependency. Select the
`InfomaniakFoundation` product for Foundation utilities or `InfomaniakChunking` for file chunking.
Both products are in this package; neither depends on or re-exports the other.

In your target's dependencies, link the product you need (or both):

```swift
.target(
    name: "MyTarget",
    dependencies: [
        .product(name: "InfomaniakFoundation", package: "swift-foundation"),
        .product(name: "InfomaniakChunking", package: "swift-foundation")
    ]
)
```

## Usage

### Foundation utilities

```swift
import InfomaniakFoundation
import UniformTypeIdentifiers

let isImageOrMovie = UTType.jpeg.conforms(to: [.image, .movie])
```

### File chunking

```swift
import Foundation
import InfomaniakChunking

let fileURL = URL(fileURLWithPath: "/path/to/file")
if let reader = ChunkReader(fileURL: fileURL) {
    let firstChunk = try reader.readChunk(range: 0 ... 1023)
}
```

## Validation

Run `swift build` and `swift test` for macOS. For iOS, run:

```sh
xcodebuild -scheme InfomaniakFoundation test -destination 'platform=iOS Simulator,name=iPhone 18 Pro,OS=latest'
xcodebuild -scheme InfomaniakChunking test -destination 'platform=iOS Simulator,name=iPhone 18 Pro,OS=latest'
```
