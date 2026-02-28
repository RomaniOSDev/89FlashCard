//
//  StatsView.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var cardViewModel: CardViewModel
    @AppStorage("flashcard_daily_goal") private var dailyGoal: Int = 20
    
    private var todayProgressText: String {
        "\(cardViewModel.todayReviewCount)/\(dailyGoal) reviews today"
    }
    
    private var goalReached: Bool {
        cardViewModel.todayReviewCount >= dailyGoal
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Group {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text(todayProgressText)
                            .font(.subheadline)
                            .foregroundColor(.flashAccent)
                        
                        HStack {
                            Rectangle()
                                .fill(Color.flashAccent)
                                .frame(
                                    width: max(
                                        0,
                                        min(
                                            1,
                                            CGFloat(cardViewModel.todayReviewCount) / CGFloat(max(dailyGoal, 1))
                                        )
                                    ) * 220,
                                    height: 4
                                )
                            
                            Spacer()
                        }
                        
                        if goalReached {
                            Text("Daily goal reached!")
                                .font(.caption)
                                .foregroundColor(.flashAccent)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Streak")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        HStack(spacing: 16) {
                            StatItemView(title: "Current streak", value: cardViewModel.currentStreak)
                            StatItemView(title: "Best streak", value: cardViewModel.bestStreak)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Totals")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        HStack(spacing: 16) {
                            StatItemView(title: "Total cards", value: cardViewModel.totalCount)
                            StatItemView(title: "Learned", value: cardViewModel.learnedCount)
                        }
                        
                        HStack(spacing: 16) {
                            StatItemView(title: "To review", value: cardViewModel.toReviewTodayCount)
                            StatItemView(title: "Reviews", value: cardViewModel.totalReviewsCount)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.flashAccent, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
                )
                
                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.flashAccent)
    }
}

