//
//  StudySessionView.swift
//  89FlashCard
//
//  Created by Roman Guravei on 10.02.2026.
//

import SwiftUI

struct StudySessionView: View {
    @ObservedObject var viewModel: StudySessionViewModel
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            if let card = viewModel.currentCard, !viewModel.isCompleted {
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Study session")
                            .font(.headline)
                            .foregroundColor(.flashAccent)
                        
                        Text("Card \(viewModel.currentIndex + 1) of \(viewModel.cards.count)")
                            .font(.caption)
                            .foregroundColor(.flashAccent)
                    }
                    
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
                                Text(card.frontText)
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
                                Text(card.backText)
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
                    
                    VStack(spacing: 12) {
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
                                    .background(LinearGradient.flashAccentBackground)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Text("Tap a button to move to the next card.")
                            .font(.caption)
                            .foregroundColor(.flashAccent)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            } else {
                VStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(LinearGradient.flashCardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.flashAccent, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 8)
                        .overlay(
                            VStack(spacing: 16) {
                                Text("Session completed")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Text("Great job! You went through all selected cards.")
                                    .font(.subheadline)
                                    .foregroundColor(.flashAccent)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                            .padding(24)
                        )
                        .padding(.horizontal, 24)
                }
            }
        }
        .navigationTitle("Study")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.flashAccent)
    }
}

