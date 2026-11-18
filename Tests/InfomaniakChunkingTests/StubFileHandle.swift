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

struct StubFileHandle: FileHandlable {
    let seekToOffset: @Sendable (UInt64) throws -> Void
    let readUpToCount: @Sendable (Int) throws -> Data?

    var availableData: Data {
        Issue.record("Unexpected availableData access")
        return Data()
    }

    var description: String {
        "StubFileHandle"
    }

    func seek(toOffset offset: UInt64) throws {
        try seekToOffset(offset)
    }

    func read(upToCount count: Int) throws -> Data? {
        try readUpToCount(count)
    }

    func close() throws {}

    func truncate(atOffset offset: UInt64) throws {
        Issue.record("Unexpected truncate(atOffset:) call")
    }

    func synchronize() throws {
        Issue.record("Unexpected synchronize() call")
    }

    func readToEnd() throws -> Data? {
        Issue.record("Unexpected readToEnd() call")
        return nil
    }

    func offset() throws -> UInt64 {
        Issue.record("Unexpected offset() call")
        return 0
    }

    func seekToEnd() throws -> UInt64 {
        Issue.record("Unexpected seekToEnd() call")
        return 0
    }
}
