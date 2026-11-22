import SwiftUI

/// Reorders the board tabs. Ordering is immediate and persisted, so the bottom tab
/// bar updates as soon as the sheet is dismissed (or live, on iPad's sidebar).
struct TabOrderEditor: View {
    @Environment(Session.self) private var session
    @Environment(\.dismiss) private var dismiss
    @AppStorage(TabOrder.defaultsKey) private var storedOrder = ""

    @State private var boards: [ForumBoard] = []

    private var allBoards: [ForumBoard] {
        session.tabCategories.flatMap(\.boards)
    }

    var body: some View {
        List {
            Section {
                ForEach(boards) { board in
                    row(board)
                }
                .onMove { indices, destination in
                    boards.move(fromOffsets: indices, toOffset: destination)
                }
            } header: {
                Text("Board tabs")
            } footer: {
                Text("Drag a board by its handle to move it up or down. “Unread” always stays first. Changes are saved immediately.")
            }

            Section {
                Button("Reset to Forum Order", role: .destructive) {
                    withAnimation {
                        boards = allBoards
                    }
                }
                .disabled(boards == allBoards)
            }
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("Arrange Tabs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
        .onAppear {
            boards = TabOrder.ordered(allBoards, saved: storedOrder)
        }
        .onChange(of: boards) { _, newValue in
            storedOrder = TabOrder.token(for: newValue)
        }
    }

    private func row(_ board: ForumBoard) -> some View {
        HStack(spacing: 12) {
            Image(systemName: board.iconName)
                .foregroundStyle(AppTheme.accent)
                .frame(width: 22)

            Text(board.name)
                .lineLimit(1)

            Spacer(minLength: 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint("Drag to reorder this board tab")
    }




}
