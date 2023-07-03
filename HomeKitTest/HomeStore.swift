//
//  HomeStore.swift
//  HomeKitTest
//
//  Created by Marco Carmona on 6/22/23.
//

import HomeKit

class HomeStore: NSObject, ObservableObject, HMHomeManagerDelegate {
    
    enum UnexpectedErrorCase: Error {
        case homeNotFound
        case accessoryNotFound
        case serviceNotFound
    }
    
    @Published var homes: [HMHome] = []
    @Published var accessories: [HMAccessory] = []
    @Published var services: [HMService] = []
    @Published var characteristics: [HMCharacteristic] = []
    
    @Published var readingData = false
    
    @Published var powerState: Bool?
    @Published var hueValue: Int?
    @Published var brightnessValue: Int?
    
    private var manager: HMHomeManager!
    
    override init() {
        super.init()
        
        if manager == nil {
            manager = .init()
            manager.delegate = self
        }
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        print("Updated homes!")
        
        homes = manager.homes
    }
    
    func findAccessories(homeID: UUID) throws {
        guard let foundHome = homes.first(where: { $0.uniqueIdentifier == homeID }) else {
            throw UnexpectedErrorCase.homeNotFound
        }
        
        accessories = foundHome.accessories
    }
    
    func findServices(accessoryID: UUID, homeID: UUID) throws {
        guard let foundHome = homes.first(where: { $0.uniqueIdentifier == homeID }) else {
            throw UnexpectedErrorCase.homeNotFound
        }
        
        guard let foundAccessory = foundHome.accessories.first(where: { $0.uniqueIdentifier == accessoryID }) else {
            throw UnexpectedErrorCase.accessoryNotFound
        }
        
        services = foundAccessory.services
    }
    
    func findCharacteristics(accessoryID: UUID, homeID: UUID, serviceID: UUID) throws {
        guard let foundHome = homes.first(where: { $0.uniqueIdentifier == homeID }) else {
            throw UnexpectedErrorCase.homeNotFound
        }
        
        guard let foundAccessory = foundHome.accessories.first(where: { $0.uniqueIdentifier == accessoryID }) else {
            throw UnexpectedErrorCase.accessoryNotFound
        }
        
        guard let foundService = foundAccessory.services.first(where: { $0.uniqueIdentifier == serviceID }) else {
            throw UnexpectedErrorCase.serviceNotFound
        }
        
        characteristics = foundService.characteristics
    }
    
    func readCharacteristicsValues(serviceID: UUID) throws {
        guard let foundService = services.first(where: { $0.uniqueIdentifier == serviceID }) else {
            throw UnexpectedErrorCase.serviceNotFound
        }
        
        readingData = true
        
        for characteristic in foundService.characteristics {
            readCharacteristicData(characteristic: characteristic)
        }
    }
    
    func setCharacteristicValue(characteristic: HMCharacteristic, value: Any) {
        characteristic.writeValue(value) { _ in
            self.readCharacteristicData(characteristic: characteristic)
        }
    }
    
    private func readCharacteristicData(characteristic: HMCharacteristic) {
        readingData = true
        
        characteristic.readValue { _ in
            switch characteristic.localizedDescription {
            case "Power State":
                self.powerState = characteristic.value as? Bool
            case "Hue":
                self.hueValue = characteristic.value as? Int
            case "Brightness":
                self.brightnessValue = characteristic.value as? Int
            default:
                break
            }
            
            self.readingData = false
        }
    }
    
}
