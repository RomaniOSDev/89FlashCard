//
//  AchievementsView.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject var cardViewModel: CardViewModel
    
    private var sortedAchievements: [Achievement] {
        cardViewModel.achievements
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            if sortedAchievements.isEmpty {
                VStack(spacing: 12) {
                    Text("No achievements yet")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text("Start studying to unlock your first rewards.")
                        .font(.subheadline)
                        .foregroundColor(.flashAccent)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            } else {
                List {
                    ForEach(sortedAchievements) { achievement in
                        AchievementRowView(achievement: achievement)
                            .listRowBackground(Color.white)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.white)
                .listStyle(.plain)
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.flashAccent)
    }
}

struct AchievementRowView: View {
    let achievement: Achievement
    
    private var statusText: String {
        achievement.isUnlocked ? "Unlocked" : "Locked"
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Accent bar for unlocked state
            Rectangle()
                .fill(Color.flashAccent)
                .frame(width: 4)
                .opacity(achievement.isUnlocked ? 1.0 : 0.2)
            
            HStack(spacing: 12) {
                Image(systemName: "rosette")
                    .foregroundColor(.flashAccent)
                    .imageScale(.large)
                    .opacity(achievement.isUnlocked ? 1.0 : 0.3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(achievement.title)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text(achievement.description)
                        .font(.caption)
                        .foregroundColor(.flashAccent)
                        .opacity(achievement.isUnlocked ? 1.0 : 0.5)
                }
                
                Spacer()
                
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.flashAccent)
                    .opacity(achievement.isUnlocked ? 1.0 : 0.5)
            }
            .padding(12)
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.flashAccent, lineWidth: achievement.isUnlocked ? 2 : 1)
                )
        )
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

