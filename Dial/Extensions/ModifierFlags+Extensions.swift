//
//  ModifierFlags+Extensions.swift
//  Dial
//
//  Created by KrLite on 2024/3/30.
//

import Foundation
import AppKit
import SFSafeSymbols

extension NSEvent.ModifierFlags {
    public var customID: Self { self }
}

extension NSEvent.ModifierFlags {
    var keys: [NSEvent.ModifierFlags] {
        var result: [NSEvent.ModifierFlags] = []
        
        if self.contains(.capsLock) {
            result.append(.capsLock)
        }
        
        if self.contains(.command) {
            result.append(.command)
        }
        
        if self.contains(.control) {
            result.append(.control)
        }
        
        if self.contains(.function) {
            result.append(.function)
        }
        
        if self.contains(.help) {
            result.append(.help)
        }
        
        if self.contains(.numericPad) {
            result.append(.numericPad)
        }
        
        if self.contains(.option) {
            result.append(.option)
        }
        
        if self.contains(.shift) {
            result.append(.shift)
        }
        
        return result
    }
    
    var sortedKeys: [NSEvent.ModifierFlags] {
        keys.sorted(by: NSEvent.ModifierFlags.isLessThan)
    }
}

extension NSEvent.ModifierFlags {
    static func isLessThan(_ lhs: NSEvent.ModifierFlags, _ rhs: NSEvent.ModifierFlags) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension NSEvent.ModifierFlags: SymbolRepresentable {
    var symbol: SFSafeSymbols.SFSymbol {
        switch self {
        case [.capsLock]: .capslock
        case [.command]: .command
        case [.control]: .control
        case [.function]: .fn
        case [.help]: .questionmark
        case [.numericPad]: .number
        case [.option]: .option
        case [.shift]: .shift
            
        default: .questionmarkAppDashed
        }
    }
}
