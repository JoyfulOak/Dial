//
//  ShortcutArray.swift
//  Dial
//
//  Created by KrLite on 2024/3/21.
//

import Foundation
import AppKit
import Defaults

struct ShortcutArray: Defaults.Serializable, Codable {
    var modifiers: NSEvent.ModifierFlags
    
    var keys: Set<Input>
    
    var display: String {
        keys.map { $0.name }.joined(separator: " ")
    }
    
    var isEmpty: Bool {
        keys.isEmpty && modifiers.isEmpty
    }
    
    init(
        modifiers: NSEvent.ModifierFlags = [],
        keys: Set<Input> = Set()
    ) {
        self.modifiers = modifiers
        self.keys = keys
    }
    
    func post() {
        Input.postKeys(keys, modifiers: modifiers)
    }
    
    enum CodingKeys: String, CodingKey {
        case modifiers
        case keys
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(modifiers.rawValue, forKey: .modifiers)
        try container.encode(keys, forKey: .keys)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawModifiers = try container.decode(UInt.self, forKey: .modifiers)
        self.modifiers = NSEvent.ModifierFlags(rawValue: rawModifiers)
        self.keys = try container.decode(Set<Input>.self, forKey: .keys)
    }
}

extension ShortcutArray: Equatable {
    // Make it equatable
}

extension ShortcutArray {
    var sortedKeys: [Input] {
        keys.sorted(by: >)
    }
}

extension ShortcutArray {
    struct DirectionBased: Codable {
        var clockwisely: ShortcutArray
        var counterclockwisely: ShortcutArray
        
        var isAllEmpty: Bool {
            clockwisely.isEmpty && counterclockwisely.isEmpty
        }
        
        func from(_ direction: Direction) -> ShortcutArray {
            switch direction {
            case .clockwise:
                clockwisely
            case .counterclockwise:
                counterclockwisely
            }
        }
    }
}
