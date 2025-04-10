//
//  EmailComposer.swift
//  Home Inspection
//
//  Created by Peter Marsters on 10/4/2025.
//


import SwiftUI
import MessageUI

struct EmailComposer: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let pdfData: Data
    let propertyNumber: String
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = context.coordinator
        mail.setSubject("Inspection Report: \(propertyNumber)")
        mail.setMessageBody("Attached is the inspection report for property \(propertyNumber).", isHTML: false)
        mail.addAttachmentData(pdfData, mimeType: "application/pdf", fileName: "InspectionReport_\(propertyNumber).pdf")
        return mail
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: EmailComposer
        
        init(_ parent: EmailComposer) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.isPresented = false
        }
    }
}

extension EmailComposer {
    static func canSendMail() -> Bool {
        MFMailComposeViewController.canSendMail()
    }
}