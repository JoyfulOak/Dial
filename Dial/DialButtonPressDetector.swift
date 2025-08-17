// DialButtonPressDetector.swift
import Foundation
import Defaults
import AppKit

final class DialButtonPressDetector {
    static let shared = DialButtonPressDetector()

        private var longPressWorkItem: DispatchWorkItem?
        private let longPressThreshold: TimeInterval = 0.6

        func handlePressDown() {
            cancelPending()
            let work = DispatchWorkItem { [weak self] in
                DispatchQueue.main.async {
                    if MiniControllerPicker.shared.isVisible {
                        // Confirm current selection
                        MiniControllerPicker.shared.confirm()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            if let first = Defaults[.activatedControllerIDs].first {
                                Defaults[.currentControllerID] = first
                            }
                            if MiniControllerPicker.shared.isVisible {
                                MiniControllerPicker.shared.close()
                            }
                            ControllerPicker.open(with: Defaults[.activatedControllerIDs])
                        }
                        return
                    }
                    if let first = Defaults[.activatedControllerIDs].first {
                        Defaults[.currentControllerID] = first
                    }
                    if MiniControllerPicker.shared.isVisible {
                        MiniControllerPicker.shared.close()
                    }
                    ControllerPicker.open(with: Defaults[.activatedControllerIDs])
                }
                // mark as "consumed" so release won't treat it as short-press
                self?.longPressWorkItem = nil
            }
            longPressWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + longPressThreshold, execute: work)
        }

        func handlePressRelease() {
            // If there's still a pending work item, duration < threshold => NOT a long press.
            let wasShortPress = (longPressWorkItem != nil)
            cancelPending()
            if wasShortPress {
                ControllerPicker.closeIfOpen()
            }
        }

        private func cancelPending() {
            longPressWorkItem?.cancel()
            longPressWorkItem = nil
        }
    }

