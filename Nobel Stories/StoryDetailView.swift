//
//  StoryDetailView.swift
//  Nobel Stories
//
//  Created by Sebastian Strus on 8/26/25.
//
import SwiftUI

struct StoryDetailView: View {
    let story: Story
    
    @ObservedObject var viewModel: StoryListViewModel
    
    @State private var selectedAnswers: [String: String] = [:]
    @State private var showAlert = false
    @State private var showStars = false
    @State private var alertMessage = ""
    @State private var incorrectAnswersCount: Int = 0
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .blur(radius: 50)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    Text(story.title)
                    
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundColor(.pink)
                        .frame(maxWidth: .infinity, alignment: .center)
//                        .padding(.top, 8)
                        .padding(.horizontal)
                    
                    Text(story.text)
                        .font(.custom("ChalkboardSE-Regular", size: 24))
                        .foregroundColor(.black)
//                        .font(.system(size: 24, weight: .regular, design: .rounded))
                        .padding(40)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white.opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.black, lineWidth: 4)
                                )
                        )
                        .padding()
                    
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(Array(story.questions.enumerated()), id: \.element.id) { index, question in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("\(index + 1). \(question.question)")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                
                                ForEach(question.options, id: \.self) { option in
                                    Button(action: {
                                        selectedAnswers[question.question] = option
                                    }) {
                                        Text(option)
                                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                                            .frame(maxWidth: .infinity)
                                            .padding(15)
                                            .background(backgroundColor(for: question, option: option))
                                            .foregroundColor(.black)
                                            .cornerRadius(25)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 25)
                                                    .stroke(Color.black, lineWidth: 4)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    
                    Button(action: {
                        checkAnswers()
                    }) {
                        Text("Check Answers")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.black, lineWidth: 4)
                                    )
                            )
                            .foregroundColor(.green)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 0)

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
//                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .glassEffect()
                        .foregroundColor(.primary)
                    
                    
                }
            }
        }
//        .navigationTitle("Story")
//        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func backgroundColor(for question: Question, option: String) -> Color {
        guard let selected = selectedAnswers[question.question] else {
            return .white.opacity(0.8)
        }
        
        if selected == option {
            return .yellow.opacity(0.4)
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



import SwiftUI

struct BigStarBurstView: View {
    struct Star: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
        var rotation: Angle
        var delay: Double
        var animal: String
    }

    @State private var stars: [Star] = []

    // 👇 Colorful emoji animals
    private let animals = [
        "🐢","🐇","🐞","🐟","🐦","🐱","🐶","🦆","🐘",
        "🐻","🐸","🐄","🐴","🦁","🦦","🐌","🦉","🦋",
        "🦊","🦒","🐬","🐙","🦜","🦔"
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(stars) { star in
                    Text(star.animal)
                        .font(.system(size: star.scale)) // 👈 scale with font size
                        .opacity(star.opacity)
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
            // 👇 Big on iPad, smaller on iPhone — but still random
            let scale = UIDevice.current.userInterfaceIdiom == .pad
                ? Double.random(in: 60...120) // larger emoji
                : Double.random(in: 40...80) // smaller emoji

            return Star(
                x: size.width / 2,
                y: size.height / 2,
                scale: scale,
                opacity: 1.0,
                rotation: .degrees(Double.random(in: 0...360)),
                delay: Double.random(in: 0...0.2),
                animal: animals.randomElement()!
            )
        }
    }

    private func moveStarAway(index id: UUID, in size: CGSize) {
        let maxRadius: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1000 : 500
        if let index = stars.firstIndex(where: { $0.id == id }) {
            let angle = Double.random(in: 0...360) * .pi / 180
            let radius: CGFloat = CGFloat.random(in: 50...maxRadius)
            stars[index].x += cos(angle) * radius
            stars[index].y += sin(angle) * radius
            stars[index].scale = 0.5 // shrink as it fades
        }
    }
}
