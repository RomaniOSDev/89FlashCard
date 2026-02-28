//
//  AddEditCardViewModel.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import Foundation
import Combine

final class AddEditCardViewModel: ObservableObject {
    @Published var frontText: String
    @Published var backText: String
    @Published var deckName: String
    
    let isEditing: Bool
    
    private let cardViewModel: CardViewModel
    private let existingCard: FlashCard?
    
    init(cardViewModel: CardViewModel, card: FlashCard? = nil) {
        self.cardViewModel = cardViewModel
        self.existingCard = card
        self.frontText = card?.frontText ?? ""
        self.backText = card?.backText ?? ""
        self.deckName = card?.deckName ?? ""
        self.isEditing = card != nil
    }
    
    @discardableResult
    func save() -> Bool {
        let trimmedFront = frontText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBack = backText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDeck = deckName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedFront.isEmpty, !trimmedBack.isEmpty else {
            return false
        }
        
        if var card = existingCard {
            card.frontText = trimmedFront
            card.backText = trimmedBack
            card.deckName = trimmedDeck
            cardViewModel.updateCard(card)
        } else {
            cardViewModel.addCard(front: trimmedFront, back: trimmedBack, deck: trimmedDeck)
        }
        
        return true
    }
}

