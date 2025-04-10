//
//  AddPropertyView.swift
//  Home Inspection
//
//  Created by Peter Marsters on 10/4/2025.
//


import SwiftUI

struct AddPropertyView: View {
    @Binding var properties: [Inspection]
    @State private var propertyNumber = ""
    @State private var address = ""
    @State private var tenantID = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Property Details")) {
                    TextField("Property Number", text: $propertyNumber)
                    TextField("Address", text: $address)
                    TextField("Tenant ID", text: $tenantID)
                }
            }
            .navigationTitle("Add Property")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newProperty = Inspection(
                            propertyNumber: propertyNumber,
                            address: address,
                            tenantID: tenantID,
                            rooms: []
                        )
                        properties.append(newProperty)
                        dismiss()
                    }
                    .disabled(propertyNumber.isEmpty || address.isEmpty)
                }
            }
        }
    }
}