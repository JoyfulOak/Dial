// SelectedControllersSettingsView.swift
// Shows only the given controllers for editing.
import SwiftUI

struct SelectedControllersSettingsView: View {
    let controllers: [ControllerID]
    // Called when a controller is selected.
    let onControllerSelected: ((ControllerID) -> Void)?
    
    init(controllers: [ControllerID], onControllerSelected: ((ControllerID) -> Void)? = nil) {
        self.controllers = controllers
        self.onControllerSelected = onControllerSelected
    }
    
    var body: some View {
        List(controllers, id: \.self) { id in
            if let onSelect = onControllerSelected {
                Button {
                    onSelect(id)
                } label: {
                    ControllerStateEntryView(id: .constant(id))
                }
                .buttonStyle(.plain)
            } else {
                ControllerStateEntryView(id: .constant(id))
            }
        }
        .navigationTitle("Selected Controllers")
        .frame(minWidth: 350, minHeight: 400)
    }
}

#Preview {
    SelectedControllersSettingsView(
        controllers: [.builtin(.scroll)],
        onControllerSelected: { controllerID in
            print("Selected controller: \(controllerID)")
        }
    )
}
