//
//  QuizSessionView.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import SwiftUI

struct QuizSessionView: View {
    @ObservedObject var viewModel: QuizSessionViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var scoreText: String {
        let total = max(viewModel.cards.count, 1)
        let percent = Int((Double(viewModel.correctCount) / Double(total)) * 100)
        return "\(percent)%"
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            if let card = viewModel.currentCard, !viewModel.isCompleted {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Quiz")
                            .font(.headline)
                            .foregroundColor(.flashAccent)
                        
                        Text(viewModel.questionNumberText)
                            .font(.caption)
                            .foregroundColor(.flashAccent)
                    }
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient.flashCardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.flashAccent, lineWidth: 3)
                        )
                        .frame(maxWidth: .infinity, minHeight: 160, maxHeight: 200)
                        .overlay(
                            Text(card.frontText)
                                .font(.title2)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding()
                        )
                        .padding(.horizontal, 24)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    
                    VStack(spacing: 12) {
                        ForEach(viewModel.options, id: \.self) { option in
                            quizOptionButton(option: option)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    Button {
                        viewModel.goToNext()
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient.flashAccentBackground)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    .disabled(viewModel.selectedOption == nil)
                    .opacity(viewModel.selectedOption == nil ? 0.4 : 1.0)
                }
            } else {
                VStack(spacing: 24) {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(LinearGradient.flashCardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.flashAccent, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 8)
                        .overlay(
                            VStack(spacing: 20) {
                                Image(systemName: "rosette")
                                    .font(.system(size: 40))
                                    .foregroundColor(.flashAccent)
                                
                                Text("Quiz completed")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                VStack(spacing: 4) {
                                    Text(scoreText)
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.flashAccent)
                                    
                                    Text("Correct answers: \(viewModel.correctCount) of \(viewModel.cards.count)")
                                        .font(.subheadline)
                                        .foregroundColor(.flashAccent)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 32)
                                }
                            }
                            .padding(24)
                        )
                        .padding(.horizontal, 24)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Back to cards")
                            .font(.headline)
                            .foregroundColor(.flashAccent)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.flashAccent, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.flashAccent)
    }
    
    private func quizOptionButton(option: String) -> some View {
        let isSelected = viewModel.selectedOption == option
        let isCorrect = option == viewModel.correctAnswer
        let answered = viewModel.selectedOption != nil
        
        let backgroundColor: Color
        let foregroundColor: Color
        let borderWidth: CGFloat
        
        if answered {
            if isCorrect {
                backgroundColor = .flashAccent
                foregroundColor = .white
                borderWidth = 0
            } else if isSelected {
                backgroundColor = .white
                foregroundColor = .flashAccent
                borderWidth = 2
            } else {
                backgroundColor = .white
                foregroundColor = .flashAccent
                borderWidth = 1
            }
        } else {
            backgroundColor = .white
            foregroundColor = .flashAccent
            borderWidth = 1
        }
        
        return Button {
            viewModel.selectOption(option)
        } label: {
            Text(option)
                .font(.subheadline)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.flashAccent, lineWidth: borderWidth)
                        )
                )
        }
        .disabled(answered)
    }
}

