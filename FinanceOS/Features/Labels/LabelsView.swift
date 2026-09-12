import SwiftUI
import SwiftData

struct LabelsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TransactionLabel.name) private var labels: [TransactionLabel]
    @State private var showsArchived = false
    @State private var newLabelName = ""
    @State private var editingLabel: TransactionLabel?
    @State private var mergingLabel: TransactionLabel?
    @State private var errorMessage: String?
    private let service = LabelService()

    private var visibleLabels: [TransactionLabel] { labels.filter { showsArchived || !$0.isArchived } }

    var body: some View {
        List {
            Section("Create label") {
                HStack {
                    TextField("e.g. Weekend", text: $newLabelName)
                    Button("Add", action: create).disabled(newLabelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            Section(showsArchived ? "All labels" : "Active labels") {
                if visibleLabels.isEmpty {
                    Text("Labels help you find patterns across transactions.").foregroundStyle(AppTheme.textSecondary)
                }
                ForEach(visibleLabels, id: \.id) { label in
                    HStack {
                        Image(systemName: label.iconName).foregroundStyle(AppTheme.primary)
                        Text(label.name).font(.body.weight(.medium))
                        Spacer()
                        if label.isArchived { Text("Archived").font(.caption).foregroundStyle(AppTheme.textSecondary) }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture { editingLabel = label }
                    .contextMenu {
                        Button("Rename", systemImage: "pencil") { editingLabel = label }
                        if !label.isArchived { Button("Archive", systemImage: "archivebox") { perform { try service.archive(label, in: modelContext) } } }
                        Button("Merge into…", systemImage: "arrow.triangle.merge") { mergingLabel = label }
                        Button("Delete unused", systemImage: "trash", role: .destructive) { perform { try service.deleteUnused(label, in: modelContext) } }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden).background(AppTheme.background)
        .navigationTitle("Labels")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu { Toggle("Show archived", isOn: $showsArchived) } label: { Image(systemName: "line.3.horizontal.decrease.circle") }
            }
        }
        .sheet(item: $editingLabel) { label in LabelRenameView(label: label) }
        .sheet(item: $mergingLabel) { source in LabelMergeView(source: source, labels: labels.filter { !$0.isArchived && $0.id != source.id }) }
        .alert("Couldn’t update labels", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    private func create() {
        perform { try service.create(name: newLabelName, in: modelContext) }
        if errorMessage == nil { newLabelName = "" }
    }

    private func perform(_ operation: () throws -> Void) {
        do { try operation() } catch { errorMessage = error.localizedDescription }
    }
}

private struct LabelRenameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let label: TransactionLabel
    @State private var name: String
    @State private var errorMessage: String?
    private let service = LabelService()

    init(label: TransactionLabel) { self.label = label; _name = State(initialValue: label.name) }

    var body: some View {
        NavigationStack {
            Form { TextField("Name", text: $name) }
                .navigationTitle("Rename Label")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: dismiss.callAsFunction) }
                    ToolbarItem(placement: .confirmationAction) { Button("Save", action: save).fontWeight(.semibold) }
                }
                .alert("Couldn’t rename label", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                    Button("OK", role: .cancel) { errorMessage = nil }
                } message: { Text(errorMessage ?? "") }
        }
    }

    private func save() {
        do { try service.rename(label, to: name, in: modelContext); dismiss() }
        catch { errorMessage = error.localizedDescription }
    }
}

private struct LabelMergeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let source: TransactionLabel
    let labels: [TransactionLabel]
    @State private var destinationID: UUID?
    @State private var errorMessage: String?
    private let service = LabelService()

    var body: some View {
        NavigationStack {
            Form {
                Picker("Merge \(source.name) into", selection: $destinationID) {
                    Text("Choose label").tag(UUID?.none)
                    ForEach(labels, id: \.id) { Text($0.name).tag(Optional($0.id)) }
                }
                Text("Transactions will keep the destination label and the source label will be archived.")
                    .font(.footnote).foregroundStyle(AppTheme.textSecondary)
            }
            .navigationTitle("Merge Label")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: dismiss.callAsFunction) }
                ToolbarItem(placement: .confirmationAction) { Button("Merge", action: merge).fontWeight(.semibold).disabled(destinationID == nil) }
            }
            .alert("Couldn’t merge label", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func merge() {
        guard let destination = labels.first(where: { $0.id == destinationID }) else { return }
        do { try service.merge(source, into: destination, in: modelContext); dismiss() }
        catch { errorMessage = error.localizedDescription }
    }
}
