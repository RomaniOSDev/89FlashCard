//
//  Achievement.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import Foundation

struct Achievement: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    var isUnlocked: Bool
    var unlockedDate: Date?
}

