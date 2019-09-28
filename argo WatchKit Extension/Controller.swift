import WatchKit
import Foundation
import SwiftUI
import CoreLocation

final private class User: ObservableObject {
    @Published var heading = Double()
}

struct Content: View {
    @ObservedObject fileprivate var user: User
    
    var body: some View {
        ZStack {
            Image("heading")
            
            GeometryReader { geo in
                ZStack {
                    ForEach((0...144), id: \.self) { p in
                        Path {
                            let side = min(geo.size.width, geo.size.height) * 0.485
                            $0.move(to: .init(x: geo.size.width / 2, y: (geo.size.height / 2) - side - 2))
                            $0.addLine(to: .init(x: geo.size.width / 2, y: (geo.size.height / 2) - side + (p == 0 ? 10 : 2)))
                        }.stroke(Color("halo"), style: .init(lineWidth: p == 0 ? 3 : 1, lineCap: .round)).rotationEffect(.degrees(Double(p) * 2.5))
                    }
                }
            }.rotationEffect(.degrees(self.user.heading)).animation(.easeOut)
        }
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

final class Controller: WKHostingController<Content>, CLLocationManagerDelegate {
    private let user = User()
    override var body: Content { Content(user: user) }
    
    override func didAppear() {
        (WKExtension.shared().delegate as! Delegate).manager.delegate = self
    }
    
    func locationManager(_: CLLocationManager, didUpdateHeading: CLHeading) {
        guard didUpdateHeading.headingAccuracy >= 0, didUpdateHeading.trueHeading >= 0 else { return }
        user.heading = -(didUpdateHeading.trueHeading > 180 ? didUpdateHeading.trueHeading - 360 : didUpdateHeading.trueHeading)
    }
}
