//
//  SessionSettingsView.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import SwiftUI
import StoreKit
import UIKit

struct SessionSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var sessionLimit: Int
    @Binding var autoAdvanceOnRemembered: Bool
    @AppStorage("flashcard_daily_goal") private var dailyGoal: Int = 20
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Study settings")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text("Customize how you study and review cards.")
                            .font(.caption)
                            .foregroundColor(.flashAccent)
                    }
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Cards per session")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            HStack {
                                Stepper("", value: $sessionLimit, in: 5...100, step: 5)
                                    .labelsHidden()
                                
                                Spacer()
                                
                                Text("\(sessionLimit)")
                                    .font(.headline)
                                    .foregroundColor(.flashAccent)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: $autoAdvanceOnRemembered) {
                                Text("Auto-advance on \"Remembered\"")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                            .tint(.flashAccent)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Daily review goal")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            HStack {
                                Stepper("", value: $dailyGoal, in: 5...200, step: 5)
                                    .labelsHidden()
                                
                                Spacer()
                                
                                Text("\(dailyGoal)")
                                    .font(.headline)
                                    .foregroundColor(.flashAccent)
                            }
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
                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
                    )
                    
                    VStack(spacing: 12) {
                        Button {
                            rateApp()
                        } label: {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.flashAccent)
                                Text("Rate FlashCard")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.flashAccent, lineWidth: 1)
                                    )
                            )
                        }
                        
                        Button {
                            openPrivacyPolicy()
                        } label: {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.flashAccent)
                                Text("Privacy Policy")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.flashAccent, lineWidth: 1)
                                    )
                            )
                        }
                        
                        Button {
                            openTerms()
                        } label: {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.flashAccent)
                                Text("Terms of Use")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.flashAccent, lineWidth: 1)
                                    )
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Study settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.flashAccent)
                }
            }
        }
        .tint(.flashAccent)
    }
}
    
private func openPrivacyPolicy() {
    if let url = URL(string: "https://www.termsfeed.com/live/1cf282d1-ac85-452d-be19-89ddea143f69") {
        UIApplication.shared.open(url)
    }
}

private func openTerms() {
    if let url = URL(string: "https://www.termsfeed.com/live/8396044f-ea95-4e53-b354-98f027e72ab2") {
        UIApplication.shared.open(url)
    }
}

private func rateApp() {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        SKStoreReviewController.requestReview(in: windowScene)
    }
}

