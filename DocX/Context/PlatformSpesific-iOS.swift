//
//  PlatformSpesific-iOS.swift
//  Test
//
//  Created by Mahmut Şahin on 24.11.2020.
//

import Foundation
import UIKit

typealias NSColor = UIColor
typealias NSFont = UIFont
let boldTrait = UIFontDescriptor.SymbolicTraits.traitBold
let italicTrait = UIFontDescriptor.SymbolicTraits.traitItalic

private enum Constants {
    static let docXUTIType = "org.openxmlformats.wordprocessingml.document"
}

extension UIColor {
    var redComponent: CGFloat {
        var red: CGFloat = 0
        getRed(&red, green: nil, blue: nil, alpha: nil)
        return red
    }

    var blueComponent: CGFloat {
        var blue: CGFloat = 0
        getRed(nil, green: nil, blue: &blue, alpha: nil)
        return blue
    }

    var greenComponent: CGFloat {
        var green: CGFloat = 0
        getRed(nil, green: &green, blue: nil, alpha: nil)
        return green
    }

    var hexColorString: String {
        if let cgRGB = cgColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil) {
            let rgbColor = UIColor(cgColor: cgRGB)
            return String(format: "%02X%02X%02X", Int(rgbColor.redComponent * 255), Int(rgbColor.greenComponent * 255), Int(rgbColor.blueComponent * 255))
        } else {
            return "FFFFFF"
        }
    }
}

@objc public class DocXActivityItemProvider: UIActivityItemProvider {
    let attributedString: NSAttributedString
    let tempURL: URL

    @objc public init(attributedString: NSAttributedString) {
        self.attributedString = attributedString
        let tempURL: URL
        if #available(iOS 10.0, *) {
            tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("docx")
        } else {
            tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension("docx")
        }
        self.tempURL = tempURL
        super.init(placeholderItem: tempURL)
    }

    override public func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        Constants.docXUTIType
    }

    override public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        tempURL
    }

    override public var item: Any {
        do {
            try attributedString.writeDocX(to: tempURL)
            return tempURL
        } catch {
            print(error)
            return error
        }
    }
}

@available(iOSApplicationExtension 12.0, *)
public extension NSAttributedString {
    @available(iOS 13.0, *)
    @objc func attributedString(for userInterfaceStyle: UIUserInterfaceStyle) -> NSAttributedString {
        let traitCollection = UITraitCollection(userInterfaceStyle: userInterfaceStyle)

        if traitCollection.hasDifferentColorAppearance(comparedTo: UITraitCollection.current) {
            let mutableSelf = NSMutableAttributedString(attributedString: self)

            traitCollection.performAsCurrent {
                mutableSelf.enumerateAttributes(in: NSRange(location: 0, length: mutableSelf.length), options: [], using: { attribute, range, _ in
                    if let foregroundColor = attribute[.foregroundColor] as? UIColor {
                        let fixedColor = UIColor(cgColor: foregroundColor.cgColor)
                        mutableSelf.addAttribute(.foregroundColor, value: fixedColor, range: range)
                    } else if let backgroundColor = attribute[.backgroundColor] as? UIColor {
                        let fixedColor = UIColor(cgColor: backgroundColor.cgColor)
                        mutableSelf.addAttribute(.backgroundColor, value: fixedColor, range: range)
                    }
                })
            }

            return mutableSelf
        } else {
            return self
        }
    }
}
