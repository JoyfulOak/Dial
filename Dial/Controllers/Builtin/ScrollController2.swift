//
//  ScrollController.swift
//  Dial
//
//  Created by KrLite on 2024/3/21.
//

import Foundation
import AppKit
import SFSafeSymbols
import Defaults
import CoreGraphics

final class ScrollController2: BuiltinController {
    static let instance: ScrollController2 = .init()

    var id: ControllerID = .builtin(.scroll)
    var name: String? = "Scroll2"
    var symbol: SFSymbol = .arrowUpArrowDown

    var controllerDescription: ControllerDescription = .init(
        abstraction: "Scroll using the dial. (Demo controller)",
        press: "Show controller picker."
    )
    
    var haptics: Bool = false
    var rotationType: Rotation.RawType = .continuous

    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: SurfaceDial.Callback) {
        if MiniControllerPicker.shared.isVisible {
            // Confirm current selection
            MiniControllerPicker.shared.confirm()
            return
        }

        // HARD-CODED LIST (you asked to define right here)
        let items: [PickerItem] = [
            .init(id: "builtin.scroll",     name: "Scroll",     symbol: .arrowUpArrowDown),
            .init(id: "builtin.scroll2",    name: "Scroll2",    symbol: .arrowUpArrowDown),
            .init(id: "builtin.playback",   name: "Playback",   symbol: .playpause),
            .init(id: "builtin.brightness", name: "Brightness", symbol: .sunMax),
            .init(id: "builtin.mission",    name: "Mission Ctr",symbol: .squareGrid2x2),
            .init(id: "builtin.volume",     name: "Volume",     symbol: .speakerWave2),
            .init(id: "miniVolume",         name: "Mini Volume",symbol: .speakerWave3),
        ]

        MiniControllerPicker.shared.open(items: items, title: "Controllers") { chosen in
            // Map the chosen.id to your real ControllerID
            switch chosen.id {
            case "builtin.scroll":
                Defaults[.currentControllerID] = ControllerID.builtin(.scroll)
            case "builtin.scroll2":
                Defaults[.currentControllerID] = ControllerID.builtin(.scroll2)
            case "builtin.playback":
                Defaults[.currentControllerID] = ControllerID.builtin(.playback)
            case "builtin.brightness":
                Defaults[.currentControllerID] = ControllerID.builtin(.brightness)
            case "builtin.mission":
                Defaults[.currentControllerID] = ControllerID.builtin(.mission)
            case "builtin.volume":
                Defaults[.currentControllerID] = ControllerID.builtin(.volume)
            case "miniVolume":
                Defaults[.currentControllerID] = .miniVolume
            default:
                break
            }
        }
    }

    func onRotation(rotation: Rotation, totalDegrees: Int, buttonState: Hardware.ButtonState, interval: TimeInterval?, duration: TimeInterval, _ callback: SurfaceDial.Callback) {
        if MiniControllerPicker.shared.isVisible {
            let directionValue = (rotation.direction == .clockwise ? 1 : -1)
            MiniControllerPicker.shared.moveSelection(by: directionValue)
            return
        }

        let linesToScroll = -rotation.direction.rawValue
        let scrollEvent = CGEvent(scrollWheelEvent2Source: nil, units: .line, wheelCount: 1, wheel1: Int32(linesToScroll), wheel2: 0, wheel3: 0)
        scrollEvent?.post(tap: .cghidEventTap)
    }

    func onRelease(_ callback: SurfaceDial.Callback) {}
}

