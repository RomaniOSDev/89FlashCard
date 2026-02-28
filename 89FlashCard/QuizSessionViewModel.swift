//
//  QuizSessionViewModel.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import Foundation
import Combine

final class QuizSessionViewModel: ObservableObject {
    @Published private(set) var cards: [FlashCard]
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var isCompleted: Bool = false
    @Published private(set) var options: [String] = []
    @Published private(set) var correctAnswer: String = ""
    @Published private(set) var selectedOption: String? = nil
    @Published private(set) var correctCount: Int = 0
    
    private let cardViewModel: CardViewModel
    
    init(cards: [FlashCard], cardViewModel: CardViewModel) {
        self.cards = cards
        self.cardViewModel = cardViewModel
        prepareQuestion()
    }
    
    var currentCard: FlashCard? {
        guard !cards.isEmpty, currentIndex >= 0, currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }
    
    var questionNumberText: String {
        "Question \(currentIndex + 1) of \(cards.count)"
    }
    
    func selectOption(_ option: String) {
        guard !isCompleted else { return }
        guard selectedOption == nil else { return }
        
        selectedOption = option
        
        if option == correctAnswer {
            correctCount += 1
        }
        
        if let card = currentCard {
            cardViewModel.incrementReviewCount(for: card)
        }
    }
    
    func goToNext() {
        guard !isCompleted else { return }
        
        if currentIndex < cards.count - 1 {
            currentIndex += 1
            selectedOption = nil
            prepareQuestion()
        } else {
            isCompleted = true
        }
    }
    
    private func prepareQuestion() {
        guard let card = currentCard else { return }
        
        correctAnswer = card.backText
        
        var otherAnswers = cards
            .filter { $0.id != card.id }
            .map { $0.backText }
        
        otherAnswers.shuffle()
        let distractors = Array(otherAnswers.prefix(3))
        
        var allOptions = [correctAnswer] + distractors
        allOptions.shuffle()
        options = allOptions
    }
}

