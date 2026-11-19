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
import InfomaniakChunking
import Testing

struct FileHandleDescriptionTests {
    @Test(arguments: [UInt64(0), 2, 5])
    func includesCurrentOffset(offset: UInt64) throws {
        try ChunkingTestFile().withContents(Data([0, 1, 2, 3, 4])) { url in
            let handle = try FileHandle(forReadingFrom: url)
            defer { try? handle.close() }

            try handle.seek(toOffset: offset)
            #expect(handle.description.hasPrefix("<"))
            #expect(handle.description.hasSuffix("<offset:\(offset)>"))
        }
    }

    @Test func includesOffsetErrorForClosedHandle() throws {
        try ChunkingTestFile().withContents(Data([0, 1])) { url in
            let handle = try FileHandle(forReadingFrom: url)
            defer { try? handle.close() }
            try handle.close()

            #expect {
                try handle.offset()
            } throws: { error in
                let error = error as NSError
                let description = handle.description
                return description.contains("<offset:Error Domain=\(error.domain) Code=\(error.code) ")
                    && description.hasSuffix(">")
            }
        }
    }
}
