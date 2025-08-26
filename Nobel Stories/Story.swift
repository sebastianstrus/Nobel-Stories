//
//  Story.swift
//  Nobel Stories
//
//  Created by Sebastian Strus on 8/26/25.
//

import Foundation

// MARK: - Top-level container for the stories
struct StoryList: Decodable {
    let stories: [Story]
}

// MARK: - Story Model
struct Story: Identifiable, Decodable {
    let id: String
    let title: String
    let text: String
    let questions: [Question]
}

// MARK: - Question Model
struct Question: Identifiable, Decodable {
    let id = UUID() // Use UUID for unique identification within a list
    let question: String
    let options: [String]
    let correct_answer: String
    
    // CodingKeys to match the JSON keys
    enum CodingKeys: String, CodingKey {
        case question
        case options
        case correct_answer
    }
}
