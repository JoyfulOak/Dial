//  MiniControllerPicker.swift
//  Dial
//
//  A tiny, self-contained picker window that you can summon from any Controller.
//  Rotate = move selection, Click = confirm.
//  You feed it a list of (id, name, symbol) items when you open it.

import SwiftUI
import AppKit
import SFSafeSymbols
import Defaults

// MARK: - Model shown in the picker (keep it repo-agnostic)
struct PickerItem: Identifiable, Equatable {
    let id: String           // could be ControllerID.description, etc.
    let name: String
    let symbol: SFSymbol
}

// MARK: - Window controller + event API
final class MiniControllerPicker {
    static let shared = MiniControllerPicker()
    private init() {}

    private var panel: NSPanel?
    private var host: NSHostingController<PickerRoot>?
    private var items: [PickerItem] = []
    private var onChoose: ((PickerItem) -> Void)?
    
    // Current selection index
    private var index: Int = 0 {
        didSet { updateSelection() }
    }

    private var previousSensitivity: Sensitivity? = nil

    var isVisible:
    Bool {
        if Thread.isMainThread {
            return panel?.isVisible == true
        } else {
            // Always access NSWindow.isVisible on the main thread
            return DispatchQueue.main.sync { panel?.isVisible == true }
        }
    }

    func open(items: [PickerItem],
              title: String = "Controllers",
              startIndex: Int = 0,
              width: CGFloat = 320,
              onChoose: @escaping (PickerItem) -> Void) {
        
        if !Thread.isMainThread {
            DispatchQueue.main.async { [self] in
                open(items: items, title: title, startIndex: startIndex, width: width, onChoose: onChoose)
            }
            return
        }

        guard !items.isEmpty else { return }
        if previousSensitivity == nil {
            previousSensitivity = Defaults[.globalSensitivity]
            Defaults[.globalSensitivity] = .medium
        }

        self.items = items
        self.onChoose = onChoose
        self.index = min(max(0, startIndex), items.count - 1)

        // Build SwiftUI content
        let content = PickerRoot(
            title: title,
            items: items,
            selectedIndex: index,
            onDoubleClick: { [weak self] in self?.confirm() }
        )

        // Reuse window if already created
        if host == nil {
            let hc = NSHostingController(rootView: content)
            host = hc
            let p = NSPanel.miniFloating(contentViewController: hc, title: title, width: width)
            p.hidesOnDeactivate = false
            p.isReleasedWhenClosed = false
            p.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
            p.level = .floating
            panel = p
        } else {
            host?.rootView = content
        }

        panel?.title = title
        panel?.makeKeyAndOrderFront(nil)
        centerNearMouse(panel)
        updateSelection()
    }

    func close() {
        let closeWork = {
            self.panel?.orderOut(nil)
            if let host = self.host {
                let current = host.rootView
                host.rootView = current.withSelected(self.index)
            }
            if let previous = self.previousSensitivity {
                Defaults[.globalSensitivity] = previous
                self.previousSensitivity = nil
            }
        }
        if Thread.isMainThread {
            closeWork()
        } else {
            DispatchQueue.main.async {
                closeWork()
            }
        }
    }

    func moveSelection(by delta: Int) {
        guard isVisible, !items.isEmpty else { return }
        let newIndex = (index + delta).clamped(to: 0...(items.count - 1))
        index = newIndex
    }

    func confirm() {
        guard isVisible, index < items.count else { return }
        let chosen = items[index]
        close()
        onChoose?(chosen)
    }

    // MARK: - Internal helpers
    private func updateSelection() {
        guard isVisible else { return }
        if let rootView = host?.rootView {
            host?.rootView = rootView.withSelected(index)
        }
    }

    private func centerNearMouse(_ window: NSWindow?) {
        guard let window else { return }
        let mouse = NSEvent.mouseLocation
        let height = window.frame.height
        let width = window.frame.width
        let origin = CGPoint(x: mouse.x - width/2, y: mouse.y - height/2)
        let constrained = NSRect(origin: origin, size: window.frame.size)
        window.setFrame(constrained, display: true)
    }
}

// MARK: - SwiftUI Root
private struct PickerRoot: View {
    let title: String
    let items: [PickerItem]
    var selectedIndex: Int
    var onDoubleClick: () -> Void

    func withSelected(_ idx: Int) -> PickerRoot {
        .init(title: title, items: items, selectedIndex: idx, onDoubleClick: onDoubleClick)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title bar area (kept simple; the panel still has its own title)
            Text(title)
                .font(.headline)
                .padding(.vertical, 8)

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(items.enumerated()), id: \.1.id) { idx, item in
                            Row(item: item, isSelected: idx == selectedIndex)
                                .id(idx)
                                .contentShape(Rectangle())
                                .onTapGesture(count: 2) { onDoubleClick() }
                        }
                    }
                }
                .onAppear { proxy.scrollTo(selectedIndex, anchor: .center) }
                .onChange(of: selectedIndex) { _, new in
                    withAnimation(.easeInOut(duration: 0.08)) {
                        proxy.scrollTo(new, anchor: .center)
                    }
                }
            }
            .frame(minHeight: 220, maxHeight: 320)

            Divider()

            HStack {
                Text("Rotate to choose • Press to select")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .padding(.horizontal, 8)
    }

    struct Row: View {
        let item: PickerItem
        let isSelected: Bool

        var body: some View {
            HStack(spacing: 8) {
                Image(systemSymbol: item.symbol)
                    .frame(width: 18)
                Text(item.name)
                    .lineLimit(1)
                Spacer()
                if isSelected {
                    Image(systemSymbol: .checkmarkCircleFill)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isSelected ? Color(nsColor: .selectedTextBackgroundColor).opacity(0.25) : .clear)
        }
    }
}

// MARK: - Small extensions
private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

private extension View {
    func withSelected(_ idx: Int) -> Self { self }
}
