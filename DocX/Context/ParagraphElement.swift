//
//  ParagraphElement.swift
//  Test
//
//  Created by Mahmut Şahin on 24.11.2020.
//

import Foundation
#if canImport(Cocoa)
import Cocoa
#elseif canImport(UIKit)
import UIKit
#endif
import AEXML

class ParagraphElement: AEXMLElement {
    override fileprivate init(name: String, value: String? = nil, attributes: [String: String] = [String: String]()) {
        fatalError()
    }

    let linkRelations: [LinkRelationship]

    init(string: NSAttributedString, range: Range<String.Index>, linkRelations: [LinkRelationship]) {
        self.linkRelations = linkRelations
        super.init(name: "w:p", value: nil, attributes: ["rsidR": "00045791", "w:rsidRDefault": "008111DF"])
        addChildren(buildRuns(string: string, range: range))
    }

    fileprivate func buildRuns(string: NSAttributedString, range: Range<String.Index>) -> [AEXMLElement] {
        var elements = [AEXMLElement]()
        let subString = string.attributedSubstring(from: NSRange(range, in: string.string))

        guard subString.length > 0 else { return [AEXMLElement]() }

        if let paragraphStyle = subString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
            elements.append(paragraphStyle.paragraphElements)
        }

        subString.enumerateAttributes(in: NSRange(location: 0, length: subString.length), options: [], using: { attributes, effectiveRange, _ in
            let affectedSubstring = subString.attributedSubstring(from: effectiveRange)

            if let link = attributes[.link] as? URL, let relationShip = self.linkRelations.first(where: { $0.linkURL == link }) {
                elements.append(attributes.linkProperties(relationship: relationShip, affectedString: affectedSubstring))
            } else {
                let runElement = AEXMLElement(name: "w:r", value: nil, attributes: [:])

                let affectedText = affectedSubstring.string

                let attributesElement = attributes.runProperties

                if let ruby = attributes[.ruby] {
                    // swiftlint:disable force_cast
                    let rubyAnnotation = ruby as! CTRubyAnnotation
                    if let element = rubyAnnotation.rubyElement(baseString: affectedSubstring) {
                        runElement.addChildren([attributesElement, element])
                    }
                } else {
                    let textElement = affectedText.element
                    runElement.addChildren([attributesElement, textElement])
                }
                // swiftlint:enable force_cast
                elements.append(runElement)
            }
        })

        return elements
    }
}
