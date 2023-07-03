//
//  AccessoryView.swift
//  HomeKitTest
//
//  Created by Marco Carmona on 6/22/23.
//

import SwiftUI
import HomeKit

struct AccessoriesView: View {
    
    @ObservedObject var model: HomeStore
    
    let homeID: UUID
    
    var body: some View {
        List {
            Section(
                content: {
                    ForEach(model.accessories, id: \.uniqueIdentifier) { accessory in
                        NavigationLink(value: accessory) {
                            Text(accessory.name)
                        }
                        .navigationDestination(for: HMAccessory.self) {
                            ServicesView(
                                model: model,
                                homeID: homeID,
                                accessoryID: $0.uniqueIdentifier,
                                accesoryName: $0.name
                            )
                        }
                    }
                },
                header: {
                    HStack {
                        Text("My Accessories")
                    }
                }
            )
        }
        .onAppear {
            do {
                try model.findAccessories(homeID: homeID)
            } catch {
                print("Could not find accessories: \(error.localizedDescription)")
            }
        }
    }
    
}
