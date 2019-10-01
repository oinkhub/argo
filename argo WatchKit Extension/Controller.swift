import WatchKit
import SwiftUI
import CoreLocation

final class Places: ObservableObject {
    @Published var session = Session()
}

final class Controller: WKHostingController<Main>, CLLocationManagerDelegate {
    private let user = User()
    private let places = Places()
    
    override var body: Main { Main(user: user, places: places) {
        var item = Session.Item()
        item.name = $0.isEmpty ? NSLocalizedString("Main.noName", comment: ""): $0
        self.places.session.items.append(item)
        self.places.session.save()
    } }
    
    override func didAppear() {
        (WKExtension.shared().delegate as! Delegate).manager.delegate = self
        Session.load { self.places.session = $0 }
    }
    
    func locationManager(_: CLLocationManager, didUpdateHeading: CLHeading) {
        guard didUpdateHeading.headingAccuracy >= 0, didUpdateHeading.trueHeading >= 0 else { return }
        user.heading = -(didUpdateHeading.trueHeading > 180 ? didUpdateHeading.trueHeading - 360 : didUpdateHeading.trueHeading)
    }
}

final class Delegate: NSObject, WKExtensionDelegate {
    fileprivate let manager = CLLocationManager()
    
    func applicationDidBecomeActive() {
        manager.startUpdatingHeading()
    }

    func applicationWillResignActive() {
        manager.stopUpdatingHeading()
    }
}
