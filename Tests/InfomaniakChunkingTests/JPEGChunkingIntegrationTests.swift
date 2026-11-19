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
@testable import InfomaniakChunking
import Testing

struct JPEGChunkingIntegrationTests {
    /// Image from wikimedia under CC, retained from the original ios-core integration tests.
    private let file = "Matterhorn_as_seen_from_Zermatt,_Wallis,_Switzerland,_2012_August,Wikimedia_Commons"

    private func fileURL() throws -> URL {
        try #require(Bundle.module.url(forResource: file, withExtension: "jpg"))
    }

    @Test func readsOriginalFileSize() throws {
        let guts = try RangeProviderGuts(fileURL: fileURL(), config: ChunkingTestConstants.config)
        #expect(try guts.readFileByteSize() == 4_865_229)
    }

    @Test func buildsOriginalFileRanges() throws {
        let guts = try RangeProviderGuts(fileURL: fileURL(), config: ChunkingTestConstants.config)
        let size = try guts.readFileByteSize()
        let ranges = try guts.buildRanges(fileSize: size, totalChunksCount: 4, chunkSize: 1024 * 1024)
        #expect(ranges.count == 5)
        #expect(ranges.first?.lowerBound == 0)
        #expect(ranges.last?.upperBound == size - 1)
        try RangeContinuity().validate(ranges)
    }

    @Test func computesPreferredSizeForOriginalFile() throws {
        let guts = try RangeProviderGuts(fileURL: fileURL(), config: ChunkingTestConstants.config)
        let size = try guts.readFileByteSize()
        let preferredSize = guts.preferredChunkSize(for: size)
        #expect(preferredSize > 0)
        #expect(preferredSize <= size)
        #expect(preferredSize == 1024 * 1024)
    }

    @Test func producesContinuousRangesForOriginalFile() throws {
        let provider = try RangeProvider(fileURL: fileURL(), config: ChunkingTestConstants.config)
        let ranges = try provider.allRanges
        #expect(ranges.count == 5)
        #expect(ranges.first?.lowerBound == 0)
        #expect(ranges.last?.upperBound == 4_865_228)
        try RangeContinuity().validate(ranges)
    }

    @Test func reassemblesOriginalFile() throws {
        let url = try fileURL()
        let expectedData = try Data(contentsOf: url)
        let rangeProvider = RangeProvider(fileURL: url, config: ChunkingTestConstants.config)
        let ranges = try rangeProvider.allRanges
        let provider = try #require(ChunkProvider(fileURL: url, ranges: ranges))
        var chunks = [Data]()
        while let chunk = provider.next() {
            chunks.append(chunk)
        }

        #expect(chunks.count == 5)
        #expect(chunks.count == ranges.count)
        for (range, chunk) in zip(ranges, chunks) {
            #expect(UInt64(chunk.count) == range.upperBound - range.lowerBound + 1)
        }
        #expect(ranges.first?.lowerBound == 0)
        #expect(ranges.last?.upperBound == UInt64(expectedData.count) - 1)
        try RangeContinuity().validate(ranges)
        #expect(chunks.reduce(into: Data()) { $0.append($1) } == expectedData)
        #expect(provider.next() == nil)
    }
}
