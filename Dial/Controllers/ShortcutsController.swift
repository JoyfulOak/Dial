//
//  ShortcutsController.swift
//  Dial
//
//  Created by KrLite on 2024/3/21.
//

import Foundation
import Defaults
import SFSafeSymbols
import AppKit

class ShortcutsController: Controller {
    struct Settings: SymbolRepresentable, Codable, Defaults.Serializable {
        var id: UUID
        var name: String?
        var symbol: SFSymbol
        
        var haptics: Bool
        var physicalDirection: Bool
        var alternativeDirection: Bool
        
        var rotationType: Rotation.RawType
        var shortcuts: Shortcuts
        
        struct Shortcuts: Codable, Defaults.Serializable {
            var rotate: ShortcutArray.DirectionBased
            var pressAndRotate: ShortcutArray.DirectionBased
            
            var press: ShortcutArray
            var doublePress: ShortcutArray
            
            var isEmpty: Bool {
                rotate.isAllEmpty && pressAndRotate.isAllEmpty && press.isEmpty && doublePress.isEmpty
            }
            
            init(
                rotation: ShortcutArray.DirectionBased = .init(
                    clockwisely: .init(),
                    counterclockwisely: .init()
                ),
                pressedRotation: ShortcutArray.DirectionBased = .init(
                    clockwisely: .init(),
                    counterclockwisely: .init()
                ),
                single: ShortcutArray = ShortcutArray(),
                double: ShortcutArray = ShortcutArray()
            ) {
                self.rotate = rotation
                self.pressAndRotate = pressedRotation
                self.press = single
                self.doublePress = double
            }
        }
        
        private init(
            id: UUID,
            name: String? = nil,
            symbol: SFSymbol? = nil,
            haptics: Bool = true,
            physicalDirection: Bool = false, alternativeDirection: Bool = false,
            rotationType: Rotation.RawType = .continuous, shortcuts: Shortcuts = Shortcuts()
        ) {
            self.id = id
            
            self.name = name
            self.symbol = symbol ?? .__circleFillableFallback
            
            self.haptics = haptics
            self.physicalDirection = physicalDirection
            self.alternativeDirection = alternativeDirection
            
            self.rotationType = rotationType
            self.shortcuts = shortcuts
        }
        
        private init(_ from: Self) {
            self.init(id: from.id)
        }
        
        init(
            name: String? = nil,
            symbol: SFSymbol? = nil,
            haptics: Bool = true,
            physicalDirection: Bool = false, alternativeDirection: Bool = false,
            rotationType: Rotation.RawType = .continuous, shortcuts: Shortcuts = Shortcuts()
        ) {
            self.init(
                id: UUID(),
                name: name, symbol: symbol,
                haptics: haptics, physicalDirection: physicalDirection, alternativeDirection: alternativeDirection,
                rotationType: rotationType, shortcuts: shortcuts
            )
        }
        
        enum CodingKeys: String, CodingKey {
            case id, name, symbol, haptics, physicalDirection, alternativeDirection, rotationType, shortcuts
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            name = try container.decodeIfPresent(String.self, forKey: .name)
            let symbolRawValue = try container.decode(String.self, forKey: .symbol)
            symbol = SFSymbol(rawValue: symbolRawValue)
            haptics = try container.decode(Bool.self, forKey: .haptics)
            physicalDirection = try container.decode(Bool.self, forKey: .physicalDirection)
            alternativeDirection = try container.decode(Bool.self, forKey: .alternativeDirection)
            rotationType = try container.decode(Rotation.RawType.self, forKey: .rotationType)
            shortcuts = try container.decode(Shortcuts.self, forKey: .shortcuts)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(symbol.rawValue, forKey: .symbol)
            try container.encode(haptics, forKey: .haptics)
            try container.encode(physicalDirection, forKey: .physicalDirection)
            try container.encode(alternativeDirection, forKey: .alternativeDirection)
            try container.encode(rotationType, forKey: .rotationType)
            try container.encode(shortcuts, forKey: .shortcuts)
        }
        
        func new() -> Settings {
            .init(self)
        }
    }
    
    private var _settings: Settings
    
    var settings: Settings {
        get {
            _settings
        }
        
        set {
            _settings = newValue
            Defaults.saveController(settings: _settings)
        }
    }
    
    var id: ControllerID {
        .shortcuts(settings)
    }
    
    var name: String? {
        get {
            settings.name
        }
        
        set {
            settings.name = newValue
        }
    }
    
    var symbol: SFSymbol {
        get {
            settings.symbol
        }
        
        set {
            settings.symbol = newValue
        }
    }
    
    var haptics: Bool {
        get {
            settings.haptics
        }
        
        set {
            settings.haptics = newValue
        }
    }
    
    var physicalDirection: Bool {
        get {
            settings.physicalDirection
        }
        
        set {
            settings.physicalDirection = newValue
        }
    }
    
    var alternativeDirection: Bool {
        get {
            settings.alternativeDirection
        }
        
        set {
            settings.alternativeDirection = newValue
        }
    }
    
    var rotationType: Rotation.RawType {
        get {
            settings.rotationType
        }
        
        set {
            settings.rotationType = newValue
        }
    }
    
    var shortcuts: Settings.Shortcuts {
        get {
            settings.shortcuts
        }
        
        set {
            settings.shortcuts = newValue
        }
    }
    
    init(settings: Settings) {
        self._settings = settings
    }
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: SurfaceDial.Callback) {
        if isDoubleClick {
            settings.shortcuts.doublePress.post()
        } else {
            settings.shortcuts.press.post()
        }
    }
    
    func onRotation(
        rotation: Rotation, totalDegrees: Int,
        buttonState: Hardware.ButtonState, interval: TimeInterval?, duration: TimeInterval,
        _ callback: SurfaceDial.Callback
    ) {
        guard rotation.conformsTo(rotationType) else { return }
        
        var direction = rotation.direction
        
        if settings.physicalDirection { direction = direction.physical }
        if settings.alternativeDirection { direction = direction.negate }
        
        switch buttonState {
        case .pressed:
            settings.shortcuts.pressAndRotate.from(direction).post()
        case .released:
            settings.shortcuts.rotate.from(direction).post()
        }
        
        if haptics && !rotationType.autoTriggers {
            callback.device.buzz()
        }
    }
}

extension ShortcutsController.Settings: Equatable {
    static func == (lhs: ShortcutsController.Settings, rhs: ShortcutsController.Settings) -> Bool {
        lhs.id == rhs.id
    }
}

extension ShortcutsController.Settings: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ShortcutsController: Equatable {
    static func == (lhs: ShortcutsController, rhs: ShortcutsController) -> Bool {
        lhs.id == rhs.id
    }
}

