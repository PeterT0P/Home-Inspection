//
//  PhotoManager.swift
//  Home Inspection
//
//  Created by Peter Marsters on 10/4/2025.
//


import UIKit

class PhotoManager {
    static func savePhoto(image: UIImage, roomName: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL, options: .atomic)
            return fileURL.path
        } catch {
            print("Error saving photo: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func loadImage(from path: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("Error loading image from \(path): \(error)")
            return nil
        }
    }
    
    static func deletePhoto(at path: String) {
        let fileManager = FileManager.default
        let fileURL = URL(fileURLWithPath: path)
        do {
            try fileManager.removeItem(at: fileURL)
            print("Deleted photo at: \(path)")
        } catch {
            print("Error deleting photo: \(error)")
        }
    }
}