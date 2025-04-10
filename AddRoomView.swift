//
//  AddRoomView.swift
//  Home Inspection
//
//  Created by Peter Marsters on 10/4/2025.
//


import SwiftUI

struct AddRoomView: View {
    @Binding var rooms: [Room]
    @State private var selectedRoomType = "Entrance"
    @State private var customRoomName = ""
    @Environment(\.dismiss) var dismiss
    
    let predefinedRooms = ["Entrance", "Hallway", "Bedrooms", "Kitchen", "Laundry", "Lounge"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Room Type")) {
                    Picker("Room Type", selection: $selectedRoomType) {
                        ForEach(predefinedRooms, id: \.self) { room in
                            Text(room).tag(room)
                        }
                        Text("Custom").tag("Custom")
                    }
                }
                
                if selectedRoomType == "Custom" {
                    Section(header: Text("Custom Room Name")) {
                        TextField("Enter room name", text: $customRoomName)
                    }
                }
            }
            .navigationTitle("Add Room")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newRoom = Room(
                            type: selectedRoomType,
                            name: selectedRoomType == "Custom" ? customRoomName : nil,
                            tags: [],
                            items: []
                        )
                        rooms.append(newRoom)
                        dismiss()
                    }
                    .disabled(selectedRoomType == "Custom" && customRoomName.isEmpty)
                }
            }
        }
    }
}
