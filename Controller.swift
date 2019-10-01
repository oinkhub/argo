import WatchKit
import SwiftUI
import CoreLocation

final class Places: ObservableObject {
    @Published var session = Session()
    @Published var heading = Double()
    @Published var error = false
    var message = ""
}

final class Controller: WKHostingController<Content> {
    fileprivate let places = Places()
    
    override var body: Content {
        Content(places: places) {
            var item = Session.Item()
            item.name = $0.isEmpty ? NSLocalizedString("Main.noName", comment: ""): $0
            self.places.session.items.append(item)
            self.places.session.save()
    } }
}

final class Delegate: NSObject, WKExtensionDelegate, CLLocationManagerDelegate {
    fileprivate let manager = CLLocationManager()
    private var places: Places { (WKExtension.shared().rootInterfaceController as! Controller).places }
    
    func applicationDidFinishLaunching() {
        Session.load { self.places.session = $0 }
    }
    
    func applicationDidBecomeActive() {
        manager.delegate = self
        manager.startUpdatingHeading()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func applicationWillResignActive() {
        manager.stopUpdatingHeading()
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_: CLLocationManager, didUpdateHeading: CLHeading) {
        guard didUpdateHeading.headingAccuracy >= 0, didUpdateHeading.trueHeading >= 0 else { return }
        places.heading = -(didUpdateHeading.trueHeading > 180 ? didUpdateHeading.trueHeading - 360 : didUpdateHeading.trueHeading)
    }
        
    func locationManager(_: CLLocationManager, didUpdateLocations: [CLLocation]) {
//        print(didUpdateLocations.first)
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
