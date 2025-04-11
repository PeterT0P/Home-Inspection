import SwiftUI

struct RoomDetailView: View {
    @Binding var room: Room
    
    private var roomInfoView: some View {
        VStack {
            TextField("Room Type", text: $room.type)
                .textFieldStyle(.roundedBorder)
            TextField("Room Name", text: Binding<String>(
                get: { room.name ?? "" },
                set: { room.name = $0 }
            ))
            .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
    
    private var tagsView: some View {
        Section(header: Text("Tags")) {
            ForEach($room.tags, id: \.self) { $tag in
                TextField("Tag", text: $tag)
            }
        }
    }
    
    private var itemsView: some View {
        Section(header: Text("Items")) {
            ForEach($room.items) { $item in
                NavigationLink(destination: ItemDetailSwiftUIView(item: $item)) {
                    Text(item.name)
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                roomInfoView
                List {
                    tagsView
                    itemsView
                }
                Button("Add Item") {
                    room.items.append(Item(name: "New Item"))
                }
                .padding()
            }
            .navigationTitle(room.name ?? room.type)
        }
    }
}
