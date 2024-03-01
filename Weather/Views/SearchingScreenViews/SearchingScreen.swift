//
//  SearchingScreen.swift
//  Weather
//
//  Created by Tomas Sanni on 6/6/23.
//

import SwiftUI
import GooglePlaces

struct SearchingScreen: View {
    @State private var showGoogleSearchScreen: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var persistenceLocations: SavedLocationsPersistenceViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @EnvironmentObject var locationManager: CoreLocationViewModel
    @EnvironmentObject var appStateViewModel: AppStateViewModel
    
    //MARK: - Main View
    var body: some View {
        VStack {
            textFieldAndBackButton
            
            CustomDivider()
            
            VStack {
                CurrentLocationView(localWeather: weatherViewModel.localWeather)
                    .padding(.bottom)
                    .padding(.bottom)
                    .onTapGesture {
                        Task {
                            await appStateViewModel.getWeatherAndUpdateDictionaryFromLocation()
                            persistenceLocations.saveData()
                        }
                    }
                
                HStack {
                    Text("Saved locations")
                        .font(.headline)
                    Spacer()
                }
                
                CustomDivider()
                
                SavedLocationsView()
            }
            .padding()
        }
        .foregroundStyle(.white)
        .contentShape(Rectangle())
        .background(K.ColorsConstants.goodDarkTheme)
        .sheet(isPresented: $showGoogleSearchScreen) {
            PlacesViewControllerBridge { place in
                Task {
                    await appStateViewModel.getWeatherWithGoogleData(place: place, currentWeather: weatherViewModel.currentWeather)
                    persistenceLocations.saveData()
                }
                
            }
        }
    }
    
    //MARK: - Textfield and Back button
    var textFieldAndBackButton: some View {
        HStack {
            Button {
                appStateViewModel.toggleShowSearchScreen()
            } label: {
                Image(systemName: "arrow.left")
                    .contentShape(Rectangle())
                    .padding()
            }
            
            Text("Search for a location")
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    DispatchQueue.main.async {
                        showGoogleSearchScreen = true
                    }
                }
        }
    }
}


struct SearchingView_Previews: PreviewProvider {
    static var previews: some View {
        SearchingScreen()
            .environmentObject(WeatherViewModel.shared)
            .environmentObject(CoreLocationViewModel.shared)
            .environmentObject(AppStateViewModel.shared)
            .environmentObject(SavedLocationsPersistenceViewModel.shared)
    }
}
