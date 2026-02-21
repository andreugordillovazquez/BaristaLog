//
//  LibraryView.swift
//  Brew
//

import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Bean.name) private var beans: [Bean]
    @Query(sort: \Grinder.name) private var grinders: [Grinder]
    @Query(sort: \Brewer.name) private var brewers: [Brewer]

    @State private var showingAddBean = false
    @State private var showingAddGrinder = false
    @State private var showingAddBrewer = false
    @State private var showingAddMenu = false

    private var isCompletelyEmpty: Bool {
        beans.isEmpty && grinders.isEmpty && brewers.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if isCompletelyEmpty {
                    LibraryEmptyStateView(onAdd: { showingAddMenu = true })
                } else {
                    List {
                        // MARK: - Beans Section
                        Section {
                            if beans.isEmpty {
                                Button {
                                    showingAddBean = true
                                } label: {
                                    Label("Add a Bean", systemImage: "plus.circle")
                                        .foregroundStyle(Color.brandBrown)
                                }
                            } else {
                                ForEach(beans) { bean in
                                    NavigationLink {
                                        BeanDetailView(bean: bean)
                                    } label: {
                                        BeanRowView(bean: bean)
                                    }
                                }
                                .onDelete(perform: deleteBeans)
                            }
                        } header: {
                            Text("Beans")
                                .textCase(nil)
                        }

                        // MARK: - Grinders Section
                        Section {
                            if grinders.isEmpty {
                                Button {
                                    showingAddGrinder = true
                                } label: {
                                    Label("Add a Grinder", systemImage: "plus.circle")
                                        .foregroundStyle(Color.brandBrown)
                                }
                            } else {
                                ForEach(grinders) { grinder in
                                    NavigationLink {
                                        GrinderDetailView(grinder: grinder)
                                    } label: {
                                        GrinderRowView(grinder: grinder)
                                    }
                                }
                                .onDelete(perform: deleteGrinders)
                            }
                        } header: {
                            Text("Grinders")
                                .textCase(nil)
                        }

                        // MARK: - Brewers Section
                        Section {
                            if brewers.isEmpty {
                                Button {
                                    showingAddBrewer = true
                                } label: {
                                    Label("Add a Brewer", systemImage: "plus.circle")
                                        .foregroundStyle(Color.brandBrown)
                                }
                            } else {
                                ForEach(brewers) { brewer in
                                    NavigationLink {
                                        BrewerDetailView(brewer: brewer)
                                    } label: {
                                        BrewerRowView(brewer: brewer)
                                    }
                                }
                                .onDelete(perform: deleteBrewers)
                            }
                        } header: {
                            Text("Brewers")
                                .textCase(nil)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.visible)
                    .headerProminence(.increased)
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingAddBean = true
                        } label: {
                            Label("Add Bean", systemImage: "leaf")
                        }
                        Button {
                            showingAddGrinder = true
                        } label: {
                            Label("Add Grinder", systemImage: "gearshape")
                        }
                        Button {
                            showingAddBrewer = true
                        } label: {
                            Label("Add Brewer", systemImage: "cup.and.saucer")
                        }
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBean) {
                AddBeanView()
            }
            .sheet(isPresented: $showingAddGrinder) {
                AddGrinderView()
            }
            .sheet(isPresented: $showingAddBrewer) {
                AddBrewerView()
            }
            .confirmationDialog("Add to Library", isPresented: $showingAddMenu) {
                Button("Add Bean")    { showingAddBean = true }
                Button("Add Grinder") { showingAddGrinder = true }
                Button("Add Brewer")  { showingAddBrewer = true }
            }
        }
    }

    private func deleteBeans(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(beans[index])
            }
        }
    }

    private func deleteGrinders(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(grinders[index])
            }
        }
    }

    private func deleteBrewers(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(brewers[index])
            }
        }
    }
}

// MARK: - Bean Row

struct BeanRowView: View {
    let bean: Bean

    var body: some View {
        HStack(spacing: 12) {
            if let imageData = bean.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .frame(width: 50, height: 50)
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(.secondary)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(bean.name)
                    .font(.headline)
                if let roaster = bean.roaster {
                    Text(roaster)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Grinder Row

struct GrinderRowView: View {
    let grinder: Grinder

    var body: some View {
        HStack(spacing: 12) {
            if let imageData = grinder.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .frame(width: 50, height: 50)
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.secondary)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(grinder.name)
                    .font(.headline)
                if let brand = grinder.brand {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Brewer Row

struct BrewerRowView: View {
    let brewer: Brewer

    var body: some View {
        HStack(spacing: 12) {
            if let imageData = brewer.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .frame(width: 50, height: 50)
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundStyle(.secondary)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(brewer.name)
                    .font(.headline)
                if let brand = brewer.brand {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Library Empty State

struct LibraryEmptyStateView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.brandBrown.opacity(0.12))
                    .frame(width: 88, height: 88)
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(Color.brandBrown)
            }

            VStack(spacing: 8) {
                Text("Set Up Your Library")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Add your beans, grinder, and brewer\nto start logging extractions.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)

            Button(action: onAdd) {
                Text("Add to Library")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(minWidth: 160)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.glassProminent)
            .tint(Color.brandBrown)
            .padding(.top, 24)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    LibraryView()
        .modelContainer(PreviewContainer.container)
}
