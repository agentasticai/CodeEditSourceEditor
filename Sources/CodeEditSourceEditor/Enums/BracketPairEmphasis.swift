//
//  BracketPairEmphasis.swift
//  CodeEditSourceEditor
//
//  Created by Khan Winter on 5/3/23.
//

import AppKit

/// Compares two NSColors by their RGBA component values rather than by reference.
/// This is necessary because NSColor's default Equatable compares by reference,
/// which causes issues when comparing colors that may be recreated with the same values.
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

/// An enum representing the type of emphasis to use for bracket pairs.
public enum BracketPairEmphasis: Equatable {
    /// Emphasize both the opening and closing character in a pair with a bounding box.
    /// The boxes will stay on screen until the cursor moves away from the bracket pair.
    case bordered(color: NSColor)
    /// Flash a yellow emphasis box on only the opposite character in the pair.
    /// This is closely matched to Xcode's flash emphasis for bracket pairs, and animates in and out over the course
    /// of `0.75` seconds.
    case flash
    /// Emphasize both the opening and closing character in a pair with an underline.
    /// The underline will stay on screen until the cursor moves away from the bracket pair.
    case underline(color: NSColor)

    /// Custom Equatable that compares colors by component values, not by reference.
    /// This prevents unnecessary configuration updates when colors are recreated with the same values.
    public static func == (lhs: BracketPairEmphasis, rhs: BracketPairEmphasis) -> Bool {
        switch (lhs, rhs) {
        case (.flash, .flash):
            return true
        case (.bordered(let lhsColor), .bordered(let rhsColor)):
            return colorsAreEqual(lhsColor, rhsColor)
        case (.underline(let lhsColor), .underline(let rhsColor)):
            return colorsAreEqual(lhsColor, rhsColor)
        default:
            return false
        }
    }

    /// Returns `true` if the emphasis should act on both the opening and closing bracket.
    var emphasizesSourceBracket: Bool {
        switch self {
        case .bordered, .underline:
            return true
        case .flash:
            return false
        }
    }
}
