//
//  ContentView.swift
//  Matematik2
//
//  Created by Sebastian Strus on 2025-02-04.
//

import SwiftUI
import AVFoundation

struct LearnView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    // Timer related state variables
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    // Completion tracking
    @State private var additionCompleted = false
    @State private var subtractionCompleted = false
    @State private var multiplicationCompleted = false
    @State private var divisionCompleted = false
    
    @State private var additionHasProgress = false
    @State private var subtractionHasProgress = false
    @State private var multiplicationHasProgress = false
    @State private var divisionHasProgress = false
    
    // UI state
    @State private var showBackConfirmation = false
    @State private var shouldShowNameAlert = false
    @State private var showingVictoryView = false
    @State private var userName = ""
    @State private var selectedTab = 0
    
    @State private var showSubscriptionSheet = false
    
    var body: some View {
        ZStack {
            // Main content
            if showingVictoryView || shouldShowVoctoryView() {
                VictoryView(elapsedTime: elapsedTime)
                    .environmentObject(settings)
            } else {
                TabView(selection: $selectedTab) {
                    if settings.isAdditionOn {
                        MathView(operation: .addition,
                                 isCompleted: $additionCompleted,
                                 hasProgress: $additionHasProgress,
                                 settings: settings)
                        .tabItem {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Circle().fill(Color.orange))
                                Text("Addition".localized)
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .tag(0)
                    }
                    
                    if settings.isSubtractionOn {
                        MathView(operation: .subtraction,
                                 isCompleted: $subtractionCompleted,
                                 hasProgress: $subtractionHasProgress,
                                 settings: settings)
                        .tabItem { Label("Subtraction".localized, systemImage: "minus") }
                        .badge(!purchaseManager.hasUnlockedPro ? "PRO" : nil)
                        .tag(1)
                    }
                    
                    if settings.isMultiplicationOn {
                        MathView(operation: .multiplication,
                                 isCompleted: $multiplicationCompleted,
                                 hasProgress: $multiplicationHasProgress,
                                 settings: settings)
                        .tabItem { Label("Multiplication".localized, systemImage: "multiply") }
                        .badge(!purchaseManager.hasUnlockedPro ? "PRO" : nil)
                        .tag(2)
                    }
                    
                    if settings.isDivisionOn {
                        MathView(operation: .division,
                                 isCompleted: $divisionCompleted,
                                 hasProgress: $divisionHasProgress,
                                 settings: settings)
                        .tabItem { Label("Division".localized, systemImage: "divide") }
                        .badge(!purchaseManager.hasUnlockedPro ? "PRO" : nil)
                        .tag(3)
                        
                    }
                }
                .onChange(of: selectedTab) { oldTab, newTab in
                    if newTab > 0 && !purchaseManager.hasUnlockedPro {
                        selectedTab = 0
                        showSubscriptionSheet = true
                    }
                }
                .sheet(isPresented: $showSubscriptionSheet) {
                    SubscriptionView()
                }
                .onChange(of: purchaseManager.hasUnlockedPro) { _, newValue in
                    if newValue {
                        showSubscriptionSheet = false
                    }
                }

                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            let hasProgress = additionHasProgress || subtractionHasProgress ||
                            multiplicationHasProgress || divisionHasProgress
                            
                            if hasProgress {
                                showBackConfirmation = true
                            } else {
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .flipsForRightToLeftLayoutDirection(true)
                                Text("Back".localized)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    if purchaseManager.hasUnlockedPro {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Text(elapsedTime.formattedTimeWithMilliseconds)
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 16,
                                              weight: .bold,
                                              design: .monospaced))
                                .foregroundColor(.blue.opacity(settings.isTimerOn ? 1 : 0))
                        }
                    } else {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                showSubscriptionSheet = true
                            } label: {
                                Text("Try Premium".localized)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: .purple.opacity(0.4), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .alert("Congratulations!".localized + "\n" + elapsedTime.formattedTime, isPresented: $shouldShowNameAlert) {
            TextField("Nickname".localized, text: $userName)
            Button("Save".localized) {
                saveResultAndShowVictory()
            }
            Button("Skip".localized, role: .cancel) {
                showingVictoryView = true
            }
        } message: {
            Text("Enter your nickname to save the result".localized)
        }
        .onChange(of: shouldShowVoctoryView()) { completed in
            if completed {
                stopTimer()
                showingVictoryView = true
                
                // Only show the name alert if ALL operations are enabled
                let allOperationsEnabled =
                settings.isAdditionOn &&
                settings.isSubtractionOn &&
                settings.isMultiplicationOn &&
                settings.isDivisionOn
                
                if allOperationsEnabled {
                    shouldShowNameAlert = true
                }
            }
        }
        .overlay {
            if showBackConfirmation {
                ZStack {
                    // Dimmed background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // Optional: tap outside to dismiss
                            showBackConfirmation = false
                        }

                    // Alert box
                    VStack(spacing: 0) {
                        Text("Are you sure?".localized)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)

                        Text("Your progress will be lost if you go back.".localized)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 4)

                        Divider()
                            .padding(.top, 20)

                        Button {
                            SoundManager.shared.stopSound()
                            dismiss()
                        } label: {
                            Text("Discard Changes".localized)
                                .foregroundColor(Color(UIColor.systemRed))
                                .font(.body)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        
                        Divider()

                            Button {
                                showBackConfirmation = false
                            } label: {
                                Text("Cancel".localized)
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(.accentColor)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }

                            
                        
                    }
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .frame(maxWidth: 320)
                    .shadow(radius: 20)
                    .padding()
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: showBackConfirmation)
            }
        }
    }
    
    private func saveResultAndShowVictory() {
        let difficulty = DifficultyLevel(rawValue: settings.difficultyLevel) ?? .medium
        settings.saveGameResult(
            name: userName.isEmpty ? "Anonymous" : userName,
            difficulty: difficulty,
            exampleCount: settings.exampleCount,
            time: elapsedTime
        )
    }
    
    private func startTimer() {
        guard startTime == nil else { return }
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let startTime = startTime {
                elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func shouldShowVoctoryView() -> Bool {
        let tabsEnabledCount: Int = [settings.isAdditionOn,
                                     settings.isSubtractionOn,
                                     settings.isMultiplicationOn,
                                     settings.isDivisionOn].filter { $0 }.count
        
        let tabsCompletedCount: Int = [additionCompleted,
                                       subtractionCompleted,
                                       multiplicationCompleted,
                                       divisionCompleted].filter { $0 }.count
        
        return tabsEnabledCount == tabsCompletedCount
    }
}


enum MathOperation {
    case addition, subtraction, multiplication, division
}

struct MathProblem: Identifiable {
    let id = UUID()
    let left: Int
    let right: Int
    let operation: MathOperation
    var userAnswer: String = ""
    
    var correctAnswer: Int {
        switch operation {
        case .addition: return left + right
        case .subtraction: return left - right
        case .multiplication: return left * right
        case .division: return right != 0 ? left / right : 1
        }
    }
    
    var isSolved: Bool = false
}

struct VictoryView: View {
    @EnvironmentObject var settings: SettingsManager
    let elapsedTime: TimeInterval
    let fontSize: CGFloat = {
        UIDevice.current.userInterfaceIdiom == .pad ? 50 : 25
    }()
    
    var body: some View {
        
        let allOperationsEnabled =
        settings.isAdditionOn &&
        settings.isSubtractionOn &&
        settings.isMultiplicationOn &&
        settings.isDivisionOn
        
        ZStack {
            FallingCoinsView()
            
            if !allOperationsEnabled {
                VStack {
                    Text("Congratulations!\nYou won!".localized)
                        .font(.system(size: fontSize, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    
                    Text("Time:".localized)
                        .font(.system(size: fontSize * 0.7, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(elapsedTime.formattedTimeWithMilliseconds)
                    
                        .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text("You need to complete addition, subtraction, multiplication, and division in order to save the result.".localized)
                        .font(.system(size: fontSize * 0.5, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(40)
                    
                }
            }
            
        }
    }
}




struct MathView: View {
    
    let hintFontSize: CGFloat = {
        UIDevice.current.userInterfaceIdiom == .pad ? 22 : 12
    }()
    
    let lineWidth: CGFloat = {
        UIDevice.current.userInterfaceIdiom == .pad ? 10 : 5
    }()
    
    let fieldWidth: CGFloat = {
        UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30
    }()
    
    let fieldHeight: CGFloat = {
        UIDevice.current.userInterfaceIdiom == .pad ? 34 : 20
    }()
    
    let spacing: CGFloat = {
        UIDevice.current.userInterfaceIdiom == .pad ? 14 : 12
    }()
    
    let cornerRadius: CGFloat = {
        UIDevice.current.userInterfaceIdiom == .pad ? 5 : 3
    }()
    
    let fieldLineWidth: CGFloat = {
        UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1
    }()
    
    var settings: SettingsManager
    let operation: MathOperation
    @State private var problems: [MathProblem] = []
    private static var recentProblems = [MathProblem]()
    @State private var showStars = false
    @Binding var isCompleted: Bool
    @Binding var hasProgress: Bool
    
    init(operation: MathOperation, isCompleted: Binding<Bool>, hasProgress: Binding<Bool>, settings: SettingsManager) {
        self.operation = operation
        self._isCompleted = isCompleted
        self._hasProgress = hasProgress
        self.settings = settings
        _problems = State(initialValue: Self.generateProblems(for: operation, settings: settings))
    }
    
    
    var body: some View {
        VStack {
            Text("").frame(height: 0)
            
            ZStack {
                ScrollView {
                    Text("").frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 10)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: spacing) {
                        ForEach(problems.indices, id: \.self) { index in
                            MathProblemRow(
                                problem: $problems[index],
                                symbol: symbol,
                                hintFontSize: hintFontSize,
                                fieldWidth: fieldWidth,
                                fieldHeight: fieldHeight,
                                cornerRadius: cornerRadius,
                                fieldLineWidth: fieldLineWidth
                            ) {
                                updateBorderColors()
                                checkCompletion()
                                if !hasProgress {
                                    checkProgress()
                                }
                            }
                        }
                    }
                    .padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? 16 : 12)
                }
                
                if showStars {
                    BigStarBurstView()
                }
            }
            .navigationTitle(title)
        }
        .padding(.trailing, UIScreen.main.bounds.width > 1000 ? 60 : 0)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onChange(of: isCompleted, { oldValue, newValue in
            if newValue {
                if SettingsManager.shared.isSparkleStarsOn {
                    showStars = true
                    SoundManager.shared.playSound(named: "stars", withExtension: "m4a")
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showStars = false
                }
            }
        })
    }
    
    func updateBorderColors() {
        for i in stride(from: 0, to: problems.count, by: 3) {
            if i + 2 < problems.count {
                let allCorrect = (0...2).allSatisfy { offset in
                    let index = i + offset
                    return Int(problems[index].userAnswer.replacingOccurrences(of: " ", with: "")) == problems[index].correctAnswer
                }
                
                for offset in 0...2 {
                    let index = i + offset
                    problems[index].isSolved = allCorrect
                }
            }
        }
    }
    
    static func generateProblems(for operation: MathOperation, settings: SettingsManager) -> [MathProblem] {
        let count = settings.exampleCount
        var newProblems: [MathProblem] = []
        
        while newProblems.count < count {
            let candidate = generateSingleProblem(for: operation, settings: settings)
            
            let itContains: Bool = MathView.recentProblems.contains { problem in
                problem.left == candidate.left && problem.right == candidate.right && problem.operation == candidate.operation
            }
            
            if !itContains {
                newProblems.append(candidate)
                MathView.recentProblems.append(candidate)
                if MathView.recentProblems.count > 9 {
                    MathView.recentProblems.removeFirst()
                }
            }
        }
        
        return newProblems
    }

    
    static func generateSingleProblem(for operation: MathOperation, settings: SettingsManager) -> MathProblem {
        var left = 1
        var right = 1

        switch operation {
        case .addition:
            switch settings.difficultyLevel {
            case 0: left = Int.random(in: 1...10); right = Int.random(in: 1...10)
            case 1: left = Int.random(in: 1...20); right = Int.random(in: 1...20)
            default: left = Int.random(in: 9...50); right = Int.random(in: 9...50)
            }

        case .subtraction:
            repeat {
                switch settings.difficultyLevel {
                case 0: left = Int.random(in: 2...20); right = Int.random(in: 1..<left)
                case 1: left = Int.random(in: 2...49); right = Int.random(in: 1..<left)
                default: left = Int.random(in: 10...99); right = Int.random(in: 9..<left)
                }
            } while left <= right

        case .multiplication:
            repeat {
                switch settings.difficultyLevel {
                case 0: left = Int.random(in: 1...6); right = Int.random(in: 1...6)
                case 1: left = Int.random(in: 1...10); right = Int.random(in: 1...10)
                default: left = Int.random(in: 2...50); right = Int.random(in: 2...50)
                }
            } while left * right > 100

        case .division:
            repeat {
                switch settings.difficultyLevel {
                case 0: right = Int.random(in: 1...5); left = right * Int.random(in: 1...5)
                case 1: right = Int.random(in: 2...7); left = right * Int.random(in: 2...8)
                default: right = Int.random(in: 2...9); left = right * Int.random(in: 2...10)
                }
            } while left / right <= 0
        }

        return MathProblem(left: left, right: right, operation: operation)
    }

    
    
    var title: String {
        switch operation {
        case .addition: return "Addition"
        case .subtraction: return "Subtraction"
        case .multiplication: return "Multiplication"
        case .division: return "Division"
        }
    }
    
    var symbol: String {
        switch operation {
        case .addition: return "+"
        case .subtraction: return "-"
        case .multiplication: return "×"
        case .division: return "÷"
        }
    }
    
    private func checkCompletion() {
        if problems.allSatisfy({ Int($0.userAnswer.replacingOccurrences(of: " ", with: "")) == $0.correctAnswer }) {
            isCompleted = true
        } else {
            isCompleted = false
        }
    }
    
    private func checkProgress() {
        hasProgress = problems.contains(where: { Int($0.userAnswer.replacingOccurrences(of: " ", with: "")) == $0.correctAnswer })
    }
}



struct MathProblemRow: View {
    @Binding var problem: MathProblem
    @State private var showStars = false
    let symbol: String
    let hintFontSize: CGFloat
    let fieldWidth: CGFloat
    let fieldHeight: CGFloat
    let cornerRadius: CGFloat
    let fieldLineWidth: CGFloat
    let onUserAnswerChanged: () -> Void

    @State private var animateSolved = false

    var body: some View {
        HStack {
            
                
                
                Spacer(minLength: 0)
                Text("\(problem.left) \(symbol) \(problem.right) =")
                    .font(.system(size: hintFontSize, weight: .bold, design: .rounded))
                
            ZStack {
                
                
                TextField("?", text: Binding(
                    get: { problem.userAnswer },
                    set: { newValue in
                        problem.userAnswer = newValue
                        onUserAnswerChanged()
                    }
                ))
                .font(.system(size: hintFontSize, weight: .bold, design: .rounded))
                .keyboardType(.numberPad)
                .frame(width: fieldWidth, height: fieldHeight)
                .multilineTextAlignment(.center)
                .padding(UIDevice.current.userInterfaceIdiom == .pad ? 16 : 4)
                .background((problem.isSolved ? Color.green : Color.gray).opacity(0.3))
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(problem.isSolved ? Color.green : Color.gray, lineWidth: fieldLineWidth)
                )
                .disabled(problem.isSolved)
                
                if showStars {
                    StarBurstView()
                        .frame(width: fieldWidth, height: fieldHeight)
                }
            }
                
            }
            
            
        
        .padding(UIDevice.current.userInterfaceIdiom == .pad ? 16 : 4)
        .onChange(of: problem.isSolved, { oldValue, newValue in
            if newValue {
                if SettingsManager.shared.isSparkleStarsOn {
                    showStars = true
                    SoundManager.shared.playSound(named: "stars", withExtension: "m4a")
                }
                
            
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    showStars = false
                }
            }
        })

    }
}


struct StarBurstView: View {
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
                                .easeOut(duration: 1.0)
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
        stars = (0..<12).map { _ in
            let scale = UIDevice.current.userInterfaceIdiom == .pad ? Double.random(in: 1.2...2.4) : Double.random(in: 0.6...1.2)
            return Star(
                x: size.width / 2,
                y: size.height / 2,
                scale: scale,
                opacity: 1.0,
                rotation: .degrees(Double.random(in: 0...360)),
                delay: Double.random(in: 0...0.1)
            )
        }
    }

    private func moveStarAway(index id: UUID, in size: CGSize) {
        let radius: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 200 : 100
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
