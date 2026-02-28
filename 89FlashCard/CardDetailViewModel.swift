//
//  CardDetailViewModel.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import Foundation
import Combine

final class CardDetailViewModel: ObservableObject {
    @Published var flipped: Bool = false
    @Published private(set) var card: FlashCard
    
    private let cardViewModel: CardViewModel
    
    init(card: FlashCard, cardViewModel: CardViewModel) {
        self.card = card
        self.cardViewModel = cardViewModel
        refreshFromSource()
    }
    
    func toggleFlip() {
        flipped.toggle()
    }
    
    func markRemembered() {
        cardViewModel.incrementReviewCount(for: card)
        cardViewModel.toggleCardLearned(card)
        refreshFromSource()
    }
    
    func markForgotten() {
        cardViewModel.incrementReviewCount(for: card)
        refreshFromSource()
    }
    
    private func refreshFromSource() {
        if let updated = cardViewModel.cards.first(where: { $0.id == card.id }) {
            card = updated
        }
    }
}

