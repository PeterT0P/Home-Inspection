import UIKit
import PDFKit

class PDFGenerator {
    static func generateReport(for property: Inspection) -> Data? {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595.2, height: 841.8)) // A4 size in points
        var pageNumber = 1
        let data = renderer.pdfData { context in
            context.beginPage()
            print("Starting to draw table on page \(pageNumber)")
            var currentY = drawTable(context: context, property: property, startY: 50, pageNumber: &pageNumber)
            
            while currentY > context.pdfContextBounds.height - 50 && !property.rooms.isEmpty {
                context.beginPage()
                pageNumber += 1
                print("Continuing table on new page \(pageNumber)")
                currentY = drawTable(context: context, property: property, startY: 50, pageNumber: &pageNumber, continuation: true)
            }
            
            let photos = property.rooms.flatMap { room in
                room.items.flatMap { item in
                    item.photos.map { (photo: $0, room: room, item: item) }
                }
            }
            var currentPhotos: [(photo: PhotoDetail, room: Room, item: Item)] = []
            for (index, photoData) in photos.enumerated() {
                currentPhotos.append(photoData)
                if currentPhotos.count == 9 || index == photos.count - 1 {
                    context.beginPage()
                    print("Drawing photo grid on page \(pageNumber + 1)")
                    drawPhotoGrid(context: context, photosData: currentPhotos, pageNumber: &pageNumber)
                    currentPhotos.removeAll()
                }
            }
        }
        return data
    }
    
    private static func drawTable(context: UIGraphicsPDFRendererContext, property: Inspection, startY: CGFloat, pageNumber: inout Int, continuation: Bool = false) -> CGFloat {
        _ = context.pdfContextBounds // Replaced let pageRect
        var currentY = startY
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ]
        let roomAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        let cellAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ]
        let redCellAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.red
        ]
        let highlightedCellAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.black,
            .backgroundColor: UIColor.orange
        ]
        
        let columnWidths: [CGFloat] = [150, 30, 30, 30, 200, 50, 80]
        let columnXPositions: [CGFloat] = [40, 190, 220, 250, 280, 480, 530]
        
        if !continuation {
            let title = "Inspection Report: \(property.propertyNumber)"
            let titleString = NSAttributedString(string: title, attributes: titleAttributes)
            titleString.draw(at: CGPoint(x: 40, y: currentY))
            print("Drew title at y: \(currentY)")
            currentY += 20
            
            let agentSection = "Agent section\nEach item has been given a column description of 'clean', 'undamaged', 'working'. Tick each column that applies to the item and make any necessary comments."
            let tenantSection = "Tenant section\nIf you disagree with the agent's report of an item, make a comment in this section. You should also note anything which seems unsafe or may be an injury risk."
            let agentSectionString = NSAttributedString(string: agentSection, attributes: cellAttributes)
            let tenantSectionString = NSAttributedString(string: tenantSection, attributes: cellAttributes)
            
            agentSectionString.draw(in: CGRect(x: 40, y: currentY, width: 250, height: 40))
            tenantSectionString.draw(in: CGRect(x: 300, y: currentY, width: 250, height: 40))
            print("Drew section headers at y: \(currentY)")
            currentY += 40
            
            let headers = ["", "Cln", "Udg", "Wkg", "Agent comments\nCln = Clean, Udg = Undamaged, Wkg = Working", "Tenant agrees", "Tenant comments"]
            for (index, header) in headers.enumerated() {
                let headerString = NSAttributedString(string: header, attributes: headerAttributes)
                headerString.draw(in: CGRect(x: columnXPositions[index], y: currentY, width: columnWidths[index], height: 20))
            }
            print("Drew table header at y: \(currentY)")
            currentY += 20
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 40, y: currentY))
            path.addLine(to: CGPoint(x: 570, y: currentY))
            path.lineWidth = 1.0
            UIColor.black.setStroke()
            path.stroke()
            print("Drew header underline at y: \(currentY)")
            currentY += 5
        }
        
        let roomsToDraw = continuation ? Array(property.rooms.dropFirst(max(0, property.rooms.count - (Int((context.pdfContextBounds.height - 50) / 30))))) : property.rooms
        
        for room in roomsToDraw {
            let roomName = (room.name ?? room.type).uppercased()
            let roomString = NSAttributedString(string: roomName, attributes: roomAttributes)
            roomString.draw(at: CGPoint(x: 40, y: currentY))
            print("Drawing room: \(roomName) at y: \(currentY)")
            currentY += 15
            
            for item in room.items {
                if currentY > context.pdfContextBounds.height - 50 {
                    print("Need new page, currentY: \(currentY)")
                    return currentY
                }
                
                let rowItems = [
                    item.name,
                    item.condition["Clean"] == true ? "Y" : "N",
                    item.condition["Undamaged"] == true ? "Y" : "N",
                    item.condition["Working"] == true ? "Y" : "N",
                    formatAgentComments(item: item, pageNumber: pageNumber),
                    "",
                    ""
                ]
                
                let highlightKeywords = ["GENERAL WEAR", "TENANT CLEANING", "OWNER MAINTENANCE"]
                let shouldHighlight = highlightKeywords.contains { keyword in
                    rowItems[4].uppercased().contains(keyword)
                }
                
                for (index, cell) in rowItems.enumerated() {
                    let attributes: [NSAttributedString.Key: Any]
                    if index == 4 && shouldHighlight {
                        attributes = highlightedCellAttributes
                    } else if index >= 1 && index <= 3 && cell == "N" {
                        attributes = redCellAttributes
                    } else {
                        attributes = cellAttributes
                    }
                    
                    let cellString = NSAttributedString(string: cell, attributes: attributes)
                    cellString.draw(in: CGRect(x: columnXPositions[index], y: currentY, width: columnWidths[index], height: 20))
                }
                print("Drew item: \(item.name) at y: \(currentY)")
                currentY += 15
                
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 40, y: currentY))
                path.addLine(to: CGPoint(x: 570, y: currentY))
                path.lineWidth = 0.5
                UIColor.gray.setStroke()
                path.stroke()
                currentY += 5
            }
            
            currentY += 10
        }
        
        print("Finished drawing table, final y: \(currentY)")
        return currentY
    }
    
    private static func formatAgentComments(item: Item, pageNumber: Int) -> String {
        var comments = item.comments.isEmpty ? "As Per Entry" : item.comments
        let photoCount = item.photos.count
        if photoCount > 0 {
            comments += " (\(photoCount) photo\(photoCount == 1 ? "" : "s"), page \(pageNumber + 1))"
        }
        return comments
    }
    
    private static func drawPhotoGrid(context: UIGraphicsPDFRendererContext, photosData: [(photo: PhotoDetail, room: Room, item: Item)], pageNumber: inout Int) {
        _ = context.pdfContextBounds // Replaced let pageRect
        let maxWidth: CGFloat = 158.4
        let maxHeight: CGFloat = 200
        let spacing: CGFloat = 20
        let startX: CGFloat = 40
        let startY: CGFloat = 50
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ]
        
        for (index, photoData) in photosData.enumerated() {
            let row = index / 3
            let col = index % 3
            let x = startX + CGFloat(col) * (maxWidth + spacing)
            let y = startY + CGFloat(row) * (maxHeight + 40)
            
            if let image = UIImage(data: photoData.photo.image) {
                let aspectRatio = image.size.width / image.size.height
                var scaledWidth: CGFloat
                var scaledHeight: CGFloat
                
                if aspectRatio > 1 {
                    scaledWidth = min(maxWidth, image.size.width)
                    scaledHeight = scaledWidth / aspectRatio
                    if scaledHeight > maxHeight {
                        scaledHeight = maxHeight
                        scaledWidth = scaledHeight * aspectRatio
                    }
                } else {
                    scaledHeight = min(maxHeight, image.size.height)
                    scaledWidth = scaledHeight * aspectRatio
                    if scaledWidth > maxWidth {
                        scaledWidth = maxWidth
                        scaledHeight = scaledWidth / aspectRatio
                    }
                }
                
                let photoRect = CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
                image.draw(in: photoRect)
                
                let roomName = (photoData.room.name ?? photoData.room.type).uppercased()
                let caption = "\(roomName)\n\(photoData.item.name)"
                
                let captionString = NSAttributedString(string: caption, attributes: textAttributes)
                captionString.draw(at: CGPoint(x: x, y: y + scaledHeight + 5))
            }
        }
        pageNumber += 1
    }
}
