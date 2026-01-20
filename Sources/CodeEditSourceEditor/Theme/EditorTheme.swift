//
//  EditorTheme.swift
//  CodeEditSourceEditor
//
//  Created by Lukas Pistrol on 29.05.22.
//

import SwiftUI

/// Compares two NSColors by their RGBA component values rather than by reference.
/// This is necessary because NSColor's default Equatable compares by reference,
/// which causes issues when comparing theme colors that may be recreated with the same values.
private func colorsAreEqual(_ lhs: NSColor, _ rhs: NSColor) -> Bool {
    // Convert both colors to the same color space for comparison
    guard let lhsRGB = lhs.usingColorSpace(.sRGB),
          let rhsRGB = rhs.usingColorSpace(.sRGB) else {
        // Fallback to comparing hex strings if color space conversion fails
        return lhs.hexString == rhs.hexString
    }
    // Compare with a small tolerance for floating point differences
    let tolerance: CGFloat = 0.001
    return abs(lhsRGB.redComponent - rhsRGB.redComponent) < tolerance &&
           abs(lhsRGB.greenComponent - rhsRGB.greenComponent) < tolerance &&
           abs(lhsRGB.blueComponent - rhsRGB.blueComponent) < tolerance &&
           abs(lhsRGB.alphaComponent - rhsRGB.alphaComponent) < tolerance
}

/// A collection of attributes used for syntax highlighting and other colors for the editor.
///
/// Attributes of a theme that do not apply to text (background, line highlight) are a single `NSColor` for simplicity.
/// All other attributes use the ``EditorTheme/Attribute`` type to store
public struct EditorTheme: Equatable {
    /// Represents attributes that can be applied to style text.
    public struct Attribute: Equatable, Hashable, Sendable {
        public let color: NSColor
        public let bold: Bool
        public let italic: Bool

        public init(color: NSColor, bold: Bool = false, italic: Bool = false) {
            self.color = color
            self.bold = bold
            self.italic = italic
        }

        /// Custom Equatable that compares colors by component values, not by reference.
        public static func == (lhs: Attribute, rhs: Attribute) -> Bool {
            colorsAreEqual(lhs.color, rhs.color) && lhs.bold == rhs.bold && lhs.italic == rhs.italic
        }
    }

    public var text: Attribute
    public var insertionPoint: NSColor
    public var invisibles: Attribute
    public var background: NSColor
    public var lineHighlight: NSColor
    public var selection: NSColor
    public var keywords: Attribute
    public var commands: Attribute
    public var types: Attribute
    public var attributes: Attribute
    public var variables: Attribute
    public var values: Attribute
    public var numbers: Attribute
    public var strings: Attribute
    public var characters: Attribute
    public var comments: Attribute

    public init(
        text: Attribute,
        insertionPoint: NSColor,
        invisibles: Attribute,
        background: NSColor,
        lineHighlight: NSColor,
        selection: NSColor,
        keywords: Attribute,
        commands: Attribute,
        types: Attribute,
        attributes: Attribute,
        variables: Attribute,
        values: Attribute,
        numbers: Attribute,
        strings: Attribute,
        characters: Attribute,
        comments: Attribute
    ) {
        self.text = text
        self.insertionPoint = insertionPoint
        self.invisibles = invisibles
        self.background = background
        self.lineHighlight = lineHighlight
        self.selection = selection
        self.keywords = keywords
        self.commands = commands
        self.types = types
        self.attributes = attributes
        self.variables = variables
        self.values = values
        self.numbers = numbers
        self.strings = strings
        self.characters = characters
        self.comments = comments
    }

    /// Maps a capture type to the attributes for that capture determined by the theme.
    /// - Parameter capture: The capture to map to.
    /// - Returns: Theme attributes for the capture.
    private func mapCapture(_ capture: CaptureName?) -> Attribute {
        switch capture {
        case .include, .constructor, .keyword, .boolean, .variableBuiltin,
                .keywordReturn, .keywordFunction, .repeat, .conditional, .tag:
            return keywords
        case .comment: return comments
        case .variable, .property: return variables
        case .function, .method: return variables
        case .number, .float: return numbers
        case .string: return strings
        case .type: return types
        case .parameter: return variables
        case .typeAlternate: return attributes
        default: return text
        }
    }

    /// Get the color from ``theme`` for the specified capture name.
    /// - Parameter capture: The capture name
    /// - Returns: A `NSColor`
    func colorFor(_ capture: CaptureName?) -> NSColor {
        return mapCapture(capture).color
    }

    /// Returns the correct font with attributes (bold and italics) for a given capture name.
    /// - Parameters:
    ///   - capture: The capture name.
    ///   - font: The font to add attributes to.
    /// - Returns: A new font that has the correct attributes for the capture.
    func fontFor(for capture: CaptureName?, from font: NSFont) -> NSFont {
        let attributes = mapCapture(capture)
        guard attributes.bold || attributes.italic else {
            return font
        }

        var font = font

        if attributes.bold {
            font = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
        }

        if attributes.italic {
            font = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
        }

        return font
    }

    /// Custom Equatable that compares colors by component values, not by reference.
    /// This prevents unnecessary theme updates when colors are recreated with the same values.
    public static func == (lhs: EditorTheme, rhs: EditorTheme) -> Bool {
        lhs.text == rhs.text &&
        colorsAreEqual(lhs.insertionPoint, rhs.insertionPoint) &&
        lhs.invisibles == rhs.invisibles &&
        colorsAreEqual(lhs.background, rhs.background) &&
        colorsAreEqual(lhs.lineHighlight, rhs.lineHighlight) &&
        colorsAreEqual(lhs.selection, rhs.selection) &&
        lhs.keywords == rhs.keywords &&
        lhs.commands == rhs.commands &&
        lhs.types == rhs.types &&
        lhs.attributes == rhs.attributes &&
        lhs.variables == rhs.variables &&
        lhs.values == rhs.values &&
        lhs.numbers == rhs.numbers &&
        lhs.strings == rhs.strings &&
        lhs.characters == rhs.characters &&
        lhs.comments == rhs.comments
    }
}
