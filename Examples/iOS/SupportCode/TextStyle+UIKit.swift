//
//  TextStyle+UIKit.swift
//  RiderCore
//
//  Created by Shai Mishali on 31/03/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import UIKit

// Defines a Component that can by styled with a Text Style
protocol TextStyleable: class {
    /// This property should be used to set the Text Style when
    /// it has no attributes, e.g. only set the color and font for
    /// the specific UI component.
    var textStyle: TextStyle { get set }
}

// MARK: - UILabel
extension UILabel: TextStyleable {
    var textStyle: TextStyle {
        get { return TextStyle(fontName: font.fontName,
                               fontSize: Float(font.pointSize),
                               color: textColor)
        }

        set(textStyle) {
            self.font = textStyle.font
            self.textColor = textStyle.color
        }
    }
}

// MARK: - UIButton
extension UIButton: TextStyleable {
    var textStyle: TextStyle {
        get { return TextStyle(fontName: titleLabel?.font.fontName ?? "",
                               fontSize: Float(titleLabel?.font.pointSize ?? 0),
                               color: titleLabel?.textColor ?? .black)
        }

        set(textStyle) {
            self.titleLabel?.font = textStyle.font
            self.setTitleColor(textStyle.color, for: .normal)
        }
    }
}

// MARK: - UIBarButtonItem
extension UIBarButtonItem: TextStyleable {
    var textStyle: TextStyle {
        get {
            guard let attributes = titleTextAttributes(for: .normal) else { return TextStyle(fontName: "", fontSize: 0, color: .black) }
            
            let font = attributes[.font] as? UIFont
            let color = attributes[.foregroundColor] as? UIColor
            
            return TextStyle(fontName: font?.fontName ?? "",
                             fontSize: Float(font?.pointSize ?? 0),
                             color: color ?? .black)
        }
        
        set(textStyle) {
            setTitleTextAttributes([.font: textStyle.font, .foregroundColor: textStyle.color],
                                   for: .normal)
        }
    }
}

// MARK: - UITextField
extension UITextField: TextStyleable {
    var textStyle: TextStyle {
        get { return TextStyle(fontName: font?.fontName ?? "",
                               fontSize: Float(font?.pointSize ?? 0),
                               color: textColor ?? .black)
        }

        set(textStyle) {
            self.font = textStyle.font
            self.textColor = textStyle.color
        }
    }
}
