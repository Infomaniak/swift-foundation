//
//  File.swift
//  InfomaniakFoundation
//
//  Created by Valentin Perignon on 11.02.2026.
//

import UniformTypeIdentifiers

public extension UTType {
    static let onlyOffice = UTType("org.oasis-open.opendocument.text")!
    static let pages = UTType("com.apple.iwork.pages.sffpages")!
    static let wordDoc = UTType("com.microsoft.word.doc")!
    static let wordDocm = UTType(mimeType: "application/vnd.ms-word")!
    static let wordDocx = UTType("org.openxmlformats.wordprocessingml.document")!

    static let ics = UTType(mimeType: "application/ics")!
}
