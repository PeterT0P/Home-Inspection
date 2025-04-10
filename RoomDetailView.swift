import SwiftUI

struct RoomDetailView: View {
    @Binding var room: Room
    @State private var showingAddItemType = false
    @State private var newItemType = ""
    @State private var showingEditItemType = false
    @State private var itemTypeToEdit: String? = nil
    @State private var editedItemTypeName = ""
    @State private var showingDeleteError = false
    @State private var deleteErrorMessage = ""
    
    // Define room-specific item types (initial test data)
    @State private var roomItemTypes: [String: [String]] = [
        "Entry": ["Doors/walls/ceiling", "Fan/Light Fittings", "Floor/floor coverings", "Cupboards/drawers"],
        "Bedroom": ["Doors/walls/ceiling", "Windows/screens", "Blinds/curtains", "Fan/Light Fittings", "Floor/floor coverings", "Wardrobe/drawers/shelves", "Power points", "Air conditioner", "Smoke Alarms"],
        "Kitchen": ["Doors/walls/ceiling", "Windows/screens", "Blinds/curtains", "Fan/Light Fittings", "Floor/floor coverings", "Cupboards/drawers", "Sink", "Appliances", "Power points"],
        "Lounge": ["Doors/walls/ceiling", "Windows/screens", "Blinds/curtains", "Fan/Light Fittings", "Floor/floor coverings", "Power points", "Air conditioner", "Smoke Alarms"]
    ]
    
    // State for the current room's item types
    @State private var itemTypesForCurrentRoom: [String]
    
    init(room: Binding<Room>) {
        self._room = room
        let initialRoomType = room.wrappedValue.type
        let initialItemTypes = [
            "Entry": ["Doors/walls/ceiling", "Fan/Light Fittings", "Floor/floor coverings", "Cupboards/drawers"],
            "Bedroom": ["Doors/walls/ceiling", "Windows/screens", "Blinds/curtains", "Fan/Light Fittings", "Floor/floor coverings", "Wardrobe/drawers/shelves", "Power points", "Air conditioner", "Smoke Alarms"],
            "Kitchen": ["Doors/walls/ceiling", "Windows/screens", "Blinds/curtains", "Fan/Light Fittings", "Floor/floor coverings", "Cupboards/drawers", "Sink", "Appliances", "Power points"],
            "Lounge": ["Doors/walls/ceiling", "Windows/screens", "Blinds/curtains", "Fan/Light Fittings", "Floor/floor coverings", "Power points", "Air conditioner", "Smoke Alarms"]
        ]
        self._roomItemTypes = State(initialValue: initialItemTypes)
        self._itemTypesForCurrentRoom = State(initialValue: initialItemTypes[initialRoomType] ?? ["Doors/walls/ceiling", "Windows/screens", "Floor/floor coverings"])
    }
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Available Item Types")) {
                    ForEach(itemTypesForCurrentRoom, id: \.self) { itemType in
                        NavigationLink(value: itemType) {
                            HStack {
                                Text(itemType)
                                Spacer()
                                // Show the number of photos for this item type
                                let photoCount = room.items.first(where: { $0.name == itemType })?.photos.count ?? 0
                                Text("Photos: \(photoCount)")
                                    .foregroundColor(photoCount > 0 ? .gray : .black) // Gray out if completed
                                    .font(.caption)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteItemType(itemType)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        showingAddItemType = true
                    }) {
                        Label("Add New Item Type", systemImage: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationDestination(for: String.self) { itemType in
                ItemDetailView(item: itemBinding(for: itemType))
            }
            
            Spacer()
        }
        .navigationTitle(room.name ?? room.type)
        .sheet(isPresented: $showingAddItemType) {
            VStack {
                Text("Add New Item Type for \(room.name ?? room.type)")
                    .font(.headline)
                    .padding()
                
                TextField("Enter item type (e.g., Power points)", text: $newItemType)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack {
                    Button("Cancel") {
                        newItemType = ""
                        showingAddItemType = false
                    }
                    .padding()
                    
                    Button("Add") {
                        if !newItemType.isEmpty {
                            // Update roomItemTypes
                            var updatedRoomItemTypes = roomItemTypes
                            if var existingItems = updatedRoomItemTypes[room.type] {
                                existingItems.append(newItemType)
                                updatedRoomItemTypes[room.type] = existingItems
                            } else {
                                updatedRoomItemTypes[room.type] = [newItemType]
                            }
                            roomItemTypes = updatedRoomItemTypes
                            
                            // Update itemTypesForCurrentRoom
                            itemTypesForCurrentRoom.append(newItemType)
                            
                            print("After adding '\(newItemType)':")
                            print("roomItemTypes[\(room.type)]: \(roomItemTypes[room.type] ?? [])")
                            print("itemTypesForCurrentRoom: \(itemTypesForCurrentRoom)")
                            
                            newItemType = ""
                            showingAddItemType = false
                        }
                    }
                    .padding()
                    .disabled(newItemType.isEmpty)
                }
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showingEditItemType) {
            VStack {
                Text("Edit Item Type for \(room.name ?? room.type)")
                    .font(.headline)
                    .padding()
                
                TextField("Edit item type", text: $editedItemTypeName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack {
                    Button("Cancel") {
                        editedItemTypeName = ""
                        itemTypeToEdit = nil
                        showingEditItemType = false
                    }
                    .padding()
                    
                    Button("Save") {
                        if let oldItemType = itemTypeToEdit, !editedItemTypeName.isEmpty {
                            // Update roomItemTypes
                            var updatedRoomItemTypes = roomItemTypes
                            if var existingItems = updatedRoomItemTypes[room.type] {
                                if let index = existingItems.firstIndex(of: oldItemType) {
                                    existingItems[index] = editedItemTypeName
                                    updatedRoomItemTypes[room.type] = existingItems
                                }
                            }
                            roomItemTypes = updatedRoomItemTypes
                            
                            // Update itemTypesForCurrentRoom
                            if let index = itemTypesForCurrentRoom.firstIndex(of: oldItemType) {
                                itemTypesForCurrentRoom[index] = editedItemTypeName
                            }
                            
                            // Update any existing Item in room.items
                            if let itemIndex = room.items.firstIndex(where: { $0.name == oldItemType }) {
                                room.items[itemIndex].name = editedItemTypeName
                            }
                            
                            print("After editing '\(oldItemType)' to '\(editedItemTypeName)':")
                            print("roomItemTypes[\(room.type)]: \(roomItemTypes[room.type] ?? [])")
                            print("itemTypesForCurrentRoom: \(itemTypesForCurrentRoom)")
                            
                            editedItemTypeName = ""
                            itemTypeToEdit = nil
                            showingEditItemType = false
                        }
                    }
                    .padding()
                    .disabled(editedItemTypeName.isEmpty)
                }
                
                Spacer()
            }
            .padding()
        }
        .alert("Cannot Delete Item Type", isPresented: $showingDeleteError) {
            Button("OK") {
                showingDeleteError = false
                deleteErrorMessage = ""
            }
        } message: {
            Text(deleteErrorMessage)
        }
        .onChange(of: room.type) { newType in
            itemTypesForCurrentRoom = roomItemTypes[newType] ?? ["Doors/walls/ceiling", "Windows/screens", "Floor/floor coverings"]
            print("Room type changed to \(newType), itemTypesForCurrentRoom: \(itemTypesForCurrentRoom)")
        }
    }
    
    private func deleteItemType(_ itemType: String) {
        // Check if the item type is in use
        if room.items.contains(where: { $0.name == itemType }) {
            deleteErrorMessage = "Cannot delete '\(itemType)' because it is in use. Please remove the item from the inspection first."
            showingDeleteError = true
            return
        }
        
        // Update roomItemTypes
        var updatedRoomItemTypes = roomItemTypes
        if var existingItems = updatedRoomItemTypes[room.type] {
            existingItems.removeAll { $0 == itemType }
            updatedRoomItemTypes[room.type] = existingItems
        }
        roomItemTypes = updatedRoomItemTypes
        
        // Update itemTypesForCurrentRoom
        itemTypesForCurrentRoom.removeAll { $0 == itemType }
        
        print("After deleting '\(itemType)':")
        print("roomItemTypes[\(room.type)]: \(roomItemTypes[room.type] ?? [])")
        print("itemTypesForCurrentRoom: \(itemTypesForCurrentRoom)")
    }
    
    private func itemBinding(for itemType: String) -> Binding<Item> {
        if let existingItemIndex = room.items.firstIndex(where: { $0.name == itemType }) {
            return $room.items[existingItemIndex]
        } else {
            var newItem = Item(name: itemType)
            let binding = Binding<Item>(
                get: { room.items.first(where: { $0.name == itemType }) ?? newItem },
                set: { updatedItem in
                    if let index = room.items.firstIndex(where: { $0.name == itemType }) {
                        room.items[index] = updatedItem
                    } else {
                        room.items.append(updatedItem)
                    }
                    newItem = updatedItem // Update local copy
                }
            )
            room.items.append(newItem) // Append immediately
            return binding
        }
    }
}
