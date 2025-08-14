// ControllersMenuView.swift
// A window showing a picker for controllers (built-in and custom)
import SwiftUI
import SFSafeSymbols
import Defaults

struct ControllersMenuView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Controllers").font(.title2).bold()
            Divider()
            // Built-in Controllers
            ForEach(ControllerID.Builtin.availableCases, id: \.self) { builtin in
                Button {
                    Defaults[.currentControllerID] = ControllerID.builtin(builtin)
                    dismiss()
                } label: {
                    HStack {
                        builtin.controller.symbol.image
                        Text(builtin.controller.name ?? "Builtin")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(.vertical, 6)
            }
            // Custom Controllers (Shortcuts)
            ForEach(Defaults[.activatedControllerIDs].filter { !$0.isBuiltin }, id: \.self) { custom in
                Button {
                    Defaults[.currentControllerID] = custom
                    dismiss()
                } label: {
                    HStack {
                        custom.controller.symbol.image
                        Text(custom.controller.name ?? "Custom")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(.vertical, 6)
            }
        }
        .padding(16)
        .frame(width: 320)
    }
}

#Preview {
    ControllersMenuView()
}
