//
//  SettingsView.swift
//  Matematik
//
//  Created by Sebastian Strus on 2025-04-27.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    

    
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showProgressAlert = false
    @State private var showCacheAlert = false
    @State private var showMailComposer = false
    @State private var showingLanguageHelp = false
    
    @State private var showSubscriptionSheet = false
    @State private var debugTappedCount = 0
    
    var statisticsSectionHeader: some View {
        HStack(spacing: 6) {
            Text("Statistics".localized)
            if !purchaseManager.hasUnlockedPro { ProBadge() }
            Spacer()
        }
    }
    
    var learningSectionHeader: some View {
        HStack(spacing: 6) {
            Text("Learning Settings".localized)
            if !purchaseManager.hasUnlockedPro { ProBadge() }
            Spacer()
        }
    }
    
    var learningSectionsSectionHeader: some View {
        HStack(spacing: 6) {
            Text("Learning Sections".localized)
            if !purchaseManager.hasUnlockedPro { ProBadge() }
            Spacer()
        }
    }
    
    var resetSectionHeader: some View {
        HStack(spacing: 6) {
            Text("Default Settings".localized)
            if !purchaseManager.hasUnlockedPro { ProBadge() }
            Spacer()
        }
    }
    
    var body: some View {
        VStack {
            Text("").frame(height: 0)
            List {
                
                if !purchaseManager.hasUnlockedPro {
                    Section {
                        Button {
                            showSubscriptionSheet = true
                        } label: {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "crown.fill")
                                            .foregroundColor(.white)
                                        Text("Try Premium".localized)
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text("Unlock all features".localized)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)
//                                .shadow(color: .orange.opacity(0.4), radius: 5, x: 0, y: 2)
                                Spacer()
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
                
                
                
                
                
                
                
                Section(header: Text("Appearance".localized)) {
                    Picker("Theme".localized, selection: Binding(
                        get: { settings.isDarkMode ? 1 : 0 },
                        set: { settings.isDarkMode = $0 == 1 }
                    )) {
                        Text("Light".localized).tag(0)
                        Text("Dark".localized).tag(1)
                    }
                    .pickerStyle(.segmented)
                }
                .onTapGesture {
                    debugTappedCount += 1
                    if (!purchaseManager.isFree && (debugTappedCount) > 50) {
                        purchaseManager.isFree = true
                    }
                }
                
                Section(header: Text("Language".localized)) {
                    NavigationLink(destination: EmptyView()) {
                        HStack {
                            Text("App Language".localized)
                            Spacer()
                            Text(settings.primaryLanguage.displayName)
                        }
                        .contentShape(Rectangle()) // makes entire row tappable
                        .onTapGesture {
                            settings.openAppLanguageSettings()
                        }
                    }
                    
                    
                }
                
                Section(header: Text("Let Us Know What You Think".localized)) {
                    Button("Share Feedback".localized) {
                        showMailComposer = true
                    }.foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
                
                Section(header: resetSectionHeader) {
                    Button("Reset Settings".localized) {
                        settings.resetSettings()
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }.disabled(!purchaseManager.hasUnlockedPro)
                
                //                Section(header: Text("Application Cache".localized)) {
                //                    Button("Reset & Exit".localized) {
                //                        showCacheAlert = true
                //                    }
                //                    .foregroundColor(.red)
                //                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Settings".localized)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .accentColor(.orange)
        
//        .navigationTitle("Settings".localized)
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionView()
        }
        .onChange(of: purchaseManager.hasUnlockedPro) { _, newValue in
            if newValue {
                showSubscriptionSheet = false
            }
        }
        .onChange(of: settings.isAdditionOn) {
            settings.updateEnabledTabsCount()
        }
        .onChange(of: settings.isSubtractionOn) {
            settings.updateEnabledTabsCount()
        }
        .onChange(of: settings.isMultiplicationOn) {
            settings.updateEnabledTabsCount()
        }
        .onChange(of: settings.isDivisionOn) {
            settings.updateEnabledTabsCount()
        }
        .alert("Are you sure you want to delete the application cache and close the app?".localized, isPresented: $showCacheAlert) {
            Button("Delete".localized, role: .destructive) {
                settings.clearUserDefaultsAndCloseApp()
            }
            Button("Cancel".localized, role: .cancel) { }
        } message: {
            Text("This action cannot be undone.".localized)
        }
        .sheet(isPresented: $showMailComposer) {
            if MFMailComposeViewController.canSendMail() {
                MailComposer(
                    isPresented: $showMailComposer,
                    screenshot: nil,
                    recipient: "feedback.nobelmath@gmail.com",
                    subject: "Nobel Stories Feedback"
                )
            } else {
                Text("Please configure Mail to send feedback.".localized)
            }
        }
        .background( GradientBackground().ignoresSafeArea().opacity(settings.isDarkMode ? 1.0 : 0.0))
        .scrollContentBackground(settings.isDarkMode ? .hidden : .visible)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: shareApp) {
                    Image(systemName: "square.and.arrow.up")
                        .accessibilityLabel("Share".localized)
                        .glassEffect()
                        .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                }
            }
        }
    }
    
    private func shareApp() {
        let text = "Check out Nobel Stories - a great math learning app!".localized
        let url = URL(string: "https://apps.apple.com/app/6745169341")!
        
        let activityViewController = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        
        // Safely get windowScene and rootViewController
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        // Configure for iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.popoverPresentationController?.sourceView = rootViewController.view
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: window.bounds.width / 2, y: window.bounds.height / 2, width: 0, height: 0)
            activityViewController.popoverPresentationController?.permittedArrowDirections = []
        }
        
        rootViewController.present(activityViewController, animated: true, completion: nil)
    }
    
}




//
//  StatisticsView.swift
//  Matematik
//
//  Created by Sebastian Strus on 2025-04-27.
//

//
//  StatisticsView.swift
//  Matematik
//
//  Created by Sebastian Strus on 2025-04-27.
//

import SwiftUI



struct ProBadge: View {
    var body: some View {
        Text("PRO")
            .font(.caption2.bold())
            .padding(4)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(4)
    }
}
