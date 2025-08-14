//
//  Controller.swift
//  Dial
//
//  Created by KrLite on 2024/3/21.
//

import Foundation
import AppKit
import Defaults
import SFSafeSymbols
import SwiftUI

enum ControllerID: Codable, Hashable, Defaults.Serializable, Equatable {
    enum Builtin: CaseIterable, Codable {
        case main
        
        case scroll
        
        case playback
        
        case brightness
        
        case mission
        
        case volume
        
        var controller: Controller {
            switch self {
            case .main:
                MainController.instance
            case .scroll:
                ScrollController.instance
            case .playback:
                PlaybackController.instance
            case .brightness:
                BrightnessController.instance
            case .mission:
                MissionController.instance
            case .volume:
                VolumeController.instance
            }
        }
        
        var linkage: ControllerID {
            .builtin(self)
        }
        
        static var availableCases: [ControllerID.Builtin] {
            allCases.filter { $0 != .main }
        }
    }
    
    case shortcuts(ShortcutsController.Settings)
    
    case builtin(Builtin)
}

extension ControllerID {
    var controller: Controller {
        get {
            switch self {
            case .shortcuts(let settings):
                ShortcutsController(settings: settings)
            case .builtin(let builtin):
                builtin.controller
            }
        }
        
        set(controller) {
            // Enable binding operations
            /*
            guard let shortcutsController = controller as? ShortcutsController else { return }
            
            if Defaults[.activatedControllerIDs].contains(self) {
                Defaults[.activatedControllerIDs].replace([self], with: [Self.shortcuts(shortcutsController.settings)])
            }
            
            if Defaults[.inactivatedControllerIDs].contains(self) {
                Defaults[.inactivatedControllerIDs].replace([self], with: [Self.shortcuts(shortcutsController.settings)])
            }
             */
        }
    }
    
    var isCurrent: Bool {
        get {
            Defaults[.currentControllerID] == self
        }
        
        set {
            guard Defaults[.activatedControllerIDs].contains(self) else {
                Defaults[.currentControllerID] = nil
                return
            }
            
            Defaults[.currentControllerID] = self
        }
    }
    
    var isBuiltin: Bool {
        switch self {
        case .shortcuts(_):
            false
        case .builtin(_):
            true
        }
    }
    
    var isActivated: Bool {
        get {
            Defaults[.activatedControllerIDs].contains(self)
        }
        
        set(activated) {
            if activated && !isActivated {
                Defaults[.activatedControllerIDs].append(self)
                Defaults[.inactivatedControllerIDs].replace([self], with: [])
            }
            
            if !activated && isActivated {
                Defaults[.activatedControllerIDs].replace([self], with: [])
                Defaults[.inactivatedControllerIDs].append(self)
            }
        }
    }
}

extension ControllerID: Identifiable {
    var id: Self {
        self
    }
}

extension ControllerID.Builtin: Identifiable {
    var id: Self {
        self
    }
}

extension ControllerID: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .shortcuts(_):
            "Shortcuts<\(self)>"
        case .builtin(let builtin):
            "Builtin<\(String(reflecting: builtin))>"
        }
    }
}

extension ControllerID: LosslessStringConvertible {
    init?(_ description: String) {
        guard let data = description.data(using: .utf8) else { return nil }
        guard let id = try? JSONDecoder().decode(ControllerID.self, from: data.base64EncodedData()) else { return nil }
        self = id
    }
    
    var description: String {
        let data = try! JSONEncoder().encode(self)
        return data.base64EncodedString()
    }
}

extension ControllerID: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .controllerID) { id in
            try JSONEncoder().encode(id).base64EncodedData()
        } importing: { data in
            try JSONDecoder().decode(ControllerID.self, from: data)
        }
    }
}

protocol Controller: AnyObject, SymbolRepresentable {
    var id: ControllerID { get }
    
    var name: String? { get set }
    
    var symbol: SFSymbol { get set }
    
    /// Whether to enable haptic feedback on stepping. The default value is `false`.
    var haptics: Bool { get set }
    
    var rotationType: Rotation.RawType { get set }
    
    var autoTriggers: Bool { get }
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: SurfaceDial.Callback)
    
    func onRotation(rotation: Rotation, totalDegrees: Int, buttonState: Hardware.ButtonState, interval: TimeInterval?, duration: TimeInterval, _ callback: SurfaceDial.Callback)
    
    func onRelease(_ callback: SurfaceDial.Callback)
}

extension Controller {
    static func equals(_ lhs: any Controller, _ rhs: any Controller) -> Bool {
        lhs.id == rhs.id
    }
    
    func equals(_ another: any Controller) -> Bool {
        Self.equals(self, another)
    }
}

extension Controller {
    var autoTriggers: Bool {
        haptics && rotationType.autoTriggers
    }
    
    var nameOrEmpty: String {
        get {
            name ?? ""
        }
        
        set {
            name = newValue.isEmpty ? nil : newValue
        }
    }
    
    func onRelease(_ callback: SurfaceDial.Callback) {
        
    }
}

protocol BuiltinController: Controller {
    var controllerDescription: ControllerDescription { get }
}

