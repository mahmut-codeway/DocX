//
//  DocXManager.swift
//  DocX
//
//  Created by Mahmut Şahin on 6.12.2020.
//

import Foundation

public class DocXManager {
    
    private init() {}
    
    public static func createDocX(_ attributedText: NSAttributedString,_ fileUrl: URL) {
        try? attributedText.writeDocX(to: fileUrl)
    }
}
