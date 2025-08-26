//
//  StoryViewModel.swift
//  Nobel Stories
//
//  Created by Sebastian Strus on 8/26/25.
//

import Foundation
import SwiftUI

// ViewModel for managing story data and state
class StoryViewModel: ObservableObject {
    @Published var stories: [Story] = []
    
    // A string to store the solved story IDs as a comma-separated list
    @AppStorage("solved_story_ids") private var solvedStoriesString: String = ""
    
    // Computed property to get the solved story IDs as a Set for efficient lookup
    var solvedStories: Set<String> {
        get {
            Set(solvedStoriesString.components(separatedBy: ",").filter { !$0.isEmpty })
        }
        set {
            solvedStoriesString = newValue.joined(separator: ",")
        }
    }
    
    // MARK: - Initializer
    init() {
        loadStories()
    }
    
    // MARK: - Data Loading
    private func loadStories() {
        if let url = Bundle.main.url(forResource: "stories", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decodedList = try JSONDecoder().decode(StoryList.self, from: data)
                self.stories = decodedList.stories
            } catch {
                print("Error loading or decoding JSON: \(error)")
            }
        }
    }
    
    // MARK: - UserDefault Handling
    func markStoryAsSolved(id: String) {
        var currentSolved = self.solvedStories
        currentSolved.insert(id)
        self.solvedStories = currentSolved
    }
}
