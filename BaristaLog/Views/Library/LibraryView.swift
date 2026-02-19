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

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Beans Section
                Section {
                    if beans.isEmpty {
                        Text("No beans yet")
                            .foregroundStyle(.secondary)
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
                        Text("No grinders yet")
                            .foregroundStyle(.secondary)
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
                        Text("No brewers yet")
                            .foregroundStyle(.secondary)
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

#Preview {
    LibraryView()
        .modelContainer(PreviewContainer.container)
}
