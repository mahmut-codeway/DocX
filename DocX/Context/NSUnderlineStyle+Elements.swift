//
//  NSUnderlineStyle+Elements.swift
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

extension NSUnderlineStyle {
    var elementValue: String {
        let val: String
        switch self {
        case _ where contains(.byWord):
            val = "words"
        case _ where contains(.single):
            val = "single"
        case _ where contains(.double):
            val = "double"
        case _ where contains(.patternDash):
            val = "dash"
        case _ where contains(.patternDot):
            val = "dotted"
        case _ where contains(.patternDashDot):
            val = "dotDash"
        case _ where contains(.patternDashDotDot):
            val = "dotDotDash"
        default:
            val = "none"
        }
        return val
    }

    func underlineElement(for color: NSColor) -> AEXMLElement {
        let colorString = color.hexColorString
        return AEXMLElement(name: "w:u", value: nil, attributes: ["w:color": colorString, "w:val": elementValue])
    }

    var strikeThroughElement: AEXMLElement {
        if contains(.double) {
            return AEXMLElement(name: "w:dstrike", value: nil, attributes: ["w:val": "true"])
        } else {
            return AEXMLElement(name: "w:strike", value: nil, attributes: ["w:val": "true"])
        }
    }
}
