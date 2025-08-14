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

var scrollClick: Bool = false

class ScrollController: BuiltinController {
    static let instance: ScrollController = .init()
    
    var id: ControllerID = .builtin(.scroll)
    var name: String? = String(localized: .init("Controllers/Default/Scroll: Name", defaultValue: "Scroll"))
    var symbol: SFSymbol = .arrowUpArrowDown
    
    var controllerDescription: ControllerDescription = .init(
        abstraction: .init(localized: .init("Controllers/Builtin/Scroll: Abstraction", defaultValue: """
You can scroll and activate Mission Controller through this controller. Scrolls will always happen at the cursor.
""")),
        press: .init(localized: .init("Controllers/Builtin/Scroll: Press", defaultValue: """
Activate Mission Controller.
"""))
    )
    
    var haptics: Bool = false
    var rotationType: Rotation.RawType = .continuous
    
    private var accumulated = 0
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: SurfaceDial.Callback) {
        scrollClick = true
        //Input.postMouse(.center, buttonState: .pressed)
        // When the button is pressed:
        Defaults[.currentControllerID] = .builtin(.mission) //sets
        //Defaults[.mission] = desiredControllerID
        
    }
    
    func onRelease(_ callback: SurfaceDial.Callback) {
        Input.postMouse(.center, buttonState: .released)
    }
    
    func onRotation(
        rotation: Rotation, totalDegrees: Int,
        buttonState: Hardware.ButtonState, interval: TimeInterval?, duration: TimeInterval,
        _ callback: SurfaceDial.Callback
    ) {
        var accelerated = false
        
        if let interval, interval <= 0.01 {
            if accumulated < 12 {
                accumulated += 1
            } else if duration > NSEvent.keyRepeatDelay {
                accelerated = true
            }
        } else {
            accumulated = 0
        }
        
        switch rotation {
        case .continuous(let direction):
            let steps = accelerated ? 60 : 30
            let event = CGEvent(
                scrollWheelEvent2Source: nil,
                units: .pixel,
                wheelCount: 1,
                wheel1: Int32(-steps * direction.negateIf(buttonState == .pressed).rawValue),
                wheel2: 0,
                wheel3: 0
            )
            event?.post(tap: .cghidEventTap)
        default:
            break
        }
    }
}

