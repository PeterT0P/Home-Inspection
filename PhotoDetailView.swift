import SwiftUI

struct PhotoDetailView: View {
    @Binding var photoDetail: PhotoDetail
    
    var body: some View {
        if let uiImage = UIImage(data: photoDetail.image) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Text("No Image")
        }
    }
}
