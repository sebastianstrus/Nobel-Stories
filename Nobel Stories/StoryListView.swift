//
//  StoryListView.swift
//  Nobel Stories
//
//  Created by Sebastian Strus on 8/26/25.
//

import SwiftUI

struct StoryListView: View {
    @StateObject private var viewModel = StoryViewModel()
    
    var body: some View {
//        NavigationStack {
            ZStack {
                // Background with a subtle gradient
                LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.3), Color.blue.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                List {
                    ForEach(viewModel.stories) { story in
                        NavigationLink(destination: StoryDetailView(story: story, viewModel: viewModel)) {
                            HStack(spacing: 15) {
                                // Story icon
                                Image(systemName: "book.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.purple)
                                
                                Text(story.title)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                if viewModel.solvedStories.contains(story.id) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 24))
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .listRowBackground(Color.white.opacity(0.8))
                        .listRowSeparator(.hidden)
                    }
                }
                .scrollContentBackground(.hidden) // Hides the default list background
                .navigationTitle("Magic Stories 📚")
            }
//        }
    }
}
