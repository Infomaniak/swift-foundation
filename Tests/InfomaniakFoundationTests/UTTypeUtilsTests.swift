/*
 Infomaniak Foundation
 Copyright (C) 2023-2025 Infomaniak Network SA

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

@testable import InfomaniakFoundation
import Testing
import UniformTypeIdentifiers

struct UTTypeUtilsTests {
    // MARK: - conforms(to: [UTType])

    @Test func conformsToArray_matchingTypes() {
        let jpeg = UTType.jpeg
        #expect(jpeg.conforms(to: [.image, .video]))
    }

    @Test func conformsToArray_noMatchingType() {
        let jpeg = UTType.jpeg
        #expect(!jpeg.conforms(to: [.video, .audio]))
    }

    @Test func conformsToArray_emptyArray() {
        let jpeg = UTType.jpeg
        #expect(!jpeg.conforms(to: []))
    }

    @Test func conformsToArray_exactType() {
        let png = UTType.png
        #expect(png.conforms(to: [.png]))
    }
}
