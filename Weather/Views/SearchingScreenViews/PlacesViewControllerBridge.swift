//
//  PlacesViewControllerBridge.swift
//  Tenki Weather
//
//  Created by Tomas Sanni on 8/17/23.
//

//import SwiftUI
//import GooglePlaces

//struct PlacesViewControllerBridge: UIViewControllerRepresentable {
//    
//    var onPlaceSelected: (GMSPlace) -> ()
//    //var selectedPlaceByFilter: GMSPlace
//    
//    func makeUIViewController(context: UIViewControllerRepresentableContext<PlacesViewControllerBridge>) -> GMSAutocompleteViewController {
//        let uiViewControllerPlaces = GMSAutocompleteViewController()
//        uiViewControllerPlaces.delegate = context.coordinator
//        
//        // Specify the place data types to return.
//        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.name.rawValue) |
//                                                                   UInt(GMSPlaceField.placeID.rawValue) |
//                                                                   UInt(GMSPlaceField.coordinate.rawValue)
//                                                                  )
//        )
//        uiViewControllerPlaces.placeFields = fields
//        
//        
//        // Specify a filter.
//        let filter = GMSAutocompleteFilter()
//        filter.types = ["locality", "sublocality", "postal_code", "administrative_area_level_1", "administrative_area_level_2"]
//        uiViewControllerPlaces.autocompleteFilter = filter
//        
//        return uiViewControllerPlaces
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        
//    }
//    
//    func makeCoordinator() -> PlacesViewAutoCompleteCoordinator {
//        return PlacesViewAutoCompleteCoordinator(placesViewControllerBridge: self)
//    }
//    
//    final class PlacesViewAutoCompleteCoordinator: NSObject, GMSAutocompleteViewControllerDelegate {
//        var placesViewControllerBridge: PlacesViewControllerBridge
//        
//        init(placesViewControllerBridge: PlacesViewControllerBridge) {
//            self.placesViewControllerBridge = placesViewControllerBridge
//        }
//        
//        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace)
//        {
//            viewController.dismiss(animated: true)
//            self.placesViewControllerBridge.onPlaceSelected(place)
//        }
//        
//        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error)
//        {
//            print("Error in : ", #function, error)
//        }
//        
//        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
//            viewController.dismiss(animated: true)
//        }
//        
////        func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
////            UIApplication.shared.isNetworkActivityIndicatorVisible = true
////        }
////        
////        func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
////            UIApplication.shared.isNetworkActivityIndicatorVisible = false
////        }
//        
//        func getCoordinatesFromGooglePlaces(coordinates: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
//            return coordinates
//        }
//        
//        
//     }
//        
//    }
