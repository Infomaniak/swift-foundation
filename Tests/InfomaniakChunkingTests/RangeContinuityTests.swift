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

import Testing

struct RangeContinuityTests {
    @Test func acceptsContinuousRanges() throws {
        try RangeContinuity().validate([0 ... 1337, 1338 ... 2047])
    }

    @Test func rejectsGap() {
        #expect(throws: RangeContinuity.ErrorDomain.gap(leftUpper: 1337, rightLower: 1339)) {
            try RangeContinuity().validate([0 ... 1337, 1339 ... 2047])
        }
    }

    @Test func acceptsEmptyRanges() throws {
        try RangeContinuity().validate([])
    }
}
