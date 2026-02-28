//
//  OnboardingView.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    
    @State private var currentPage: Int = 0
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        title: "Create flashcards",
                        subtitle: "Add your own words, questions and answers to build personalized decks.",
                        systemImage: "square.on.square",
                        index: 0
                    )
                    .tag(0)
                    
                    OnboardingPageView(
                        title: "Study and review",
                        subtitle: "Use Study and Review modes to keep your memory sharp every day.",
                        systemImage: "brain.head.profile",
                        index: 1
                    )
                    .tag(1)
                    
                    OnboardingPageView(
                        title: "Track progress",
                        subtitle: "See your streak, daily goal and achievements as you learn.",
                        systemImage: "chart.bar.fill",
                        index: 2
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                HStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(index == currentPage ? Color.flashAccent : Color.white)
                            .overlay(
                                Circle()
                                    .stroke(Color.flashAccent, lineWidth: 1)
                            )
                            .frame(width: 8, height: 8)
                    }
                }
                
                Button {
                    if currentPage < 2 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        onFinish()
                    }
                } label: {
                    Text(currentPage < 2 ? "Next" : "Get started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient.flashAccentBackground)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                
                Button {
                    onFinish()
                } label: {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundColor(.flashAccent)
                }
                .padding(.bottom, 16)
            }
            .padding(.top, 40)
            .padding(.bottom, 24)
        }
    }
}

private struct OnboardingPageView: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let index: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient.flashCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.flashAccent, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 8)
                
                VStack(spacing: 20) {
                    Image(systemName: systemImage)
                        .font(.system(size: 40))
                        .foregroundColor(.flashAccent)
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.flashAccent)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(32)
            }
            .frame(maxWidth: .infinity, maxHeight: 340)
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

