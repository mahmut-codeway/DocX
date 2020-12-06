//
//  AttributeElements.swift
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

extension Dictionary where Key == NSAttributedString.Key {
    var runProperties: AEXMLElement {
        let attributesElement = AEXMLElement(name: "w:rPr")

        if let font = self[.font] as? NSFont {
            attributesElement.addChildren(font.attributeElements)
        }

        if let color = self[.foregroundColor] as? NSColor {
            if let strokeWidth = self[.strokeWidth] as? CGFloat,
               strokeWidth != 0,
               let font = self[.font] as? NSFont
            {
                attributesElement.addChildren(outlineProperties(strokeWidth: strokeWidth, font: font))
            } else {
                attributesElement.addChild(color.colorElement)
            }
        } else if let strokeWidth = self[.strokeWidth] as? CGFloat,
                  strokeWidth != 0,
                  let font = self[.font] as? NSFont
        {
            attributesElement.addChildren(outlineProperties(strokeWidth: strokeWidth, font: font))
        }

        if let style = self[.underlineStyle] as? Int, let color = self[.foregroundColor] as? NSColor {
            let underline = NSUnderlineStyle(rawValue: style)
            attributesElement.addChild(underline.underlineElement(for: color))
        }

        if let backgroundColor = self[.backgroundColor] as? NSColor {
            attributesElement.addChild(backgroundColor.backgroundColorElement)
        }

        if let style = self[.strikethroughStyle] as? Int {
            let strikeThrough = NSUnderlineStyle(rawValue: style)
            attributesElement.addChild(strikeThrough.strikeThroughElement)
        }

        return attributesElement
    }

    func rubyAnnotationRunProperties(scaleFactor: CGFloat) -> AEXMLElement {
        let element = runProperties
        if let font = self[.font] as? NSFont {
            let size = Int(font.pointSize * scaleFactor * 2)
            let sizeElement = AEXMLElement(name: "w:sz", value: nil, attributes: ["w:val": String(size)])
            element.addChild(sizeElement)
        }
        return element
    }

    func linkProperties(relationship: LinkRelationship, affectedString: NSAttributedString) -> AEXMLElement {
        let hyperlinkElement = AEXMLElement(name: "w:hyperlink ", value: nil, attributes: ["r:id": relationship.relationshipID])
        let runElement = AEXMLElement(name: "w:r", value: nil, attributes: [:])
        hyperlinkElement.addChild(runElement)
        runElement.addChild(runProperties)
        runElement.addChild(affectedString.string.element)
        return hyperlinkElement
    }

    func outlineProperties(strokeWidth: CGFloat, font: NSFont) -> [AEXMLElement] {
        let strokeColor: NSColor
        let fillColor: NSColor

        if strokeWidth > 0 {
            strokeColor = (self[.strokeColor] as? NSColor ?? self[.foregroundColor] as? NSColor) ?? NSColor.black
            fillColor = self[.backgroundColor] as? NSColor ?? NSColor.white
        } else {
            strokeColor = (self[.strokeColor] as? NSColor ?? self[.foregroundColor] as? NSColor) ?? NSColor.black
            fillColor = self[.foregroundColor] as? NSColor ?? NSColor.black
        }

        let fontSize = font.pointSize
        let strokeWidth = abs(fontSize * strokeWidth / 100)
        let wordStrokeWidth = Int(strokeWidth * 12700)
        let colorElement = fillColor.colorElement
        let outlineElement = AEXMLElement(name: "w14:textOutline", value: nil, attributes: ["w14:cap": "flat", "w14:cmpd": "sng", "w14:algn": "ctr", "w14:w": String(wordStrokeWidth)])
        let fillElement = AEXMLElement(name: "w14:solidFill")
        outlineElement.addChild(fillElement)
        let strokeColorElement = AEXMLElement(name: "w14:srgbClr", value: nil, attributes: ["w14:val": strokeColor.hexColorString])
        fillElement.addChild(strokeColorElement)
        let dashElement = AEXMLElement(name: "w14:prstDash", value: nil, attributes: ["w14:val": "solid"])
        outlineElement.addChild(dashElement)
        let lineCapElement = AEXMLElement(name: "w14:round")
        outlineElement.addChild(lineCapElement)

        return [colorElement, outlineElement]
    }
}

extension NSColor {
    var colorElement: AEXMLElement {
        AEXMLElement(name: "w:color", value: nil, attributes: ["w:val": hexColorString])
    }

    var backgroundColorElement: AEXMLElement {
        AEXMLElement(name: "w:shd", value: nil, attributes: ["w:fill": hexColorString, "w:val": "clear", "w:color": hexColorString])
    }
}

extension String {
    var element: AEXMLElement {
        let textElement = AEXMLElement(name: "w:t", value: self, attributes: ["xml:space": "preserve"])
        return textElement
    }
}
