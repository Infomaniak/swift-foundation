/*
 Infomaniak Foundation
 Copyright (C) 2026 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import Foundation
@testable import InfomaniakFoundation
import Testing

enum ChunkingTestConstants {
    static let config = RangeProvider.Config(
        chunkMinSize: 1024 * 1024,
        chunkMaxSizeClient: 50 * 1024 * 1024,
        chunkMaxSizeServer: 1024 * 1024 * 1024,
        optimalChunkCount: 200,
        maxTotalChunks: 10000,
        minTotalChunks: 1
    )
}

/// Each test owns its file so filesystem tests can run in parallel.
struct ChunkingTestFile {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

    func withContents(_ data: Data, perform: (URL) throws -> Void) throws {
        defer { try? FileManager.default.removeItem(at: url) }
        try data.write(to: url)
        try perform(url)
    }
}

struct RangeProviderGutsTests {
    private let guts = RangeProviderGuts(
        fileURL: ChunkingTestFile().url,
        config: ChunkingTestConstants.config
    )

    @Test(arguments: [
        (UInt64(0), UInt64(4), UInt64(10), [DataRange]()),
        (1, 1, 1, [0 ... 0]),
        (10, 4, 1, [0 ... 0, 1 ... 1, 2 ... 2, 3 ... 3, 4 ... 9]),
        (10, 1, 4, [0 ... 3, 4 ... 9]),
        (8, 4, 2, [0 ... 1, 2 ... 3, 4 ... 5, 6 ... 7]),
        (9, 4, 2, [0 ... 1, 2 ... 3, 4 ... 5, 6 ... 7, 8 ... 8])
    ])
    func buildsContiguousRanges(fileSize: UInt64, count: UInt64, size: UInt64, expected: [DataRange]) throws {
        let ranges = try guts.buildRanges(fileSize: fileSize, totalChunksCount: count, chunkSize: size)
        #expect(ranges == expected)
        for (left, right) in zip(ranges, ranges.dropFirst()) {
            #expect(left.upperBound + 1 == right.lowerBound)
        }
    }

    @Test func rejectsZeroChunkSize() {
        #expect(throws: RangeProvider.ErrorDomain.IncorrectChunkSize) {
            try guts.buildRanges(fileSize: 10, totalChunksCount: 1, chunkSize: 0)
        }
    }

    @Test func rejectsZeroChunkCount() {
        #expect(throws: RangeProvider.ErrorDomain.IncorrectTotalChunksCount) {
            try guts.buildRanges(fileSize: 10, totalChunksCount: 0, chunkSize: 1)
        }
    }

    @Test(arguments: [(UInt64(1), UInt64(4), UInt64(10)), (10, 1, 11), (10, 4, 3)])
    func rejectsChunksLargerThanFile(fileSize: UInt64, count: UInt64, size: UInt64) {
        #expect(throws: RangeProvider.ErrorDomain.ChunkedSizeLargerThanSourceFile) {
            try guts.buildRanges(fileSize: fileSize, totalChunksCount: count, chunkSize: size)
        }
    }

    @Test(arguments: [
        (0, 0),
        (769, 769),
        (1024 * 1024, 1024 * 1024),
        (5 * 1024 * 1024, 1024 * 1024),
        (50 * 1024 * 1024, 1024 * 1024),
        (500 * 1024 * 1024, 500 * 1024 * 1024 / 200),
        (500_000 * 1024 * 1024, 50 * 1024 * 1024),
        (5_000_000_000_000_000, 50 * 1024 * 1024)
    ] as [(UInt64, UInt64)])
    func preferredChunkSize(fileSize: UInt64, expected: UInt64) {
        #expect(guts.preferredChunkSize(for: fileSize) == expected)
    }

    @Test func readsFileSizeAndBuildsRanges() throws {
        let data = Data(repeating: 42, count: 4_865_229)
        try ChunkingTestFile().withContents(data) { url in
            let guts = RangeProviderGuts(fileURL: url, config: ChunkingTestConstants.config)
            let size = try guts.readFileByteSize()
            #expect(size == UInt64(data.count))
            let ranges = try guts.buildRanges(fileSize: size, totalChunksCount: 4, chunkSize: 1024 * 1024)
            #expect(ranges.count == 5)
            #expect(ranges.last?.upperBound == size - 1)
        }
    }

    @Test func missingFileThrows() {
        #expect(throws: (any Error).self) {
            try guts.readFileByteSize()
        }
    }
}

struct RangeProviderTests {
    @Test func splitsAndReassemblesFile() throws {
        let data = Data((0 ..< 4_865_229).map { UInt8(truncatingIfNeeded: $0) })
        try ChunkingTestFile().withContents(data) { url in
            let provider = RangeProvider(fileURL: url, config: ChunkingTestConstants.config)
            #expect(try provider.fileSize == UInt64(data.count))
            let ranges = try provider.allRanges
            #expect(ranges.count == 5)
            let chunks = try #require(ChunkProvider(fileURL: url, ranges: ranges))
            var reassembled = Data()
            for range in ranges {
                let chunk = try #require(chunks.next())
                #expect(UInt64(chunk.count) == range.upperBound - range.lowerBound + 1)
                reassembled.append(chunk)
            }
            #expect(chunks.next() == nil)
            #expect(reassembled == data)
        }
    }

    @Test func delegatesRangeCalculation() throws {
        var provider = RangeProvider(fileURL: ChunkingTestFile().url, config: ChunkingTestConstants.config)
        provider.guts = StubRangeProviderGuts(size: 10, preferredSize: 3)
        #expect(try provider.fileSize == 10)
        #expect(try provider.allRanges == [0 ... 2, 3 ... 5, 6 ... 8, 9 ... 9])
    }

    @Test(arguments: [false, true])
    func rejectsClientAndServerSizeLimits(serverLimit: Bool) {
        let config = RangeProvider.Config(
            chunkMinSize: 1,
            chunkMaxSizeClient: serverLimit ? 20 : 10,
            chunkMaxSizeServer: serverLimit ? 10 : 20,
            optimalChunkCount: 1,
            maxTotalChunks: 1,
            minTotalChunks: 1
        )
        var provider = RangeProvider(fileURL: ChunkingTestFile().url, config: config)
        provider.guts = StubRangeProviderGuts(size: 10, preferredSize: 1)
        #expect(throws: RangeProvider.ErrorDomain.FileTooLarge) {
            try provider.allRanges
        }
    }

    @Test func missingFileThrows() {
        let provider = RangeProvider(fileURL: ChunkingTestFile().url, config: ChunkingTestConstants.config)
        #expect(throws: (any Error).self) {
            try provider.allRanges
        }
    }
}

private struct StubRangeProviderGuts: RangeProviderGutsable {
    let size: UInt64
    let preferredSize: UInt64

    func readFileByteSize() throws -> UInt64 {
        size
    }

    func preferredChunkSize(for fileSize: UInt64) -> UInt64 {
        #expect(fileSize == size)
        return preferredSize
    }

    func buildRanges(fileSize: UInt64, totalChunksCount: UInt64, chunkSize: UInt64) throws -> [DataRange] {
        #expect(fileSize == size)
        #expect(totalChunksCount == 3)
        #expect(chunkSize == preferredSize)
        return [0 ... 2, 3 ... 5, 6 ... 8, 9 ... 9]
    }
}

struct ChunkReaderTests {
    @Test func readsInclusiveRangeAndSeeksForEachRead() throws {
        try ChunkingTestFile().withContents(Data([0, 1, 2, 3, 4])) { url in
            let reader = try #require(ChunkReader(fileURL: url))
            #expect(try reader.readChunk(range: 2 ... 4) == Data([2, 3, 4]))
            #expect(try reader.readChunk(range: 0 ... 1) == Data([0, 1]))
            #expect(try reader.readChunk(range: 1 ... 1) == Data([1]))
            #expect(try reader.readChunk(range: 5 ... 6) == nil)
        }
    }

    @Test func missingFileReturnsNil() {
        #expect(ChunkReader(fileURL: ChunkingTestFile().url) == nil)
    }

    @Test func closedHandleThrows() throws {
        try ChunkingTestFile().withContents(Data([0, 1])) { url in
            let handle = try FileHandle(forReadingFrom: url)
            let reader = ChunkReader(mockedHandlable: handle)
            try handle.close()
            #expect(throws: (any Error).self) {
                try reader.readChunk(range: 0 ... 1)
            }
        }
    }

    @Test func readFailureThrows() throws {
        try ChunkingTestFile().withContents(Data([0, 1])) { url in
            let handle = try FileHandle(forWritingTo: url)
            let reader = ChunkReader(mockedHandlable: handle)
            #expect(throws: (any Error).self) {
                try reader.readChunk(range: 0 ... 1)
            }
        }
    }
}

struct ChunkProviderTests {
    @Test func emptyRangesReturnNil() throws {
        try ChunkingTestFile().withContents(Data([0, 1])) { url in
            let provider = try #require(ChunkProvider(fileURL: url, ranges: []))
            #expect(provider.next() == nil)
        }
    }

    @Test func iteratesAllRangesInOrder() throws {
        try ChunkingTestFile().withContents(Data([0, 1, 2, 3, 4])) { url in
            let provider = try #require(ChunkProvider(fileURL: url, ranges: [0 ... 1, 1 ... 2, 2 ... 4]))
            #expect(provider.next() == Data([0, 1]))
            #expect(provider.next() == Data([1, 2]))
            #expect(provider.next() == Data([2, 3, 4]))
            #expect(provider.next() == nil)
        }
    }

    @Test func missingFileReturnsNil() {
        #expect(ChunkProvider(fileURL: ChunkingTestFile().url, ranges: [0 ... 1]) == nil)
    }

    @Test func readErrorReturnsNil() throws {
        try ChunkingTestFile().withContents(Data([0, 1])) { url in
            let handle = try FileHandle(forReadingFrom: url)
            let provider = ChunkProvider(mockedHandlable: handle, ranges: [0 ... 1])
            try handle.close()
            #expect(provider.next() == nil)
            #expect(provider.next() == nil)
        }
    }
}
