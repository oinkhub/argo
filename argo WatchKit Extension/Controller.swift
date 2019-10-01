import WatchKit
import SwiftUI
import CoreLocation

final class Places: ObservableObject {
    @Published var session = Session()
    @Published var heading = Double()
    @Published var error = false
    var message = ""
}

final class Controller: WKHostingController<Main>, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let places = Places()
    
    override var body: Main {
        .init(places: places) {
            var item = Session.Item()
            item.name = $0.isEmpty ? NSLocalizedString("Main.noName", comment: ""): $0
            self.places.session.items.append(item)
            self.places.session.save()
    } }
    
    override func didAppear() {
        super.didAppear()
        Session.load { self.places.session = $0 }
    }
    
    override func willActivate() {
        super.willActivate()
        manager.delegate = self
        manager.startUpdatingHeading()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        manager.stopUpdatingHeading()
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_: CLLocationManager, didFailWithError: Error) {
        DispatchQueue.main.async {
            self.places.message = didFailWithError.localizedDescription
            self.places.error = true
        }
    }
    
    func locationManager(_: CLLocationManager, didUpdateHeading: CLHeading) {
        guard didUpdateHeading.headingAccuracy >= 0, didUpdateHeading.trueHeading >= 0 else { return }
        places.heading = -(didUpdateHeading.trueHeading > 180 ? didUpdateHeading.trueHeading - 360 : didUpdateHeading.trueHeading)
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) {
        print(didUpdateLocations.first)
    }
    
    func locationManager(_: CLLocationManager, didChangeAuthorization: CLAuthorizationStatus) {
        switch didChangeAuthorization {
        case .denied:
            DispatchQueue.main.async {
                self.places.message = NSLocalizedString("Error.noAuth", comment: "")
                self.places.error = true
            }
        case .notDetermined: manager.requestWhenInUseAuthorization()
        default:
            manager.startUpdatingLocation()
        }
    }
}
