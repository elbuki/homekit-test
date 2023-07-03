//
//  ServicesView.swift
//  HomeKitTest
//
//  Created by Marco Carmona on 6/22/23.
//

import SwiftUI
import HomeKit

struct ServicesView: View {
    
    @ObservedObject var model: HomeStore
    
    let homeID: UUID
    let accessoryID: UUID
    let accesoryName: String
    
    var body: some View {
        List {
            Section(
                content: {
                    ForEach(model.services, id: \.uniqueIdentifier) { service in
                        NavigationLink(value: service) {
                            Text(service.localizedDescription)
                        }
                        .navigationDestination(for: HMService.self) {
                            CharacteristicsView(
                                model: model,
                                homeID: homeID,
                                accessoryID: accessoryID,
                                serviceID: $0.uniqueIdentifier,
                                serviceName: $0.name
                            )
                        }
                    }
                },
                header: {
                    HStack {
                        Text("\(accesoryName) services")
                    }
                }
            )
        }
        .onAppear {
            do {
                try model.findServices(accessoryID: accessoryID, homeID: homeID)
            } catch {
                print("Could not find services: \(error.localizedDescription)")
            }
        }
    }
    
}
