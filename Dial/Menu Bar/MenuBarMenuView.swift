//
//  MenuBarMenuView.swift
//  Dial
//
//  Created by KrLite on 2024/3/24.
//

import SwiftUI
import SettingsAccess
import Defaults
import LaunchAtLogin

struct MenuBarMenuView: View {
    @State var isConnected: Bool = false
    @State var serial: String? = nil
    
    @Default(.activatedControllerIDs) var activatedControllerIDs
    @Default(.currentControllerID) var currentControllerID
    
    @Default(.globalHapticsEnabled) var globalHapticsEnabled
    @Default(.globalSensitivity) var globalSensitivity
    @Default(.globalDirection) var globalDirection
    
    @ObservedObject var startsWithMacOS = LaunchAtLogin.observable
    
    func possibleChar(from int: Int) -> Character? {
        return String(int).first
    }
    
    var body: some View {
        // MARK: - Status
        
        Button {
            // Nothing to do
        } label: {
            Text("Surface Dial")
            Image(systemSymbol: .hockeyPuck)
        }
        .disabled(true)
        .badge(Text(serial ?? ""))
        .orSomeView(condition: !isConnected) {
            Button {
                dial.connect()
            } label: {
                Image(systemSymbol: .arrowTriangle2Circlepath)
                Text("Surface Dial")
            }
            .badge(Text("disconnected"))
        }
        
        Divider()
        
        // MARK: - Controllers
        
        Button(action: {}) {
            Text("Controllers")
                .badge(Text("press and hold dial"))
        }
        .buttonStyle(.plain)
        .highPriorityGesture(
            LongPressGesture(minimumDuration: 0.7).onEnded { _ in
                SettingsWindowController.open()
            }
        )
        
        ForEach(Array($activatedControllerIDs.enumerated()), id: \.offset) { index, id in
            Toggle(isOn: id.isCurrent) {
                id.wrappedValue.controller.symbol.image
                Text(id.wrappedValue.controller.name ?? controllerNamePlaceholder)
            }
            .possibleKeyboardShortcut(
                possibleChar(from: index).map { KeyEquivalent.init($0) },
                modifiers: .option
            )
        }
        
        Divider()
        
        // MARK: - Quick Settings
        
        Text("Quick Settings")
        
        Toggle(isOn: $globalHapticsEnabled) {
            Text(.init(localized: .init("Menu: Haptics", defaultValue: "Haptic Feedback")))
        }
        
        HStack {
            Picker(selection: $globalSensitivity) {
                ForEach(Sensitivity.allCases) { sensitivity in
                    Label {
                        Text(sensitivity.title)
                    } icon: {
                        sensitivity.symbol.image
                    }
                }
            } label: {
                Text(.init(localized: .init("Menu: Sensitivity", defaultValue: "Sensitivity")))
            }
            globalSensitivity.symbol.image
        }
        
        HStack {
            Picker(selection: $globalDirection) {
                ForEach(Direction.allCases) { direction in
                    Label {
                        Text(direction.title)
                    } icon: {
                        direction.symbol.image
                    }
                }
            } label: {
                Text(.init(localized: .init("Menu: Direction", defaultValue: "Direction")))
            }
            globalDirection.symbol.image
        }
        
        Divider()
        
        // MARK: - More Settings
        
        Toggle(isOn: $startsWithMacOS.isEnabled) {
            Text(.init(localized: .init("Menu: Starts with macOS", defaultValue: "Starts with macOS")))
        }
        
        SettingsLink(
            label: {
                Text("Settings…")
            },
            preAction: {
                for window in NSApp.windows where window.toolbar?.items != nil {
                    window.close()
                }
            },
            postAction: {
                for window in NSApp.windows where window.toolbar?.items != nil {
                    window.orderFrontRegardless()
                    window.center()
                }
            }
        )
        .keyboardShortcut(",", modifiers: .command)
        
        Button("About \(Bundle.main.appName)…") {
            NSApp.setActivationPolicy(.regular)
            AboutViewController.open()
        }
        .keyboardShortcut("i", modifiers: .command)
        
        Divider()
        
        Button("Quit") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
        .task {
            // MARK: Update conenction status
            
            for await _ in observationTrackingStream({ dial.hardware.connectionStatus }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let connectionStatus = dial.hardware.connectionStatus
                    isConnected = connectionStatus.isConnected
                    
                    switch connectionStatus {
                    case .connected(let string):
                        serial = string
                    case .disconnected:
                        serial = nil
                    }
                }
            }
        }
    }
}

