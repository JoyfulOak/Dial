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
        VStack(spacing: 0) {
            // Header
            Text("Controllers")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 14)
                .padding(.bottom, 6)
            Divider()
            // Main: list
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
            .listStyle(.plain)
            .frame(minHeight: 180, maxHeight: .infinity)
            Divider()
            // Footer: rotate/select message
            HStack {
                Spacer()
                Text("Rotate to choose • Press to select")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 10)
                Spacer()
            }
        }
        .frame(minWidth: 350)
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
