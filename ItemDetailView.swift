import SwiftUI

struct ItemDetailView: View {
    @Binding var item: Item
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var selectedPhoto: PhotoDetail?
    @State private var showingPhotoDetail = false
    @State private var photoToDelete: PhotoDetail?
    @State private var showingDeletePhotoAlert = false
    @FocusState private var isTextEditorFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Item Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Item: \(item.name)")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextEditor(text: $item.comments)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        .padding(.horizontal)
                        .focused($isTextEditorFocused)
                    
                    Button(action: {
                        showingCamera = true
                    }) {
                        Label("Take Photo", systemImage: "camera")
                            .foregroundColor(.blue)
                            .padding(.horizontal)
                    }
                }
                
                // Condition Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Condition")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ToggleTag(label: "Clean", isOn: conditionBinding(for: "Clean"))
                        .padding(.horizontal)
                    ToggleTag(label: "Undamaged", isOn: conditionBinding(for: "Undamaged"))
                        .padding(.horizontal)
                    ToggleTag(label: "Working", isOn: conditionBinding(for: "Working"))
                        .padding(.horizontal)
                }
                
                // Photos Section
                VStack {
                    if item.photos.isEmpty {
                        Text("No photos yet")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                                ForEach(item.photos) { photoDetail in
                                    VStack {
                                        if let image = PhotoManager.loadImage(from: photoDetail.path) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(8)
                                                .onTapGesture {
                                                    selectedPhoto = photoDetail
                                                    showingPhotoDetail = true
                                                }
                                        } else {
                                            Image(systemName: "exclamationmark.triangle")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 100, height: 100)
                                                .foregroundColor(.red)
                                        }
                                        
                                        Button(action: {
                                            photoToDelete = photoDetail
                                            showingDeletePhotoAlert = true
                                        }) {
                                            Text("Delete")
                                                .foregroundColor(.red)
                                                .font(.caption)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding()
                
                Spacer(minLength: 100) // Ensure some scrollable space
            }
            .padding(.top)
        }
        .onTapGesture {
            isTextEditorFocused = false // Dismiss keyboard on tap
        }
        .ignoresSafeArea(.keyboard)
        .navigationTitle(item.name)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isTextEditorFocused = false
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker(image: $capturedImage) { image in
                let resizedImage = resizeImage(image, maxDimension: 800)
                if let path = PhotoManager.savePhoto(image: resizedImage, roomName: item.name) {
                    item.photos.append(PhotoDetail(path: path))
                } else {
                    errorMessage = "Failed to save photo: Check storage space or permissions."
                    showingError = true
                }
            }
        }
        .sheet(isPresented: $showingPhotoDetail) {
            if let selectedPhoto = selectedPhoto {
                PhotoDetailView(photoDetail: binding(for: selectedPhoto))
            }
        }
        .alert("Delete Photo", isPresented: $showingDeletePhotoAlert, presenting: photoToDelete) { photo in
            Button("Delete", role: .destructive) {
                deletePhoto(photo)
                photoToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                photoToDelete = nil
            }
        } message: { _ in
            Text("Are you sure you want to delete this photo? This action cannot be undone.")
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
    }
    
    private func binding(for photoDetail: PhotoDetail) -> Binding<PhotoDetail> {
        guard let index = item.photos.firstIndex(where: { $0.id == photoDetail.id }) else {
            fatalError("Photo not found")
        }
        return $item.photos[index]
    }
    
    private func conditionBinding(for key: String) -> Binding<Bool> {
        Binding(
            get: { item.condition[key] ?? true },
            set: { newValue in item.condition[key] = newValue }
        )
    }
    
    private func resizeImage(_ image: UIImage, maxDimension: Int) -> UIImage {
        let originalSize = image.size
        let maxSide = max(originalSize.width, originalSize.height)
        if maxSide <= CGFloat(maxDimension) { return image }
        
        let scaleFactor = CGFloat(maxDimension) / maxSide
        let newSize = CGSize(width: originalSize.width * scaleFactor, height: originalSize.height * scaleFactor)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    private func deletePhoto(_ photoDetail: PhotoDetail) {
        if let index = item.photos.firstIndex(where: { $0.id == photoDetail.id }) {
            PhotoManager.deletePhoto(at: item.photos[index].path)
            item.photos.remove(at: index)
        }
    }
}

struct ToggleTag: View {
    let label: String
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            isOn.toggle()
        }) {
            HStack {
                Text(label)
                Spacer()
                Text(isOn ? "Yes" : "No")
                    .foregroundColor(isOn ? .green : .red)
            }
        }
    }
}
