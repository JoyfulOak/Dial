//
//  SettingsView.swift
//  Dial
//
//  Created by KrLite on 2024/3/20.
//

import SwiftUI
import SFSafeSymbols
import TipKit

struct SettingsView: View {
    enum Tab: String, Hashable, CaseIterable {
        case general = "general"
        case controllers = "controllers"
        case dialMenu = "dialMenu"
        case more = "more"
        
        @ViewBuilder
        var tabItemView: some View {
            Group {
                switch self {
                case .general:
                    Image(systemSymbol: .gear)
                    Text("General")
                case .controllers:
                    Image(systemSymbol: .dialHigh)
                    Text("Controllers")
                case .dialMenu:
                    Image(systemSymbol: .circleCircle)
                    Text("Dial Menu")
                case .more:
                    Image(systemSymbol: .curlybraces)
                    Text("More…")
                }
            }
        }
    }
    
    @State var selectedTab: Tab = .general
    
    var body: some View {
        ZStack {
            Group {
                TabView(selection: $selectedTab) {
                    GeneralSettingsView()
                        .tag(Tab.general)
                        .tabItem { Tab.general.tabItemView }
                        .frame(width: 450)
                        .fixedSize()
                    DummyView()
                        .tag(Tab.controllers)
                        .tabItem { Tab.controllers.tabItemView }
                    DialMenuSettingsView()
                        .tag(Tab.dialMenu)
                        .tabItem { Tab.dialMenu.tabItemView }
                        .frame(width: 450)
                    MoreSettingsView()
                        .tag(Tab.more)
                        .tabItem { Tab.more.tabItemView }
                        .frame(width: 450)
                        .fixedSize()
                }
                .opacity(selectedTab != .controllers ? 1 : 0)
                .allowsHitTesting(selectedTab != .controllers)
            }
            ControllersSettingsView()
                .opacity(selectedTab == .controllers ? 1 : 0)
                .allowsHitTesting(selectedTab == .controllers)
        }
        .task {
            // Tips tasks
#if DEBUG
            try? Tips.resetDatastore()
#endif
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
    }
}

extension SettingsView.Tab: Identifiable {
    var id: Self {
        self
    }
}
