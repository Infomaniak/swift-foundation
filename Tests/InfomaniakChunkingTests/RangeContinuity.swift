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

struct RangeContinuity {
    enum ErrorDomain: Error, Equatable {
        case gap(leftUpper: UInt64, rightLower: UInt64)
    }

    func validate(_ ranges: [DataRange]) throws {
        for (left, right) in zip(ranges, ranges.dropFirst()) {
            guard left.upperBound + 1 == right.lowerBound else {
                throw ErrorDomain.gap(leftUpper: left.upperBound, rightLower: right.lowerBound)
            }
        }
    }
}
