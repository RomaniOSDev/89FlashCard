//
//  StudySessionViewModel.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import Foundation
import Combine

final class StudySessionViewModel: ObservableObject {
    @Published private(set) var cards: [FlashCard]
    @Published private(set) var currentIndex: Int = 0
    @Published var flipped: Bool = false
    @Published private(set) var isCompleted: Bool = false
    
    private let cardViewModel: CardViewModel
    private let autoAdvanceOnRemembered: Bool
    
    init(cards: [FlashCard], cardViewModel: CardViewModel, autoAdvanceOnRemembered: Bool) {
        self.cards = cards
        self.cardViewModel = cardViewModel
        self.autoAdvanceOnRemembered = autoAdvanceOnRemembered
    }
    
    var currentCard: FlashCard? {
        guard !cards.isEmpty, currentIndex >= 0, currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }
    
    func toggleFlip() {
        flipped.toggle()
    }
    
    func markRemembered() {
        guard let card = currentCard else { return }
        cardViewModel.incrementReviewCount(for: card)
        cardViewModel.toggleCardLearned(card)
        // Always advance to the next card after remembering
        goToNextCard(shouldAutoAdvance: true)
    }
    
    func markForgotten() {
        guard let card = currentCard else { return }
        cardViewModel.incrementReviewCount(for: card)
        goToNextCard(shouldAutoAdvance: true)
    }
    
    func goToNextCard(shouldAutoAdvance: Bool = true) {
        guard shouldAutoAdvance else { return }
        guard !cards.isEmpty else { return }
        
        if currentIndex < cards.count - 1 {
            currentIndex += 1
            flipped = false
        } else {
            isCompleted = true
        }
    }
}

