//
//  PropertyDetailView.swift
//  Home Inspection
//
//  Created by Peter Marsters on 10/4/2025.
//


import SwiftUI

struct PropertyDetailView: View {
    @Binding var property: Inspection
    @State private var showingAddRoom = false
    @State private var roomsToDelete: IndexSet?
    @State private var showingDeleteRoomAlert = false
    @State private var showingEmailComposer = false
    @State private var pdfData: Data?
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Property Details")) {
                    TextField("Property Number", text: $property.propertyNumber)
                    TextField("Address", text: $property.address)
                    TextField("Tenant ID", text: $property.tenantID)
                }
            }
            .frame(height: 200)
            
            List {
                Section(header: Text("Rooms")) {
                    ForEach(property.rooms) { room in
                        NavigationLink(value: room) {
                            HStack {
                                Text(room.name ?? room.type)
                                Spacer()
                                if !room.tags.isEmpty {
                                    Text(room.tags.joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .onDelete { offsets in
                        roomsToDelete = offsets
                        showingDeleteRoomAlert = true
                    }
                }
            }
            .navigationDestination(for: Room.self) { room in
                RoomDetailView(room: binding(for: room))
            }
            
            Button("Add Room") {
                showingAddRoom = true
            }
            .padding()
            
            Button("Generate and Email Report") {
                if let data = PDFGenerator.generateReport(for: property) {
                    pdfData = data
                    showingEmailComposer = true
                }
            }
            .padding()
            .disabled(property.rooms.isEmpty)
            
            Spacer()
        }
        .navigationTitle("Property: \(property.propertyNumber)")
        .sheet(isPresented: $showingAddRoom) {
            AddRoomView(rooms: $property.rooms)
        }
        .sheet(isPresented: $showingEmailComposer, onDismiss: {
            pdfData = nil
        }) {
            if EmailComposer.canSendMail(), let pdfData = pdfData {
                EmailComposer(isPresented: $showingEmailComposer, pdfData: pdfData, propertyNumber: property.propertyNumber)
            } else {
                Text("Email is not configured on this device.")
            }
        }
        .alert("Delete Room", isPresented: $showingDeleteRoomAlert, presenting: roomsToDelete) { offsets in
            Button("Delete", role: .destructive) {
                deleteRooms(at: offsets)
                roomsToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                roomsToDelete = nil
            }
        } message: { _ in
            Text("Are you sure you want to delete this room? This action cannot be undone.")
        }
    }
    
    private func binding(for room: Room) -> Binding<Room> {
        guard let index = property.rooms.firstIndex(where: { $0.id == room.id }) else {
            fatalError("Room not found")
        }
        return $property.rooms[index]
    }
    
    private func deleteRooms(at offsets: IndexSet) {
        property.rooms.remove(atOffsets: offsets)
    }
}
