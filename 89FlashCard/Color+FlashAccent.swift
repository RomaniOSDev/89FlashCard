//
//  Color+FlashAccent.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import SwiftUI

extension Color {
    static let flashAccent = Color(red: 1.0, green: 0.235, blue: 0.0) // #FF3C00
}

extension LinearGradient {
    /// Soft card background using only white and flashAccent
    static let flashCardBackground = LinearGradient(
        colors: [
            .white,
            Color.flashAccent.opacity(0.08)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Stronger accent background using only white and flashAccent
    static let flashAccentBackground = LinearGradient(
        colors: [
            Color.flashAccent,
            Color.flashAccent.opacity(0.6)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}


