//
//  StoryDetailView.swift
//  Nobel Stories
//
//  Created by Sebastian Strus on 8/26/25.
//

import SwiftUI

struct StoryDetailView: View {
    let story: Story
    @ObservedObject var viewModel: StoryViewModel
    
    @State private var selectedAnswers: [String: String] = [:]
    
    // Computed property to check if all questions are answered correctly
    private var allQuestionsCorrect: Bool {
        story.questions.allSatisfy { question in
            selectedAnswers[question.question] == question.correct_answer
        }
    }
    
    var body: some View {
        ZStack {
            // Background with a subtle gradient
            LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // Play Button with Kid-Friendly Design
                    Button(action: {
                        // Play audio
                        print("Play button tapped for \(story.title)")
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.largeTitle)
                            Text("Listen to the Story")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    
                    // Story Text
                    Text(story.text)
                        .font(.body)
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(15)
                    
                    // Questions Section
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(story.questions) { question in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("❓ \(question.question)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                
                                ForEach(question.options, id: \.self) { option in
                                    Button(action: {
                                        selectedAnswers[question.question] = option
                                        checkAnswers()
                                    }) {
                                        Text(option)
                                            .font(.subheadline)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(backgroundColor(for: question, option: option))
                                            .foregroundColor(.primary)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(story.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func backgroundColor(for question: Question, option: String) -> Color {
        guard let selected = selectedAnswers[question.question] else { return .white.opacity(0.8) }
        
        if selected == option {
            return option == question.correct_answer ? .green.opacity(0.4) : .red.opacity(0.4)
        } else if selected != question.correct_answer && option == question.correct_answer {
            // This case highlights the correct answer after the user selects an incorrect one
            return .green.opacity(0.4)
        }
        
        return .white.opacity(0.8)
    }
    
    private func checkAnswers() {
        if selectedAnswers.count == story.questions.count {
            if allQuestionsCorrect {
                viewModel.markStoryAsSolved(id: story.id)
                print("All questions answered correctly. Story \(story.id) is solved! 🎉")
            } else {
                print("Incorrect answers. Try again.")
            }
        }
    }
}
