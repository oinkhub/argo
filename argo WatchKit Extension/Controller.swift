import WatchKit
import Foundation
import SwiftUI
import CoreLocation

final class User: ObservableObject {
    @Published var heading = Double()
}

struct Content: View {
    @ObservedObject var user: User
    
    var body: some View { Image("heading").rotationEffect(.radians(user.heading)) }
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

final class Controller: WKHostingController<Content>, CLLocationManagerDelegate {
    @ObservedObject var user = User()
    override var body: Content { Content(user: user) }
    
    override func didAppear() {
        (WKExtension.shared().delegate as! Delegate).manager.delegate = self
    }
    
    func locationManager(_: CLLocationManager, didUpdateHeading: CLHeading) {
        guard didUpdateHeading.headingAccuracy >= 0, didUpdateHeading.trueHeading >= 0 else { return }
        user.heading = didUpdateHeading.trueHeading * .pi / 180
    }
}
