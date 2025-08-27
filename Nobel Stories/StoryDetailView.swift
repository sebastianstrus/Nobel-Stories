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
    @State private var showAlert = false
    @State private var showStars = false
    @State private var alertMessage = ""
    @State private var incorrectAnswersCount: Int = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.9),
                    Color.blue.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    Text(story.title)
                        .font(.custom("ChalkboardSE-Regular", size: 24))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                        
                    
                    Text(story.text)
                        .font(.custom("ChalkboardSE-Regular", size: 22))
                        .padding()
                        .cornerRadius(15)
                        .padding()
                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 80 : 0)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(story.questions) { question in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("❓ \(question.question)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                
                                ForEach(question.options, id: \.self) { option in
                                    Button(action: {
                                        // Update the selected answer without checking immediately
                                        selectedAnswers[question.question] = option
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
                    
                    // The new "Check Answers" button
                    Button(action: {
                        checkAnswers()
                    }) {
                        Text("Check Answers")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 20)
            }
            .onDisappear {
                AudioManager.shared.stopSound()
            }
            
            if showStars {
                BigStarBurstView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    AudioManager.shared.playSound(storyId: story.id)
                }) {
                    Image(systemName: "play.circle.fill")
//                            .font(.title2)
                        .glassEffect()
//                        .foregroundColor(.white)
//                            .padding()
                }
                
                
//                NavigationLink(destination: SettingsView()) {
//                    Image(systemName: "play.circle.fill")
////                            .font(.title2)
//                        .glassEffect()
//                        .foregroundColor(.white)
////                            .padding()
//                }
            }
            
        }
        .navigationTitle("Story".localized)
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func backgroundColor(for question: Question, option: String) -> Color {
        guard let selected = selectedAnswers[question.question] else {
            return .white.opacity(0.8)
        }
        
        // This logic is simplified since we only show feedback after the user taps "Check Answers"
        if selected == option {
            return .yellow.opacity(0.4) // Highlight the selected option
        }
        
        return .white.opacity(0.8)
    }
    
    private func checkAnswers() {
        guard selectedAnswers.count == story.questions.count else {
            alertMessage = "Please answer all the questions."
            showAlert = true
            return
        }
        
        var incorrectCount = 0
        for question in story.questions {
            if selectedAnswers[question.question] != question.correct_answer {
                incorrectCount += 1
            }
        }
        
        if incorrectCount == 0 {
            viewModel.markStoryAsSolved(id: story.id)
            showStars = true
            
            SoundManager.shared.playSound(named: "stars", withExtension: "m4a")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showStars = false
            }
        } else {
            alertMessage = "You had \(incorrectCount) incorrect answer\(incorrectCount > 1 ? "s" : ""). Please try again."
            
            showAlert = true
        }
        
    }
}



struct BigStarBurstView: View {
    struct Star: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
        var rotation: Angle
        var delay: Double
    }

    @State private var stars: [Star] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(stars) { star in
                    Image(systemName: "sparkle")
                        .foregroundColor(.yellow)
                        .opacity(star.opacity)
                        .scaleEffect(star.scale)
                        .rotationEffect(star.rotation)
                        .position(x: star.x, y: star.y)
                        .onAppear {
                            withAnimation(
                                .easeOut(duration: 2.0)
                                .delay(star.delay)
                            ) {
                                moveStarAway(index: star.id, in: geo.size)
                            }
                        }
                }
            }
            .onAppear {
                generateStars(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }

    private func generateStars(in size: CGSize) {
        stars = (0..<80).map { _ in
            let scale = UIDevice.current.userInterfaceIdiom == .pad ? Double.random(in: 6...12) : Double.random(in: 3...6)
            return Star(
                x: size.width / 2,
                y: size.height / 2,
                scale: scale,
                opacity: 1.0,
                rotation: .degrees(Double.random(in: 0...360)),
                delay: Double.random(in: 0...0.2)
            )
        }
    }

    private func moveStarAway(index id: UUID, in size: CGSize) {
        let radius: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1000 : 500
        if let index = stars.firstIndex(where: { $0.id == id }) {
            let angle = Double.random(in: 0...360) * .pi / 180
            let radius: CGFloat = CGFloat.random(in: 50...(radius))
            stars[index].x += cos(angle) * radius
            stars[index].y += sin(angle) * radius
            stars[index].scale = 0.1
            stars[index].opacity = 0
        }
    }
}
