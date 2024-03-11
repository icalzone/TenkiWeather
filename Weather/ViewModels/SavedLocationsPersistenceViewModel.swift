//
//  SavedLocationsPersistenceViewModel.swift
//  Weather
//
//  Created by Tomas Sanni on 6/19/23.
//

//TODO: Cannot update a saved location name because I assume @Published var savedLocations is not ordered correctly

import Foundation
import CoreData

class SavedLocationsPersistenceViewModel: ObservableObject {
    static let shared = SavedLocationsPersistenceViewModel()

    let container: NSPersistentContainer
    let weatherManager = WeatherManager.shared
    
    @Published var savedLocations: [LocationEntity] = []
    
    private init() {
        
        ValueTransformer.setValueTransformer(UnitTemperatureTransformer(), forName: NSValueTransformerName("UnitTemperatureTransformer"))
        
        container = NSPersistentContainer(name: "SavedLocations")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("ERROR LOADING CORE DATA \(error)")
                return
            }
        }
        fetchLocations()
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    func fetchLocations() {        
        let request = NSFetchRequest<LocationEntity>(entityName: "LocationEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "timeAdded", ascending: false)]
        Task {
            do {
                try await fetchWeatherPlacesWithTaskGroup()
                try await MainActor.run {
                    savedLocations = try container.viewContext.fetch(request)
                }
            } catch let error{
                print("Error fetching. \(error)")
            }
        }
    }
    
    func addLocation(locationDictionary: [String: Any])  {

        guard let time = locationDictionary[K.LocationDictionaryKeysConstants.timezone] as? Int else {
            print("COULD NOT CONVERT")
            return
        }
        
        let newLocation = LocationEntity(context: container.viewContext)
        
        newLocation.name = locationDictionary[K.LocationDictionaryKeysConstants.name] as? String
        newLocation.latitude = locationDictionary[K.LocationDictionaryKeysConstants.latitude] as? Double ?? 0
        newLocation.longitude = locationDictionary[K.LocationDictionaryKeysConstants.longitude] as? Double ?? 0
        newLocation.timeAdded = Date.now
        newLocation.timezone = Double(time)
        newLocation.temperature = locationDictionary[K.LocationDictionaryKeysConstants.temperature] as? String
        newLocation.currentDate = locationDictionary[K.LocationDictionaryKeysConstants.date] as? String
        newLocation.sfSymbol = locationDictionary[K.LocationDictionaryKeysConstants.symbol] as? String
        newLocation.weatherCondition = locationDictionary[K.LocationDictionaryKeysConstants.weatherCondition] as? String
        newLocation.unitTemperature = locationDictionary[K.LocationDictionaryKeysConstants.unitTemperature] as? UnitTemperature 
        
        Task {
            try await fetchWeatherPlacesWithTaskGroup()
            saveData()
        }
        
    }
    
    
    func updatePlaceName(entity: LocationEntity, newName: String) {
        if newName == "" {
            return
        }
        let currentName = entity.name ?? ""
        let newName = newName
        entity.name = newName
        saveData()
//        entity.name = newName
//        saveData()
    }
    
//    func updatePlace(entity: LocationEntity) {
//        let currentName = entity.name ?? ""
//        let newName = currentName + "!"
//        entity.name = newName
//        saveData()
//    }
    
    func deletePlace(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let entity = savedLocations[index]
        container.viewContext.delete(entity)
        saveData()
    }
    
    func deleteLocationFromContextMenu(entity: LocationEntity) {
        container.viewContext.delete(entity)
        saveData()
    }
    
    func saveData() {
        do {
            Task {
                try await fetchWeatherPlacesWithTaskGroup()
                fetchLocations()
            }
            
            try container.viewContext.save()

        } catch let error {
            print("Error saving. \(error)")
        }
    }
    
    
    func fetchWeatherPlacesWithTaskGroup() async throws   {
        
        return try await withThrowingTaskGroup(of: LocationEntity?.self) { group in
            var weather: [LocationEntity] = []

            for location in savedLocations {
                group.addTask {
                    try? await self.fetchCurrentWeather(entity: location)
                }
            }

            // Special For Loop. This For Loop waits for each task to come back
            // If a task never comes back, we would wait forever or until it fails
            for try await currentData in group {
                if let data = currentData {
                    weather.append(data)
                }
            }
        }
    }
    
    private func fetchCurrentWeather(entity: LocationEntity) async throws -> LocationEntity {
        
        let weather = try await weatherManager.getWeatherFromWeatherKit(latitude: entity.latitude, longitude: entity.longitude, timezone: Int(entity.timezone))

        if let currentWeather = weather {
            let todaysWeather = await weatherManager.getTodayWeather(
                current: currentWeather.currentWeather,
                dailyWeather: currentWeather.dailyForecast,
                hourlyWeather: currentWeather.hourlyForecast,
                timezoneOffset: Int(entity.timezone)
            )
            
            let possibleWeatherAlerts = await weatherManager.getWeatherAlert(optionalWeatherAlert: currentWeather.weatherAlerts)
          
            entity.currentDate = todaysWeather.readableDate
            entity.temperature = todaysWeather.currentTemperature
            entity.sfSymbol = todaysWeather.symbolName
            entity.weatherCondition = todaysWeather.weatherDescription.description
            entity.unitTemperature = Helper.getUnitTemperature()
            
            if possibleWeatherAlerts != nil {
                entity.weatherAlert = true
            } else {
                entity.weatherAlert = false
            }
            
            return entity
        } else {
            throw URLError(.badURL)
        }
    }
}
