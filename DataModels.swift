import Foundation

struct PhotoDetail: Identifiable, Codable {
    let id: UUID
    var image: Data
    var dateTaken: Date
    
    init(id: UUID = UUID(), image: Data, dateTaken: Date) {
        self.id = id
        self.image = image
        self.dateTaken = dateTaken
    }
}

struct Item: Identifiable, Codable, Hashable, Equatable {
    var id: UUID
    var name: String
    var comments: String = ""
    var condition: [String: Bool] = ["Good": true, "Fair": false, "Poor": false]
    var photos: [PhotoDetail] = []
    
    init(id: UUID = UUID(), name: String, photos: [PhotoDetail] = [], comments: String = "", condition: [String: Bool] = ["Clean": true, "Undamaged": true, "Working": true]) {
        self.id = id
        self.name = name
        self.photos = photos
        self.comments = comments
        self.condition = condition
    }
    
    static func ==(lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Room: Identifiable, Codable, Hashable, Equatable {
    let id = UUID()
    var type: String
    var name: String?
    var tags: [String]
    var items: [Item]
    
    enum CodingKeys: String, CodingKey {
        case type, name, tags, items
    }
}

struct Inspection: Identifiable, Codable, Equatable, Hashable {
    let id = UUID()
    var propertyNumber: String
    var address: String
    var tenantID: String
    var rooms: [Room]
    
    enum CodingKeys: String, CodingKey {
        case propertyNumber, address, tenantID, rooms
    }
}
