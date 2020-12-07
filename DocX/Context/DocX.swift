//
//  DocX.swift
//  Test
//
//  Created by Mahmut Şahin on 24.11.2020.
//

import AEXML
import Foundation

enum DocXSavingErrors: Error {
    case noBlankDocument
    case compressionFailed
    case noBundle
}

protocol DocX {
    func docXDocument(linkRelations: [LinkRelationship]) throws -> String
    func writeDocX(to url: URL) throws
    func prepareLinks(linkXML: AEXMLDocument) -> [LinkRelationship]
}
