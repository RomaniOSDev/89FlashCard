//
//  CardViewModel.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import Foundation
import Combine
import SwiftUI

final class CardViewModel: ObservableObject {
    @Published var cards: [FlashCard] = [] {
        didSet {
            saveCards()
        }
    }
    
    @Published var achievements: [Achievement] = [] {
        didSet {
            saveAchievements()
        }
    }
    
    // Daily stats & streak
    @Published private(set) var todayReviewCount: Int = 0
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var bestStreak: Int = 0
    
    private let calendar = Calendar.current
    
    private let storageKey = "flashcards_storage"
    private let achievementsKey = "flashcards_achievements"
    private let statsKey = "flashcards_stats"
    
    init() {
        loadCards()
        loadAchievements()
        loadStats()
        if achievements.isEmpty {
            achievements = Self.defaultAchievements()
        }
        updateAchievementsForCurrentStats()
    }
    
    // MARK: - Public API
    
    func addCard(front: String, back: String, deck: String? = nil) {
        let deckName = deck?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newCard = FlashCard(
            id: UUID(),
            frontText: front,
            backText: back,
            isLearned: false,
            reviewCount: 0,
            lastReviewDate: nil,
            creationDate: Date(),
            deckName: deckName
        )
        cards.append(newCard)
        updateAchievementsForCurrentStats()
    }
    
    func toggleCardLearned(_ card: FlashCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index].isLearned.toggle()
        updateAchievementsForCurrentStats()
    }
    
    func deleteCard(at offsets: IndexSet) {
        cards.remove(atOffsets: offsets)
        updateAchievementsForCurrentStats()
    }
    
    func deleteCard(_ card: FlashCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards.remove(at: index)
        updateAchievementsForCurrentStats()
    }
    
    func incrementReviewCount(for card: FlashCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index].reviewCount += 1
        cards[index].lastReviewDate = Date()
        registerReview()
        updateAchievementsForCurrentStats()
    }
    
    func updateCard(_ updated: FlashCard) {
        guard let index = cards.firstIndex(where: { $0.id == updated.id }) else { return }
        cards[index] = updated
    }
    
    // MARK: - Derived collections & stats
    
    var cardsToReview: [FlashCard] {
        let now = Date()
        let oneDay: TimeInterval = 24 * 60 * 60
        
        return cards.filter { card in
            if !card.isLearned {
                return true
            }
            guard let last = card.lastReviewDate else {
                return true
            }
            return now.timeIntervalSince(last) > oneDay
        }
    }
    
    var totalCount: Int {
        cards.count
    }
    
    var learnedCount: Int {
        cards.filter { $0.isLearned }.count
    }
    
    var toReviewTodayCount: Int {
        cardsToReview.count
    }
    
    var totalReviewsCount: Int {
        cards.reduce(0) { $0 + $1.reviewCount }
    }
    
    var availableDeckNames: [String] {
        let names = cards
            .map { $0.deckName.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return Array(Set(names)).sorted()
    }
    
    // MARK: - Persistence
    
    private func saveCards() {
        do {
            let data = try JSONEncoder().encode(cards)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save cards: \(error)")
        }
    }
    
    private func loadCards() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        
        do {
            let decoded = try JSONDecoder().decode([FlashCard].self, from: data)
            cards = decoded
        } catch {
            print("Failed to load cards: \(error)")
        }
    }
    
    private func saveAchievements() {
        do {
            let data = try JSONEncoder().encode(achievements)
            UserDefaults.standard.set(data, forKey: achievementsKey)
        } catch {
            print("Failed to save achievements: \(error)")
        }
    }
    
    private func loadAchievements() {
        guard let data = UserDefaults.standard.data(forKey: achievementsKey) else { return }
        
        do {
            let decoded = try JSONDecoder().decode([Achievement].self, from: data)
            achievements = decoded
        } catch {
            print("Failed to load achievements: \(error)")
        }
    }
    
    private struct StoredStats: Codable {
        let todayCount: Int
        let currentStreak: Int
        let bestStreak: Int
        let lastReviewDate: Date?
    }
    
    private func saveStats(lastReviewDate: Date?) {
        let stats = StoredStats(
            todayCount: todayReviewCount,
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            lastReviewDate: lastReviewDate
        )
        
        do {
            let data = try JSONEncoder().encode(stats)
            UserDefaults.standard.set(data, forKey: statsKey)
        } catch {
            print("Failed to save stats: \(error)")
        }
    }
    
    private func loadStats() {
        guard let data = UserDefaults.standard.data(forKey: statsKey) else { return }
        
        do {
            let decoded = try JSONDecoder().decode(StoredStats.self, from: data)
            self.todayReviewCount = decoded.todayCount
            self.currentStreak = decoded.currentStreak
            self.bestStreak = decoded.bestStreak
            
            // Normalize today counter based on date
            if let lastDate = decoded.lastReviewDate {
                if calendar.isDateInToday(lastDate) {
                    // keep todayReviewCount as is
                } else {
                    todayReviewCount = 0
                }
            } else {
                todayReviewCount = 0
            }
        } catch {
            print("Failed to load stats: \(error)")
        }
    }
    
    // MARK: - Achievements logic
    
    func refreshAchievements() {
        updateAchievementsForCurrentStats()
    }
    
    private static func defaultAchievements() -> [Achievement] {
        return [
            Achievement(
                id: "first_card",
                title: "First step",
                description: "Create your first card.",
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "ten_cards",
                title: "Collector",
                description: "Create 10 cards.",
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "fifty_cards",
                title: "Deck master",
                description: "Create 50 cards.",
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "first_learned",
                title: "First memory",
                description: "Mark your first card as learned.",
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "ten_learned",
                title: "Brain trainer",
                description: "Learn 10 cards.",
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "fifty_reviews",
                title: "Hard worker",
                description: "Complete 50 reviews.",
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "hundred_reviews",
                title: "FlashCard pro",
                description: "Complete 100 reviews.",
                isUnlocked: false,
                unlockedDate: nil
            )
        ]
    }
    
    private func updateAchievementsForCurrentStats() {
        let totalCards = totalCount
        let learned = learnedCount
        let reviews = totalReviewsCount
        
        checkAchievement(id: "first_card", condition: totalCards >= 1)
        checkAchievement(id: "ten_cards", condition: totalCards >= 10)
        checkAchievement(id: "fifty_cards", condition: totalCards >= 50)
        
        checkAchievement(id: "first_learned", condition: learned >= 1)
        checkAchievement(id: "ten_learned", condition: learned >= 10)
        
        checkAchievement(id: "fifty_reviews", condition: reviews >= 50)
        checkAchievement(id: "hundred_reviews", condition: reviews >= 100)
    }
    
    private func checkAchievement(id: String, condition: Bool) {
        guard condition else { return }
        guard let index = achievements.firstIndex(where: { $0.id == id }) else { return }
        guard !achievements[index].isUnlocked else { return }
        
        achievements[index].isUnlocked = true
        achievements[index].unlockedDate = Date()
        saveAchievements()
    }
    
    // MARK: - Daily streak logic
    
    private func registerReview() {
        let now = Date()
        var lastReviewDate: Date? = nil
        
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let stored = try? JSONDecoder().decode(StoredStats.self, from: data) {
            lastReviewDate = stored.lastReviewDate
        }
        
        if let last = lastReviewDate {
            if calendar.isDateInToday(last) {
                todayReviewCount += 1
            } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
                      calendar.isDate(last, inSameDayAs: yesterday) {
                todayReviewCount = 1
                currentStreak += 1
            } else {
                todayReviewCount = 1
                currentStreak = 1
            }
        } else {
            todayReviewCount = 1
            currentStreak = max(currentStreak, 1)
        }
        
        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }
        
        saveStats(lastReviewDate: now)
    }
}

