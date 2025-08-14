//
//  VolumeController.swift
//  Dial
//
//  Created by You on 2025/08/09.
//

import Foundation
import SFSafeSymbols
import AppKit

final class VolumeController: BuiltinController {
    static let instance: VolumeController = .init()

    var id: ControllerID = .builtin(.volume)
    var name: String? = String(localized: .init("Controllers/Builtin/Volume: Name",
                                                defaultValue: "Volume"))
    var symbol: SFSymbol = .speakerWave2

    var controllerDescription: ControllerDescription = .init(
        abstraction: .init(localized: .init("Controllers/Builtin/Volume: Abstraction", defaultValue: """
Adjust the macOS output volume and mute via the dial.
""")),
        rotateClockwisely: .init(localized: .init("Controllers/Builtin/Volume: Rotate Clockwisely", defaultValue: """
Volume up.
""")),
        rotateCounterclockwisely: .init(localized: .init("Controllers/Builtin/Volume: Rotate Counterclockwisely", defaultValue: """
Volume down.
""")),
        press: .init(localized: .init("Controllers/Builtin/Volume: Press", defaultValue: """
Toggle mute.
""")),
        doublePress: .init(localized: .init("Controllers/Builtin/Volume: Double Press", defaultValue: """
Toggle mute.
""")),
        pressAndRotateClockwisely: .init(localized: .init("Controllers/Builtin/Volume: Press and Rotate Clockwisely", defaultValue: """
Fine‑tune volume (same as rotate).
"""))
    )

    // Haptics off; rotation is continuous like Brightness
    var haptics: Bool = false
    var rotationType: Rotation.RawType = .continuous

    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: SurfaceDial.Callback) {
        // Toggle mute on press (and also on double press for symmetry)
        Input.postAuxKeys([Input.keyMute])
    }

    func onRotation(
        rotation: Rotation, totalDegrees: Int,
        buttonState: Hardware.ButtonState, interval: TimeInterval?, duration: TimeInterval,
        _ callback: SurfaceDial.Callback
    ) {
        guard case .continuous(let direction) = rotation else { return }

        // System volume keys don’t need modifiers
        switch direction {
        case .clockwise:
            Input.postAuxKeys([Input.keyVolumeUp])
        case .counterclockwise:
            Input.postAuxKeys([Input.keyVolumeDown])
        }
    }
}
//
//  VolumeController.swift
//  Dial
//
