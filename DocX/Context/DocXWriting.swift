//
//  DocXWriting.swift
//  Test
//
//  Created by Mahmut Şahin on 24.11.2020.
//

import AEXML
import Foundation

extension DocX where Self: NSAttributedString {
    var pageDef: AEXMLElement {
        let pageDef = AEXMLElement(name: "w:sectPr", value: nil, attributes: ["w:rsidR": "00045791", "w:rsidSect": "004F37A0"])
        if verticalFormEnabled {
            let vertical = AEXMLElement(name: "w:textDirection", value: nil, attributes: ["w:val": "tbRl"])
            pageDef.addChild(vertical)
        }
        return pageDef
    }

    func buildParagraphs(paragraphRanges: [Range<String.Index>], linkRelations: [LinkRelationship]) -> [AEXMLElement] {
        paragraphRanges.map { range in
            let paragraph = ParagraphElement(string: self, range: range, linkRelations: linkRelations)
            return paragraph
        }
    }

    func docXDocument(linkRelations: [LinkRelationship] = [LinkRelationship]()) throws -> String {
        var options = AEXMLOptions()
        options.documentHeader.standalone = "yes"
        let root = DocumentRoot()
        let document = AEXMLDocument(root: root, options: options)
        let body = AEXMLElement(name: "w:body")
        root.addChild(body)
        body.addChildren(buildParagraphs(paragraphRanges: paragraphRanges, linkRelations: linkRelations))
        body.addChild(pageDef)
        return document.xmlCompact
    }

    func prepareLinks(linkXML: AEXMLDocument) -> [LinkRelationship] {
        var linkURLS = [URL]()
        enumerateAttribute(.link, in: NSRange(location: 0, length: length), options: [.longestEffectiveRangeNotRequired], using: { attribute, _, _ in
            if let link = attribute as? URL {
                linkURLS.append(link)
            }
        })
        guard !linkURLS.isEmpty else { return [LinkRelationship]() }
        let relationships = linkXML["Relationships"]
        let presentIds = relationships.children.map(\.attributes).compactMap { $0["Id"] }.sorted(by: { s1, s2 in
            s1.compare(s2, options: [.numeric], range: nil, locale: nil) == .orderedAscending
        })
        guard let lastID = presentIds.last?.trimmingCharacters(in: .letters), let lastIdIDX = Int(lastID) else { return [LinkRelationship]() }

        let linkRelationShips = linkURLS.enumerated().map { (arg) -> LinkRelationship in
            let (idx, url) = arg
            let newID = "rId\(lastIdIDX + 1 + idx)"
            let relationShip = LinkRelationship(relationshipID: newID, linkURL: url)
            return relationShip
        }

        relationships.addChildren(linkRelationShips.map(\.element))

        return linkRelationShips
    }
}

extension LinkRelationship {
    var element: AEXMLElement {
        AEXMLElement(name: "Relationship", value: nil, attributes: ["Id": relationshipID, "Type": "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink", "Target": linkURL.absoluteString, "TargetMode": "External"])
    }
}
