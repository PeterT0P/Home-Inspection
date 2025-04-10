import Foundation

struct PhotoDetail: Identifiable, Codable, Hashable {
    let id = UUID()
    var path: String
    
    enum CodingKeys: String, CodingKey {
        case path
    }
}

struct Item: Identifiable, Codable, Hashable, Equatable {
    let id = UUID()
    var name: String
    var photos: [PhotoDetail]
    var comments: String
    var condition: [String: Bool]
    
    enum CodingKeys: String, CodingKey {
        case name, photos, comments, condition
    }
    
    init(name: String, photos: [PhotoDetail] = [], comments: String = "", condition: [String: Bool] = ["Clean": true, "Undamaged": true, "Working": true]) {
        self.name = name
        self.photos = photos
        self.comments = comments
        self.condition = condition
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
