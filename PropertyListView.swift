//
//  PropertyListView.swift
//  Home Inspection
//
//  Created by Peter Marsters on 10/4/2025.
//


import SwiftUI

struct PropertyListView: View {
    @State private var properties: [Inspection]
    @State private var showingAddProperty = false
    @State private var propertiesToDelete: IndexSet?
    @State private var showingDeletePropertyAlert = false
    
    init() {
        _properties = State(initialValue: PropertyListView.loadProperties())
    }
    
    var body: some View {
        NavigationStack {
            propertyList
                .navigationTitle("Property List")
                .navigationDestination(for: Inspection.self) { property in
                    PropertyDetailView(property: binding(for: property))
                }
                .toolbar(content: toolbarContent)
                .sheet(isPresented: $showingAddProperty) {
                    AddPropertyView(properties: $properties)
                }
                .alert("Delete Property", isPresented: $showingDeletePropertyAlert, presenting: propertiesToDelete) { offsets in
                    Button("Delete", role: .destructive) {
                        deleteProperties(at: offsets)
                        propertiesToDelete = nil
                    }
                    Button("Cancel", role: .cancel) {
                        propertiesToDelete = nil
                    }
                } message: { _ in
                    Text("Are you sure you want to delete this property? This action cannot be undone.")
                }
                .onChange(of: properties) { _ in
                    saveProperties()
                }
        }
    }
    
    private var propertyList: some View {
        List {
            Section(header: Text("Properties")) {
                ForEach(properties) { property in
                    NavigationLink(value: property) {
                        VStack(alignment: .leading) {
                            Text(property.propertyNumber)
                                .font(.headline)
                            Text(property.address)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete { offsets in
                    propertiesToDelete = offsets
                    showingDeletePropertyAlert = true
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(action: {
                showingAddProperty = true
            }) {
                Image(systemName: "plus")
            }
        }
    }
    
    private func binding(for property: Inspection) -> Binding<Inspection> {
        guard let index = properties.firstIndex(where: { $0.id == property.id }) else {
            fatalError("Property not found")
        }
        return $properties[index]
    }
    
    private func deleteProperties(at offsets: IndexSet) {
        properties.remove(atOffsets: offsets)
    }
    
    private func saveProperties() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(properties) {
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("properties.json")
            try? data.write(to: fileURL)
        }
    }
    
    private static func loadProperties() -> [Inspection] {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("properties.json")
        guard let data = try? Data(contentsOf: fileURL),
              let properties = try? JSONDecoder().decode([Inspection].self, from: data) else { return [] }
        return properties
    }
}