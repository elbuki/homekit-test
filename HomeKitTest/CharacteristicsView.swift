//
//  CharacteristicsView.swift
//  HomeKitTest
//
//  Created by Marco Carmona on 6/22/23.
//

import SwiftUI
import HomeKit

struct CharacteristicsView: View {
    
    @ObservedObject var model: HomeStore
    
    @State var hueSlider: Float = 0
    @State var brightnessSlider: Float = 0
    
    let homeID: UUID
    let accessoryID: UUID
    let serviceID: UUID
    let serviceName: String
    
    var body: some View {
        List {
            Section(
                content: {
                    ForEach(model.characteristics, id: \.uniqueIdentifier) { characteristic in
                        NavigationLink(value: characteristic) {
                            Text(characteristic.localizedDescription)
                        }
                        .navigationDestination(for: HMCharacteristic.self) {
                            Text($0.metadata?.description ?? "No Metadata found")
                        }
                    }
                },
                header: {
                    HStack {
                        Text("\(serviceName) characteristics")
                    }
                }
            )

            Section(
                content: {
                    if serviceHasPowerStateCharacteristic(characteristics: model.characteristics) {
                        Button("Read Characteristics State") {
                            try! model.readCharacteristicsValues(serviceID: serviceID)
                        }
                        
                        Text("Power state: \(model.powerState?.description ?? "no value found")")
                        Text("Hue state: \(model.hueValue?.description ?? "no value found")")
                        Text("Brightness state: \(model.brightnessValue?.description ?? "no value found")")
                    }
                },
                header: {
                    HStack {
                        Text("\(serviceName) characteristic values")
                    }
                }
            )
            
            Section(
                content: {
                    VStack {
                        Button(
                            "Toggle power",
                            action: {
                                let state = model.powerState ?? false
                                
                                model.setCharacteristicValue(
                                    characteristic: model.characteristics.first(
                                        where: { $0.localizedDescription == "Power State" }
                                    ).unsafelyUnwrapped,
                                    value: !state
                                )
                            }
                        )
                        
                        Slider(value: $hueSlider, in: 0...360) { _ in
                            model.setCharacteristicValue(characteristic: model.characteristics.first(where: {$0.localizedDescription == "Hue"}).unsafelyUnwrapped, value: Int(hueSlider))
                        }
                        Slider(value: $brightnessSlider, in: 0...100) { _ in
                            model.setCharacteristicValue(characteristic: model.characteristics.first(where: {$0.localizedDescription == "Brightness"}).unsafelyUnwrapped, value: Int(brightnessSlider))
                        }
                    }
                },
                header: {
                    Text("\(serviceName) characteristics control")
                }
            )
        }
        .onAppear {
            do {
                try model.findCharacteristics(
                    accessoryID: accessoryID,
                    homeID: homeID,
                    serviceID: serviceID
                )
                
                try model.readCharacteristicsValues(serviceID: serviceID)
            } catch {
                print("Could not find characteristics: \(error.localizedDescription)")
            }
        }
    }
    
    func serviceHasPowerStateCharacteristic(characteristics: [HMCharacteristic]) -> Bool {
        return characteristics.first(where: { $0.localizedDescription == "Power State" }) != nil
    }
    
}
