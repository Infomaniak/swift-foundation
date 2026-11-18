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

import InfomaniakFoundation
import Testing
import UniformTypeIdentifiers

struct UTTypeExtensionTests {
    @Test(arguments: [
        (UTType.onlyOffice, "org.oasis-open.opendocument.text"),
        (UTType.pages, "com.apple.iwork.pages.sffpages"),
        (UTType.wordDoc, "com.microsoft.word.doc"),
        (UTType.wordDocx, "org.openxmlformats.wordprocessingml.document")
    ])
    func documentTypesHaveExpectedIdentifiers(type: UTType, identifier: String) {
        #expect(type.identifier == identifier)
    }

    @Test(arguments: [
        (UTType.wordDocm, "application/vnd.ms-word"),
        (UTType.ics, "application/ics")
    ])
    func mimeTypesMatchSystemLookup(type: UTType, mimeType: String) throws {
        let expectedType = try #require(UTType(mimeType: mimeType))
        #expect(type == expectedType)
    }
}
