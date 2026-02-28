//
//  FlashCard.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import Foundation

struct FlashCard: Identifiable, Codable, Hashable {
    let id: UUID
    var frontText: String
    var backText: String
    var isLearned: Bool
    var reviewCount: Int
    var lastReviewDate: Date?
    let creationDate: Date
    /// Optional deck / category name
    var deckName: String = ""
}

