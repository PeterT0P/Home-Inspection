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
    
    @State private var roomItemTypes: [String: [String]] = [
        "Entry": ["Doors/walls/ceiling", "Fan/Light Fittings", "Floor/floor coverings", "Cupboards/drawers"],
        "Bedroom": ["Doors/walls/ceiling", "Windows/screens", "Blinds/curtains", "Fan/Light Fittings", "Floor/floor coverings", "Wardrobe/drawers/shelves", "Power points", "Air conditioner", "Smoke Alarms"],
        "Kitchen": ["Doors/walls/ceiling", "Windows/screens", "Blinds/curtains", "Fan/Light Fittings", "Floor/floor coverings", "Cupboards/drawers", "Sink", "Appliances", "Power points"],
        "Lounge": ["Doors/walls/ceiling", "Windows/screens", "Blinds/curtains", "Fan/Light Fittings", "Floor/floor coverings", "Power points", "Air conditioner", "Smoke Alarms"]
    ]
    
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
    
    // Function to calculate photo count for an item type
    private func photoCount(for itemType: String) -> Int {
        room.items.first(where: { $0.name == itemType })?.photos.count ?? 0
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
                                let count = photoCount(for: itemType) // Use function
                                Text("Photos: \(count)")
                                    .foregroundColor(count > 0 ? .gray : .black)
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
                            var updatedRoomItemTypes = roomItemTypes
                            if var existingItems = updatedRoomItemTypes[room.type] {
                                existingItems.append(newItemType)
                                updatedRoomItemTypes[room.type] = existingItems
                            } else {
                                updatedRoomItemTypes[room.type] = [newItemType]
                            }
                            roomItemTypes = updatedRoomItemTypes
                            itemTypesForCurrentRoom.append(newItemType)
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
                            var updatedRoomItemTypes = roomItemTypes
                            if var existingItems = updatedRoomItemTypes[room.type] {
                                if let index = existingItems.firstIndex(of: oldItemType) {
                                    existingItems[index] = editedItemTypeName
                                    updatedRoomItemTypes[room.type] = existingItems
                                }
                            }
                            roomItemTypes = updatedRoomItemTypes
                            if let index = itemTypesForCurrentRoom.firstIndex(of: oldItemType) {
                                itemTypesForCurrentRoom[index] = editedItemTypeName
                            }
                            if let itemIndex = room.items.firstIndex(where: { $0.name == oldItemType }) {
                                room.items[itemIndex].name = editedItemTypeName
                            }
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
        }
    }
    
    private func deleteItemType(_ itemType: String) {
        if room.items.contains(where: { $0.name == itemType }) {
            deleteErrorMessage = "Cannot delete '\(itemType)' because it is in use. Please remove the item from the inspection first."
            showingDeleteError = true
            return
        }
        
        var updatedRoomItemTypes = roomItemTypes
        if var existingItems = updatedRoomItemTypes[room.type] {
            existingItems.removeAll { $0 == itemType }
            updatedRoomItemTypes[room.type] = existingItems
        }
        roomItemTypes = updatedRoomItemTypes
        itemTypesForCurrentRoom.removeAll { $0 == itemType }
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
                    newItem = updatedItem
                }
            )
            room.items.append(newItem)
            return binding
        }
    }
}
