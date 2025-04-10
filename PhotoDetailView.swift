import SwiftUI

struct PhotoDetailView: View {
    @Binding var photoDetail: PhotoDetail
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if let image = PhotoManager.loadImage(from: photoDetail.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else {
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.red)
            }
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .padding()
        }
        .navigationTitle("Photo")
    }
}
