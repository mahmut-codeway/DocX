//
//  NSParagraphStyle+Elements.swift
//  Test
//
//  Created by Mahmut Şahin on 24.11.2020.
//

import AEXML
import Foundation

#if canImport(Cocoa)
import Cocoa
#elseif canImport(UIKit)
import UIKit
#endif

extension NSParagraphStyle {
    var paragraphElements: AEXMLElement {
        let paragraphStyleElement = AEXMLElement(name: "w:pPr")
        paragraphStyleElement.addChildren([
            alignmentElement,
            spacingElement,
            indentationElement,
        ].compactMap { $0 })

        return paragraphStyleElement
    }

    var alignmentElement: AEXMLElement? {
        let element = AEXMLElement(name: "w:jc", value: nil, attributes: ["w:val": alignment.attributeValue])
        return element
    }

    var spacingElement: AEXMLElement? {
        var attributes = [String: String]()

        if paragraphSpacingBefore > 0 {
            attributes["w:before"] = String(Int(paragraphSpacingBefore * 20))
        }
        if paragraphSpacing > 0 {
            attributes["w:after"] = String(Int(paragraphSpacing * 20))
        }
        if lineHeightMultiple > 0 {
            attributes["w:lineRule"] = "auto"
            attributes["w:line"] = String(Int(lineHeightMultiple * 240))
        }
        if lineSpacing > 0 {
            attributes["w:lineRule"] = "exact"
            attributes["w:line"] = String(Int(lineSpacing * 20))
        }

        guard attributes.isEmpty == false else { return nil }
        return AEXMLElement(name: "w:spacing", value: nil, attributes: attributes)
    }

    var indentationElement: AEXMLElement? {
        var attributes = [String: String]()
        if headIndent > 0 || firstLineHeadIndent > 0 {
            let delta = headIndent - firstLineHeadIndent
            switch delta {
            case _ where delta == 0:
                attributes["w:start"] = String(Int(headIndent * 20))
            case _ where delta > 0:
                attributes["w:start"] = String(Int(headIndent * 20))
                attributes["w:hanging"] = String(Int(delta * 20))
            case _ where delta < 0:
                attributes["w:start"] = String(Int(headIndent * 20))
                attributes["w:firstLine"] = String(Int(-delta * 20))
            default:
                break
            }
        }
        /* this isnt really compatible with how cocoa is handling tail indents, in the NSTextView, the indent is from the leading margin
         word, howver, want the distance from the trailing margin, we don't know that, unless we know the page size
         the tailindent could alo be negative, which means it is from the trailing margin. wehn using the standar ruler views to manipulate the indents, however, the value appears to be positive throughout
         the Cocoa TextKit exporter ignores these attributes entirely
         */
        if tailIndent < 0 {
            attributes["w:end"] = String(Int(abs(tailIndent) * 20))
        }

        guard attributes.isEmpty == false else { return nil }
        return AEXMLElement(name: "w:ind", value: nil, attributes: attributes)
    }
}

extension NSTextAlignment {
    var attributeValue: String {
        switch self {
        case .center:
            return "center"
        case .justified:
            return "both"
        case .left:
            return "start"
        case .right:
            return "end"
        default:
            return "start"
        }
    }
}
