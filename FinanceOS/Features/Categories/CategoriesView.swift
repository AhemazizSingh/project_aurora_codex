import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.displayOrder) private var categories: [Category]
    @State private var showsArchived = false
    @State private var showsEditor = false
    @State private var editingCategory: Category?
    @State private var mergingCategory: Category?
    @State private var errorMessage: String?
    private let service = CategoryService()

    private var visibleCategories: [Category] { categories.filter { showsArchived || !$0.isArchived } }

    var body: some View {
        List {
            if visibleCategories.isEmpty {
                ContentUnavailableView("No categories", systemImage: "square.grid.2x2", description: Text("Create a category to classify your spending."))
                    .frame(maxWidth: .infinity, minHeight: 280)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(visibleCategories, id: \.id) { category in
                    CategoryRow(category: category)
                        .contentShape(Rectangle())
                        .onTapGesture { editingCategory = category; showsEditor = true }
                        .contextMenu {
                            Button("Edit", systemImage: "pencil") { editingCategory = category; showsEditor = true }
                            if !category.isArchived {
                                Button("Archive", systemImage: "archivebox") { perform { try service.archive(category, in: modelContext) } }
                            }
                            Button("Merge into…", systemImage: "arrow.triangle.merge") { mergingCategory = category }
                            Button("Delete unused", systemImage: "trash", role: .destructive) { perform { try service.deleteUnused(category, in: modelContext) } }
                        }
                }
                .onMove { source, destination in perform { try service.reorder(visibleCategories, from: source, to: destination, in: modelContext) } }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle("Categories")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { EditButton() }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Toggle("Show archived", isOn: $showsArchived)
                } label: { Image(systemName: "line.3.horizontal.decrease.circle") }
            }
        }
        .safeAreaInset(edge: .bottom) {
            FSPrimaryButton(title: "New category") { editingCategory = nil; showsEditor = true }
                .padding(.horizontal, 24).padding(.vertical, 12).background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showsEditor) { CategoryEditor(category: editingCategory) }
        .sheet(item: $mergingCategory) { source in CategoryMergeView(source: source, categories: categories.filter { !$0.isArchived && $0.id != source.id }) }
        .alert("Couldn’t update categories", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    private func perform(_ operation: () throws -> Void) {
        do { try operation() } catch { errorMessage = error.localizedDescription }
    }
}

private struct CategoryRow: View {
    let category: Category
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: category.iconName).foregroundStyle(AppTheme.primary).frame(width: 32, height: 32)
                .background(AppTheme.primary.opacity(0.15), in: Circle())
            Text(category.name).font(.body.weight(.semibold))
            Spacer()
            if category.isArchived { Text("Archived").font(.caption).foregroundStyle(AppTheme.textSecondary) }
        }
        .padding(.vertical, 5)
        .accessibilityElement(children: .combine)
    }
}

private struct CategoryEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let category: Category?
    @State private var name: String
    @State private var iconName: String
    @State private var errorMessage: String?
    private let service = CategoryService()
    private let icons = ["fork.knife", "car.fill", "bag.fill", "cross.case.fill", "doc.text.fill", "film.fill", "book.fill", "ellipsis.circle.fill"]

    init(category: Category?) {
        self.category = category
        _name = State(initialValue: category?.name ?? "")
        _iconName = State(initialValue: category?.iconName ?? "tag.fill")
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                Picker("Icon", selection: $iconName) {
                    ForEach(icons, id: \.self) { icon in Label(icon, systemImage: icon).tag(icon) }
                }
            }
            .navigationTitle(category == nil ? "New Category" : "Edit Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: dismiss.callAsFunction) }
                ToolbarItem(placement: .confirmationAction) { Button("Save", action: save).fontWeight(.semibold) }
            }
            .alert("Couldn’t save category", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func save() {
        do {
            if let category { try service.update(category, name: name, iconName: iconName, colorHex: category.colorHex, in: modelContext) }
            else { try service.create(name: name, iconName: iconName, colorHex: "#3B82F6", in: modelContext) }
            dismiss()
        } catch { errorMessage = error.localizedDescription }
    }
}

private struct CategoryMergeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let source: Category
    let categories: [Category]
    @State private var destinationID: UUID?
    @State private var errorMessage: String?
    private let service = CategoryService()

    var body: some View {
        NavigationStack {
            Form {
                Section("Merge \(source.name) into") {
                    Picker("Destination", selection: $destinationID) {
                        Text("Choose category").tag(UUID?.none)
                        ForEach(categories, id: \.id) { Text($0.name).tag(Optional($0.id)) }
                    }
                }
                Text("All past transactions in \(source.name) will be reassigned. The source category will be archived.")
                    .font(.footnote).foregroundStyle(AppTheme.textSecondary)
            }
            .navigationTitle("Merge Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: dismiss.callAsFunction) }
                ToolbarItem(placement: .confirmationAction) { Button("Merge", action: merge).fontWeight(.semibold).disabled(destinationID == nil) }
            }
            .alert("Couldn’t merge category", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }

    private func merge() {
        guard let destination = categories.first(where: { $0.id == destinationID }) else { return }
        do { try service.merge(source, into: destination, in: modelContext); dismiss() }
        catch { errorMessage = error.localizedDescription }
    }
}
