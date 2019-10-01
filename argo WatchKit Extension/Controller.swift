import WatchKit
import SwiftUI
import CoreLocation

final class Controller: WKHostingController<Main>, CLLocationManagerDelegate {
    private let user = User()
    private let marks = Marks()
    
    override var body: Main { Main(user: user, marks: marks) { _ in
        self.marks.items.append(.init())
    } }
    
    override func didAppear() {
        (WKExtension.shared().delegate as! Delegate).manager.delegate = self
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
