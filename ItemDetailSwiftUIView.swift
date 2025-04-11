import SwiftUI

struct ItemDetailSwiftUIView: View {
    @Binding var item: Item
    @Environment(\.dismiss) var dismiss
    @State private var showingPhotoPicker = false
    @State private var selectedImageData: Data?
    
    private var photoGallery: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(item.photos.indices, id: \.self) { index in
                    if let uiImage = UIImage(data: item.photos[index].image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(item.name)
                    .font(.title)
                    .padding(.top)
                
                TextField("Comments", text: Binding(
                    get: { item.comments.isEmpty ? "Good" : item.comments },
                    set: { item.comments = $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Condition")
                        .font(.headline)
                    ForEach(item.condition.keys.sorted(), id: \.self) { key in
                        Toggle(key, isOn: Binding(
                            get: { item.condition[key] ?? false },
                            set: { item.condition[key] = $0 }
                        ))
                    }
                }
                .padding(.horizontal)
                
                if !item.photos.isEmpty {
                    photoGallery
                } else {
                    Text("No photos yet")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    showingPhotoPicker = true
                }) {
                    Label("Add Photo", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle(item.name)
            .navigationBarItems(trailing: Button("Save") {
                dismiss()
            })
            .sheet(isPresented: $showingPhotoPicker) {
                PhotoPicker(imageData: $selectedImageData)
                    .onChange(of: selectedImageData) { newData in
                        if let data = newData {
                            let newPhoto = PhotoDetail(image: data, dateTaken: Date())
                            item.photos.append(newPhoto)
                            selectedImageData = nil
                        }
                    }
            }
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 0.8) {
                parent.imageData = data
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
