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

import InfomaniakChunking

struct RangeGenerationCase: Sendable {
    let fileSize: UInt64
    let count: UInt64
    let size: UInt64
    let expected: [DataRange]

    init(_ fileSize: UInt64, _ count: UInt64, _ size: UInt64, _ expected: [DataRange]) {
        self.fileSize = fileSize
        self.count = count
        self.size = size
        self.expected = expected
    }
}
