//
//  ContentView.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import SwiftUI

enum StatusFilter {
    case all
    case learned
    case notLearned
    case toReview
}

enum SortOption: CaseIterable {
    case creationDate
    case reviewCount
    case lastReview
    
    var title: String {
        switch self {
        case .creationDate: return "By date"
        case .reviewCount: return "By reviews"
        case .lastReview: return "By last review"
        }
    }
}

struct ContentView: View {
    @StateObject private var cardViewModel = CardViewModel()
    @State private var showingAddSheet = false
    @State private var showingSettingsSheet = false
    @State private var randomCard: FlashCard?
    @State private var showRandomDetail = false
    @State private var studyViewModel: StudySessionViewModel?
    @State private var reviewViewModel: StudySessionViewModel?
    @State private var showStudy = false
    @State private var showReview = false
    @State private var quizViewModel: QuizSessionViewModel?
    @State private var showQuiz = false
    @State private var editingCard: FlashCard?
    
    // Filters & search
    @State private var searchText: String = ""
    @State private var statusFilter: StatusFilter = .all
    @State private var selectedDeck: String = "All decks"
    @State private var sortOption: SortOption = .creationDate
    
    // Study session settings
    @AppStorage("flashcard_session_limit") private var sessionLimit: Int = 10
    @AppStorage("flashcard_auto_advance") private var autoAdvanceOnRemembered: Bool = true
    @AppStorage("flashcard_daily_goal") private var dailyGoal: Int = 20
    @AppStorage("flashcard_has_seen_onboarding") private var hasSeenOnboarding: Bool = false
    @State private var showOnboarding: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    statsAndActions
                    
                    filtersAndSearch
                    
                    if filteredCards.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Text("No cards yet")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Text("Tap the + button to add your first card.")
                                .font(.subheadline)
                                .foregroundColor(.flashAccent)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredCards) { card in
                                NavigationLink {
                                    let detailViewModel = CardDetailViewModel(card: card, cardViewModel: cardViewModel)
                                    CardDetailView(viewModel: detailViewModel)
                                } label: {
                                    CardRowView(card: card)
                                }
                                .listRowBackground(Color.white)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button {
                                        editingCard = card
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.flashAccent)
                                    
                                    Button(role: .destructive) {
                                        cardViewModel.deleteCard(card)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(.flashAccent)
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.white)
                        .listStyle(.plain)
                    }
                }
                .padding(.top, 8)
            }
            .navigationTitle("FlashCards")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .foregroundColor(.flashAccent)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 16) {
                        NavigationLink {
                            AchievementsView(cardViewModel: cardViewModel)
                        } label: {
                            Image(systemName: "rosette")
                                .imageScale(.medium)
                                .foregroundColor(.flashAccent)
                        }
                        
                        NavigationLink {
                            StatsView(cardViewModel: cardViewModel)
                        } label: {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .imageScale(.medium)
                                .foregroundColor(.flashAccent)
                        }
                        
                        Button {
                            startRandomCard()
                        } label: {
                            Image(systemName: "shuffle")
                                .imageScale(.medium)
                                .foregroundColor(.flashAccent)
                        }
                        
                        Button {
                            showingSettingsSheet = true
                        } label: {
                            Image(systemName: "gearshape")
                                .imageScale(.medium)
                                .foregroundColor(.flashAccent)
                        }
                    }
                }
            }
            .background(
                ZStack {
                    NavigationLink(
                        destination: randomDetailDestination,
                        isActive: $showRandomDetail
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    
                    NavigationLink(
                        destination: studyDestination,
                        isActive: $showStudy
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    
                    NavigationLink(
                        destination: reviewDestination,
                        isActive: $showReview
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    
                    NavigationLink(
                        destination: quizDestination,
                        isActive: $showQuiz
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
            )
        }
        .tint(.flashAccent)
        .sheet(isPresented: $showingAddSheet) {
            AddEditCardView(
                viewModel: AddEditCardViewModel(cardViewModel: cardViewModel)
            )
        }
        .sheet(item: $editingCard) { card in
            AddEditCardView(
                viewModel: AddEditCardViewModel(cardViewModel: cardViewModel, card: card)
            )
        }
        .sheet(isPresented: $showingSettingsSheet) {
            SessionSettingsView(
                sessionLimit: $sessionLimit,
                autoAdvanceOnRemembered: $autoAdvanceOnRemembered
            )
        }
        .onAppear {
            cardViewModel.refreshAchievements()
            if !hasSeenOnboarding {
                showOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                hasSeenOnboarding = true
                showOnboarding = false
            }
        }
    }
    
    private var filteredCards: [FlashCard] {
        var result = cardViewModel.cards
        
        // Search
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter { card in
                card.frontText.lowercased().contains(query) ||
                card.backText.lowercased().contains(query)
            }
        }
        
        // Deck filter
        if selectedDeck != "All decks" {
            result = result.filter { $0.deckName == selectedDeck }
        }
        
        // Status filter
        switch statusFilter {
        case .all:
            break
        case .learned:
            result = result.filter { $0.isLearned }
        case .notLearned:
            result = result.filter { !$0.isLearned }
        case .toReview:
            let ids = Set(cardViewModel.cardsToReview.map { $0.id })
            result = result.filter { ids.contains($0.id) }
        }
        
        // Sorting
        switch sortOption {
        case .creationDate:
            result.sort { $0.creationDate < $1.creationDate }
        case .reviewCount:
            result.sort { $0.reviewCount > $1.reviewCount }
        case .lastReview:
            result.sort { (lhs, rhs) in
                switch (lhs.lastReviewDate, rhs.lastReviewDate) {
                case let (l?, r?):
                    return l > r
                case (_?, nil):
                    return true
                case (nil, _?):
                    return false
                default:
                    return lhs.creationDate < rhs.creationDate
                }
            }
        }
        
        return result
    }
    
    private var statsAndActions: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today focus")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text("Keep your streak and reach the daily goal.")
                    .font(.caption)
                    .foregroundColor(.flashAccent)
            }
            
            HStack {
                StatItemView(title: "Total", value: cardViewModel.totalCount)
                StatItemView(title: "Learned", value: cardViewModel.learnedCount)
                StatItemView(title: "To review", value: cardViewModel.toReviewTodayCount)
            }
            
            HStack {
                StatItemView(title: "Today", value: cardViewModel.todayReviewCount)
                StatItemView(title: "Goal", value: dailyGoal)
                StatItemView(title: "Streak", value: cardViewModel.currentStreak)
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.flashAccent.opacity(0.3))
            
            HStack(spacing: 12) {
                Button {
                    startStudyAll()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                        Text("Study")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Color.flashAccent)
                    .cornerRadius(10)
                }
                .disabled(cardViewModel.cards.isEmpty)
                .opacity(cardViewModel.cards.isEmpty ? 0.4 : 1.0)
                
                Button {
                    startReviewToday()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("Review")
                    }
                    .font(.subheadline)
                    .foregroundColor(.flashAccent)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.flashAccent, lineWidth: 1)
                    )
                }
                .disabled(cardViewModel.cardsToReview.isEmpty)
                .opacity(cardViewModel.cardsToReview.isEmpty ? 0.4 : 1.0)
                
                Button {
                    startQuiz()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "questionmark.circle")
                        Text("Quiz")
                    }
                    .font(.subheadline)
                    .foregroundColor(.flashAccent)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.flashAccent, lineWidth: 1)
                    )
                }
                .disabled(cardViewModel.cards.isEmpty)
                .opacity(cardViewModel.cards.isEmpty ? 0.4 : 1.0)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient.flashCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.flashAccent, lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
    
    private var filtersAndSearch: some View {
        VStack(spacing: 8) {
            // Search
            HStack {
                TextField("Search", text: $searchText)
                    .textFieldStyle(.plain)
                    .tint(.flashAccent)
                    .foregroundColor(.black)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.flashAccent)
                    }
                }
            }
            .padding(.vertical, 4)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.flashAccent)
            
            // Filters
            HStack {
                filterButton(title: "All", status: .all)
                filterButton(title: "Learned", status: .learned)
                filterButton(title: "Not learned", status: .notLearned)
                filterButton(title: "To review", status: .toReview)
            }
            
            // Deck & sort
            HStack {
                deckPicker
                Spacer()
                sortPicker
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func filterButton(title: String, status: StatusFilter) -> some View {
        Button {
            statusFilter = status
        } label: {
            Text(title)
                .font(.caption)
                .foregroundColor(statusFilter == status ? .white : .flashAccent)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(statusFilter == status ? Color.flashAccent : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.flashAccent, lineWidth: 1)
                        )
                )
        }
    }
    
    private var deckPicker: some View {
        let decks = ["All decks"] + cardViewModel.availableDeckNames
        
        return Menu {
            ForEach(decks, id: \.self) { deck in
                Button {
                    selectedDeck = deck
                } label: {
                    HStack {
                        Text(deck)
                        if selectedDeck == deck {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedDeck)
                    .font(.caption)
                    .foregroundColor(.flashAccent)
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundColor(.flashAccent)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.flashAccent, lineWidth: 1)
            )
        }
    }
    
    private var sortPicker: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    sortOption = option
                } label: {
                    HStack {
                        Text(option.title)
                        if sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(sortOption.title)
                    .font(.caption)
                    .foregroundColor(.flashAccent)
                Image(systemName: "arrow.up.arrow.down")
                    .font(.caption2)
                    .foregroundColor(.flashAccent)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.flashAccent, lineWidth: 1)
            )
        }
    }
    
    private func limitedCards(from source: [FlashCard]) -> [FlashCard] {
        guard !source.isEmpty else { return [] }
        let shuffled = source.shuffled()
        let limit = max(1, sessionLimit)
        return Array(shuffled.prefix(limit))
    }
    
    private func startRandomCard() {
        guard let card = cardViewModel.cards.randomElement() else { return }
        randomCard = card
        showRandomDetail = true
    }
    
    private func startStudyAll() {
        let source = cardViewModel.cards
        let limited = limitedCards(from: source)
        guard !limited.isEmpty else { return }
        studyViewModel = StudySessionViewModel(
            cards: limited,
            cardViewModel: cardViewModel,
            autoAdvanceOnRemembered: autoAdvanceOnRemembered
        )
        showStudy = true
    }
    
    private func startReviewToday() {
        let source = cardViewModel.cardsToReview
        let limited = limitedCards(from: source)
        guard !limited.isEmpty else { return }
        reviewViewModel = StudySessionViewModel(
            cards: limited,
            cardViewModel: cardViewModel,
            autoAdvanceOnRemembered: autoAdvanceOnRemembered
        )
        showReview = true
    }
    
    private func startQuiz() {
        let source = cardViewModel.cardsToReview.isEmpty ? cardViewModel.cards : cardViewModel.cardsToReview
        let limited = limitedCards(from: source)
        guard !limited.isEmpty else { return }
        quizViewModel = QuizSessionViewModel(cards: limited, cardViewModel: cardViewModel)
        showQuiz = true
    }
    
    @ViewBuilder
    private var randomDetailDestination: some View {
        if let randomCard {
            let vm = CardDetailViewModel(card: randomCard, cardViewModel: cardViewModel)
            CardDetailView(viewModel: vm)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var studyDestination: some View {
        if let studyViewModel {
            StudySessionView(viewModel: studyViewModel)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var reviewDestination: some View {
        if let reviewViewModel {
            StudySessionView(viewModel: reviewViewModel)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var quizDestination: some View {
        if let quizViewModel {
            QuizSessionView(viewModel: quizViewModel)
        } else {
            EmptyView()
        }
    }
}

struct StatItemView: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.headline)
                .foregroundColor(.black)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.flashAccent)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.flashAccent, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

struct CardRowView: View {
    let card: FlashCard
    
    private var progressText: String {
        let target = 5
        let current = min(card.reviewCount, target)
        return "\(current)/\(target) repetitions"
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.frontText)
                    .font(.headline)
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    if !card.deckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(card.deckName)
                            .font(.caption2)
                            .foregroundColor(.flashAccent)
                    }
                    
                    Text(progressText)
                        .font(.caption2)
                        .foregroundColor(.flashAccent)
                }
            }
            
            Spacer()
            
            if card.isLearned {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.flashAccent)
                    .imageScale(.large)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.flashAccent, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

struct CardDetailView: View {
    @ObservedObject var viewModel: CardDetailViewModel
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                cardView
                    .padding(.horizontal, 24)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            viewModel.toggleFlip()
                        }
                    }
                    .rotation3DEffect(
                        .degrees(viewModel.flipped ? 180 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button {
                        viewModel.markForgotten()
                    } label: {
                        Text("Don't remember")
                            .font(.headline)
                            .foregroundColor(.flashAccent)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.flashAccent, lineWidth: 1)
                            )
                    }
                    
                    Button {
                        viewModel.markRemembered()
                    } label: {
                        Text("Remembered")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.flashAccent)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .tint(.flashAccent)
    }
    
    private var cardView: some View {
        ZStack {
            // Front side
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.flashAccent, lineWidth: 3)
                    )
                
                VStack(spacing: 16) {
                    Text(viewModel.card.frontText)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    
                    Text("Tap to see answer")
                        .font(.footnote)
                        .foregroundColor(.flashAccent)
                }
                .padding()
            }
            .opacity(viewModel.flipped ? 0 : 1)
            
            // Back side
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.flashAccent)
                
                VStack(spacing: 16) {
                    Text(viewModel.card.backText)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    
                    Text("Tap to go back")
                        .font(.footnote)
                        .foregroundColor(.white)
                }
                .padding()
            }
            .opacity(viewModel.flipped ? 1 : 0)
            .rotation3DEffect(
                .degrees(180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .frame(maxWidth: .infinity, minHeight: 250, maxHeight: 320)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

struct AddEditCardView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AddEditCardViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 20) {
                        // Header inside card
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.isEditing ? "Edit card" : "New card")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                            Text("Fill in the front, back and deck to create a focused flashcard.")
                                .font(.caption)
                                .foregroundColor(.flashAccent)
                        }
                        
                        // Front side
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Front side")
                                .font(.caption)
                                .foregroundColor(.flashAccent)
                            
                        textFieldBlock(
                            title: "Word / Question",
                            text: $viewModel.frontText
                        )
                        }
                        
                        // Back side
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Back side")
                                .font(.caption)
                                .foregroundColor(.flashAccent)
                            
                            textFieldBlock(
                                title: "Translation / Answer",
                                text: $viewModel.backText
                            )
                        }
                        
                        // Deck
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Deck")
                                .font(.caption)
                                .foregroundColor(.flashAccent)
                            
                            textFieldBlock(
                                title: "Deck / Category (optional)",
                                text: $viewModel.deckName
                            )
                            
                            presetsRow
                        }
                        
                        if !viewModel.deckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            HStack(spacing: 6) {
                                Text("Current deck:")
                                    .font(.caption)
                                    .foregroundColor(.flashAccent)
                                
                                Text(viewModel.deckName)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.flashAccent)
                                    )
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(LinearGradient.flashCardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.flashAccent, lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 8)
                    )
                    
                    Spacer()
                    
                    Button {
                        if viewModel.save() {
                            dismiss()
                        }
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient.flashAccentBackground)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.flashAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
                .padding(24)
            }
            .navigationTitle(viewModel.isEditing ? "Edit Card" : "New Card")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(.flashAccent)
    }
    
    private func textFieldBlock(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(title, text: text, axis: .vertical)
                .textFieldStyle(.plain)
                .tint(.flashAccent)
                .foregroundColor(.black)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.flashAccent)
        }
    }
    
    private var presetsRow: some View {
        let presets = ["English", "Spanish", "IT terms", "Phrasal verbs"]
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(presets, id: \.self) { preset in
                    Button {
                        viewModel.deckName = preset
                    } label: {
                        Text(preset)
                            .font(.caption)
                            .foregroundColor(viewModel.deckName == preset ? .white : .flashAccent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.deckName == preset ? Color.flashAccent : Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.flashAccent, lineWidth: 1)
                                    )
                            )
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

