//
//  NSAttributedString+Extensions.swift
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

extension NSAttributedString {
    var paragraphRanges: [Range<String.Index>] {
        var ranges = [Range<String.Index>]()
        string.enumerateSubstrings(in: string.startIndex ..< string.endIndex, options: [.byParagraphs, .substringNotRequired]) { _, range, _, _ in
            ranges.append(range)
        }
        return ranges
    }

    var verticalFormEnabled: Bool {
        var vertical = false

        enumerateAttribute(.verticalForms, in: NSRange(location: 0, length: length), options: [.longestEffectiveRangeNotRequired], using: { attribute, _, stop in
            if let attribute = attribute as? Bool, attribute == true {
                vertical = true
                stop.pointee = true
            }
        })
        enumerateAttribute(.verticalGlyphForm, in: NSRange(location: 0, length: length), options: [.longestEffectiveRangeNotRequired], using: { attribute, _, stop in
            if let attribute = attribute as? Bool, attribute == true {
                vertical = true
                stop.pointee = true
            }
        })

        return vertical
    }

    var containsRubyAnnotations: Bool {
        var hasRuby = false

        enumerateAttribute(.ruby, in: NSRange(location: 0, length: length), options: [.longestEffectiveRangeNotRequired], using: { attribute, _, stop in
            if attribute != nil {
                hasRuby = true
                stop.pointee = true
            }
        })
        return hasRuby
    }
}

public extension NSAttributedString.Key {
    static let ruby = NSAttributedString.Key(kCTRubyAnnotationAttributeName as String)
    static let verticalForms = NSAttributedString.Key(kCTVerticalFormsAttributeName as String)
}
