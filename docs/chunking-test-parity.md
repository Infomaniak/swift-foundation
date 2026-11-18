# Chunking test migration parity

Baseline: `Infomaniak/ios-core` commit `7a8ab413d5ac54531d9cae327e49bd1c28b26adc`, immediately before chunking was removed.

All 41 original tests are mapped below, including the three continuity-helper tests. A parameterized row is a counterpart, not a dropped test. The newer temporary-file, exact-result, error, I/O-count, and description tests are retained in addition to this baseline.

The original JPEG is copied byte-for-byte into `Tests/InfomaniakChunkingTests/Resources/`:

- File: `Matterhorn_as_seen_from_Zermatt,_Wallis,_Switzerland,_2012_August,Wikimedia_Commons.jpg`
- Size: 4,865,229 bytes
- Original attribution: “Image from wikimedia under CC.”
- SHA-256: `e76965e6a92d3327a77ab6ce070657054acdbe3b2d077a5cd71a7d8217e5d90c`

`MiB` below means `1024 * 1024` bytes. Tuple inputs for `buildsContiguousRanges` and `rejectsChunksLargerThanFile` are `(fileSize, count, size)`. Error and zero-count tests name their arguments explicitly.

## Provider and reader unit tests

| Original test | Current counterpart and retained assertions |
| --- | --- |
| `UTChunkProvider.testNext_emptyRanges` | `ChunkProviderTests.readsEachRangeExactlyOnce`, empty ranges: nil result and zero seeks/reads. |
| `UTChunkProvider.testNext_hasOneRange` | `readsEachRangeExactlyOnce`, `[0 ... 1024]`: one seek/read and non-nil empty Data. |
| `UTChunkProvider.testNext_hasRanges` | `doesNotReadAhead`: one seek/read after consuming only the first of `[0 ... 1, 1 ... 2, 2 ... 4]`. |
| `UTChunkProvider.testNext_enumarateAll` | `readsEachRangeExactlyOnce`, all three original ranges: three chunks and exactly three seeks/reads. Repeated exhaustion performs no additional I/O. |
| `UTChunkReader.testReadChunk_validChunk` | `ChunkReaderTests.readsSingleRangeWithOneSeekAndRead`: range `0 ... 1`, seek offset 0, one seek/read, non-nil empty Data, requested byte count 2. |
| `UTChunkReader.testReadChunk_throwErrorOnSeek` | `propagatesSeekErrorWithoutReading`: injected NSError domain `k`, code 1337, exact error propagation, one seek and zero reads. |
| `UTChunkReader.testReadChunk_throwErrorOnRead` | `propagatesReadErrorAfterOneSeek`: injected NSError domain `k`, code 1337, exact error propagation, one seek and one read. |
| `UTRangeProvider.testAllRanges_zeroes` | `RangeProviderTests.delegatesZeroValuesWithOneChunkFallback`: size/preferred size 0, no error, empty stub result; additionally checks all three calls and the one-chunk fallback. |
| `UTRangeProvider.testAllRanges_FileTooLarge` | `rejectsFileAboveOriginalClientLimit`: original configuration, size `fileMaxSizeClient + 1`, exact `FileTooLarge` error. The newer equality and server-limit cases remain. |
| `UTRangeProvider.testAllRanges_Success` | `delegatesOriginalSuccessfulInputs`: size `chunkMinSize + 1`, preferred size 1 MiB, empty stub result, and all three delegated operations called once. |

## Range-provider guts unit tests

| Original test | Current counterpart and retained assertions |
| --- | --- |
| `UTRangeProviderGuts.testBuildRanges_0ChunkSize` | `rejectsZeroChunkSize(fileSize: 4_865_229, count: 4)`: exact `IncorrectChunkSize` error. |
| `UTRangeProviderGuts.testBuildRanges_0FileLength` | `buildsContiguousRanges`, `(0, 4, 10 MiB)`: zero ranges and continuity validation. |
| `UTRangeProviderGuts.testBuildRanges_0Chunk` | `rejectsZeroChunkCount(fileSize: 4_865_229, chunkSize: 10 MiB)`: exact `IncorrectTotalChunksCount` error. |
| `UTRangeProviderGuts.testBuildRanges_1ChunkSize` | `buildsContiguousRanges`, `(4_865_229, 4, 1)`: five ranges, continuity, and exact bounds. |
| `UTRangeProviderGuts.testBuildRanges_1FileLength_valid` | `buildsContiguousRanges`, `(1, 1, 1)`: one range `0 ... 0` and continuity. |
| `UTRangeProviderGuts.testBuildRanges_1FileLength_invalid` | `rejectsChunksLargerThanFile`, `(1, 4, 10 MiB)`: exact `ChunkedSizeLargerThanSourceFile` error. |
| `UTRangeProviderGuts.testBuildRanges_1Chunk` | `buildsContiguousRanges`, `(4_865_229, 1, 1 MiB)`: two ranges including the remainder, continuity, and exact bounds. |
| `UTRangeProviderGuts.testBuildRanges_1ChunkBiggerThanFile` | `rejectsChunksLargerThanFile`, `(4_865_229, 1, 10 MiB)`: exact error. |
| `UTRangeProviderGuts.testBuildRanges_ChunkBiggerThanFile` | `rejectsChunksLargerThanFile`, `(4_865_229, 4, 10 MiB)`: exact error. |
| `UTRangeProviderGuts.testBuildRanges_ChunksWithoutRemainder` | `buildsContiguousRanges`, `(4 MiB, 4, 1 MiB)`: four contiguous ranges and exact bounds. |
| `UTRangeProviderGuts.testBuildRanges_ChunksWithRemainder` | `buildsContiguousRanges`, `(4_865_229, 4, 1 MiB)`: five contiguous ranges and exact bounds. |
| `UTRangeProviderGuts.testPreferredChunkSize_smallerThanMinChunk` | `preferredChunkSize`, 769 bytes: expected size 769. |
| `UTRangeProviderGuts.testPreferredChunkSize_equalsMinChunk` | `preferredChunkSize`, 1 MiB: expected size 1 MiB. |
| `UTRangeProviderGuts.testPreferredChunkSize_betweensMinAndMax` | `preferredChunkSize`, original `5 * 1025 * 1024` input: expected size 1 MiB, stronger than the original min/max bounds. |
| `UTRangeProviderGuts.testPreferredChunkSize_EqualMax` | `preferredChunkSize`, 50 MiB: expected size 1 MiB, within the original bounds. |
| `UTRangeProviderGuts.testPreferredChunkSize_10Times` | `preferredChunkSize`, 500 MiB: expected size `500 MiB / 200`, within the original bounds. |
| `UTRangeProviderGuts.testPreferredChunkSize_10KTimes` | `preferredChunkSize`, 500,000 MiB: expected size 50 MiB. |
| `UTRangeProviderGuts.testPreferredChunkSize_100KTimes` | `preferredChunkSize`, `100_000 * 50 MiB`: expected size 50 MiB. |
| `UTRangeProviderGuts.testPreferredChunkSize_100MTimes` | `preferredChunkSize`, `100_000_000 * 50 MiB`: expected size 50 MiB. |
| `UTRangeProviderGuts.testContinuityHelper_continuous` | `RangeContinuityTests.acceptsContinuousRanges`: original `[0 ... 1337, 1338 ... 2047]`, no error. |
| `UTRangeProviderGuts.testContinuityHelper_notContinuous` | `RangeContinuityTests.rejectsGap`: original `[0 ... 1337, 1339 ... 2047]`, exact gap error. |
| `UTRangeProviderGuts.testContinuityHelper_empty` | `RangeContinuityTests.acceptsEmptyRanges`: empty ranges, no error. |

## Integration tests

| Original test | Current counterpart and retained assertions |
| --- | --- |
| `ITChunkProvider.testAllRanges_image` | `JPEGChunkingIntegrationTests.reassemblesOriginalFile`: original JPEG, five chunks, each chunk matches its range length, and byte-for-byte reconstruction. |
| `ITRangeProvider.testAllRanges_image` | `JPEGChunkingIntegrationTests.producesContinuousRangesForOriginalFile`: original JPEG, successful range calculation and explicit continuity validation. |
| `ITRangeProviderGuts.testReadFileByteSize` | `JPEGChunkingIntegrationTests.readsOriginalFileSize`: original JPEG size is 4,865,229 bytes. |
| `ITRangeProviderGuts.testReadFileByteSize_FileDoesNotExists` | `RangeProviderGutsTests.missingFileThrows`: missing file, NSCocoaErrorDomain and code 260. Uses an isolated temporary URL instead of the original hard-coded root path. |
| `ITRangeProviderGuts.testBuildRanges_fromImage` | `JPEGChunkingIntegrationTests.buildsOriginalFileRanges`: original JPEG, four 1 MiB chunks plus remainder, five ranges, continuity and final upper bound `fileSize - 1`. |
| `ITRangeProviderGuts.testBuildRanges_fromEmptyFile` | `buildsContiguousRanges`, `(0, 1, 1)`: zero ranges and continuity validation. The original unused HTTP URL is not needed for this pure calculation. |
| `ITRangeProviderGuts.testPreferredChunkSize_fromImage` | `JPEGChunkingIntegrationTests.computesPreferredSizeForOriginalFile`: reads original JPEG size, preferred size positive and no larger than file; additionally checks exact 1 MiB result. |
| `ITRangeProviderGuts.testPreferredChunkSize_0` | `preferredChunkSize`, file size 0: expected size 0. |
| `ITRangeProviderGuts.testPreferredChunkSize_notLargerThanFileSize` | `preferredChunkSize`, file size 10: expected size 10. |

## Test-double migration

- `MCKChunkProvidable` and `MCKRangeProvidable` had no consumers outside their declarations and are not restored.
- `MCKFileHandlable` is replaced by the Sendable `StubFileHandle` and Swift Testing confirmations. The original I/O call-count and exact-error assertions are retained without mutable shared counters.
- `MCKRangeProviderGutsable` is replaced by focused stubs, including `SingleChunkRangeProviderGuts`, which checks delegated arguments and calls for both original success cases.
- `TestRangeProviderConfig.default` is retained as `ChunkingTestConstants.config` with the same values.

This matrix documents scenario/assertion parity, not a claim of 100% line or branch coverage. Compiler coverage is measured separately.
