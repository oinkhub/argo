import SwiftUI

struct Navigation: View {
    @ObservedObject var user: User
    let mark: Session.Item
    
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
