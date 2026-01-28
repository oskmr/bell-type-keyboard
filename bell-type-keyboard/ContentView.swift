//
//  ContentView.swift
//  bell-type-keyboard
//
//  Created by miseri.osaka on 2026/01/29.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(RetroTheme.bodyBackground)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(RetroTheme.displayTextDim)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(RetroTheme.displayTextDim),
            .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .medium)
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(RetroTheme.accentGreen)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(RetroTheme.accentGreen),
            .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .bold)
        ]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            OnboardingView()
                .tabItem {
                    Label("SETUP", systemImage: "gearshape.fill")
                }

            KeyMapView()
                .tabItem {
                    Label("KEYMAP", systemImage: "number.square.fill")
                }

            DemoView()
                .tabItem {
                    Label("DEMO", systemImage: "keyboard.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
