//
//  StoryListView.swift
//  Nobel Stories
//
//  Created by Sebastian Strus on 8/26/25.
//

//import SwiftUI
//
//struct StoryListView: View {
//    @StateObject private var viewModel = StoryListViewModel()
//    
//    var body: some View {
//        ZStack {
//            // Background with a subtle gradient
//            LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.3), Color.blue.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
//                .edgesIgnoringSafeArea(.all)
//            
//            List {
//                ForEach(viewModel.stories) { story in
//                    NavigationLink(destination: StoryDetailView(story: story, viewModel: viewModel)) {
//                        HStack(spacing: 15) {
//                            // Story icon
//                            Image(systemName: "book.fill")
//                                .font(.system(size: 28))
//                                .foregroundColor(.purple)
//                            
//                            Text(story.title)
//                                .font(.title3)
//                                .fontWeight(.bold)
//                            
//                            Spacer()
//                            
//                            if viewModel.solvedStories.contains(story.id) {
//                                Image(systemName: "sparkles")
//                                    .font(.system(size: 24))
//                                    .foregroundColor(.green)
//                            }
//                        }
//                        .padding(.vertical, 10)
//                    }
//                    .listRowBackground(Color.white.opacity(0.8))
//                    .listRowSeparator(.hidden)
//                }
//            }
//            .scrollContentBackground(.hidden)
//            .navigationTitle("Magic Stories 📚")
//        }
//    }
//}
import SwiftUI


struct StoryListView: View {
    @StateObject private var viewModel = StoryListViewModel()

    var body: some View {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 50)

                List {
                    ForEach(viewModel.stories) { story in
                        NavigationLink(destination: StoryDetailView(story: story, viewModel: viewModel)) {
                            CartoonStoryRow(story: story, isSolved: viewModel.solvedStories.contains(story.id))
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Story Time! 🎉")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundColor(.red)
            }
        
    }
}

struct CartoonStoryRow: View {
    let story: Story
    let isSolved: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "pencil.and.outline")
                .font(.system(size: 32))
                .foregroundColor(.blue)
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 3)
                )

            Text(story.id.dropFirst(6) + ". " +  story.title)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(.black)
                .padding(.horizontal)

            Spacer()

            if isSolved {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.yellow)
                    .padding(.trailing, 8)
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.black, lineWidth: 4)
                )
        )
    }
}
