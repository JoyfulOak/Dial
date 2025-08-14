//
//  MissionController.swift
//  Dial
//
//  Created by KrLite on 2024/3/21.
//

import Foundation
import AppKit
import SFSafeSymbols
import Defaults

// Assumes scrollClick is defined globally in ScrollController.swift
// If extern is not allowed, add a comment indicating that scrollClick must be globally defined.
// extern var scrollClick: Bool

class MissionController: BuiltinController {
    static let instance: MissionController = .init()
    
    var id: ControllerID = .builtin(.mission)
    var name: String? = String(localized: .init("Controllers/Default/Mission: Name", defaultValue: "Mission"))
    var symbol: SFSymbol = .command
    
    var controllerDescription: ControllerDescription = .init(
        abstraction: .init(localized: .init("Controllers/Builtin/Mission: Abstraction", defaultValue: """
You can iterate through App Switcher and activate app windows through this controller.
"""))
    )
    
    var haptics: Bool = true
    var rotationType: Rotation.RawType = .stepping
    
    private var inMission = false
    private var escapeDispatch: DispatchWorkItem?
    private var resetToScrollDispatch: DispatchWorkItem?
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: SurfaceDial.Callback) {
      
        
        if !isDoubleClick {
            onRelease(callback)
        }
    }
    
    func onRotation(
        rotation: Rotation, totalDegrees: Int,
        buttonState: Hardware.ButtonState, interval: TimeInterval?, duration: TimeInterval,
        _ callback: SurfaceDial.Callback
    ) {
        switch rotation {
        case .stepping(let direction):
            escapeDispatch?.cancel()
            inMission = true
            
            let modifiers: [Direction: NSEvent.ModifierFlags] = [.clockwise: [.command], .counterclockwise: [.shift, .command]]
            let action: [Direction: Set<Input>] = [.clockwise: [.keyTab], .counterclockwise: [.keyTab]]
            
            Input.postKeys(action[direction]!, modifiers: modifiers[direction]!)
            
            escapeDispatch = DispatchWorkItem {
                Input.keyEscape.post()
            }
            if let escapeDispatch {
                DispatchQueue.main.asyncAfter(deadline: .now() + NSEvent.doubleClickInterval * 3, execute: escapeDispatch)
            }
            
            callback.device.buzz()
            
            //rotation stops set scrollClick and active controller to ScrollController
            
            resetToScrollDispatch?.cancel()
            resetToScrollDispatch = DispatchWorkItem {
                if scrollClick {
                    scrollClick = false
                    Defaults[.currentControllerID] = .builtin(.scroll)
                }
            }
            if let resetToScrollDispatch {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: resetToScrollDispatch)
            }
        default:
            break
        }
    }
    
    func onRelease(_ callback: SurfaceDial.Callback) {
        if inMission {
            inMission = false
            escapeDispatch?.cancel()
            
            Input.keyReturn.post()
            
        }
        // After application picker selection set ScrollController as active controller
        if scrollClick {
            scrollClick = false
            Defaults[.currentControllerID] = .builtin(.scroll)
            return
        }
    }
}

