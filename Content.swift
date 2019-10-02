import SwiftUI

struct Content: View {
    @ObservedObject var places: Places
    @State private var creating = false
    var add: (String) -> Void
    var delete: (IndexSet) -> Void

    var body: some View {
        List {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .padding(.leading, 5)
                    .foregroundColor(Color("halo"))
                
                Text(.init("Main.add"))
                    .padding(.leading, 2)
            }
            .onTapGesture {
                self.creating = true
            }
            
            Section(header: Text(.init("Main.header"))) {
                ForEach(places.session.items, id: \.self) { item in
                    NavigationLink(destination: Navigation(places: self.places, item: item)) {
                        Text(item.name)
                    }
                }.onDelete(perform: delete)
            }
        }
        .navigationBarTitle("Main.title")
        .sheet(isPresented: $creating) {
            Create {
                self.add($0)
                self.creating = false
            }
        }
        .alert(isPresented: self.$places.error) {
            Alert(title: Text("Main.alert"), message: Text(self.places.message), dismissButton:
                .default(Text("Main.continue")) {
                    self.places.error = false
                }
            )
        }
    }
}

private struct Navigation: View {
    @ObservedObject var places: Places
    var item: Session.Item
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                ZStack {
                    ForEach((2...142), id: \.self) { p in
                        Path {
                            let side = min(geo.size.width, geo.size.height) * 0.47
                            $0.move(to: .init(x: geo.size.width / 2, y: (geo.size.height / 2) - side - 2))
                            $0.addLine(to: .init(x: geo.size.width / 2, y: (geo.size.height / 2) - side + 2))
                        }
                        .stroke(Color("halo"), style: .init(lineWidth: 1, lineCap: .round)).rotationEffect(.degrees(Double(p) * 2.5))
                    }
                    
                    Path {
                        let side = min(geo.size.width, geo.size.height) * 0.47
                        $0.addArc(center: .init(x: geo.size.width / 2, y: (geo.size.height / 2) - side), radius: 4, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
                    }
                    .stroke(Color("halo"), style: .init(lineWidth: 1, lineCap: .round))

                    Path {
                        let x = CGFloat(self.item.longitude - self.places.coordinate.1)
                        let y = CGFloat(self.places.coordinate.0 - self.item.latitude)
                        let side = min(geo.size.width, geo.size.height) * 0.27
                        let rate = max(abs(x), abs(y)) / side
                        $0.move(to: .init(x: geo.size.width / 2, y: geo.size.height / 2))
                        $0.addLine(to: .init(x: (geo.size.width / 2) + (x / rate), y: (geo.size.height / 2) + (y / rate)))
                    }
                    .stroke(Color(white: 0.1), style: .init(lineWidth: 12, lineCap: .round))
                    
                    Path {
                        let x = CGFloat(self.item.longitude - self.places.coordinate.1)
                        let y = CGFloat(self.places.coordinate.0 - self.item.latitude)
                        let side = min(geo.size.width, geo.size.height) * 0.27
                        let rate = max(abs(x), abs(y)) / side
                        $0.addArc(center: .init(x: (geo.size.width / 2) + (x / rate), y: (geo.size.height / 2) + (y / rate)), radius: 8, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
                    }
                    .fill(Color("halo"))
                }
            }
            .rotationEffect(.degrees(places.heading))
            .navigationBarTitle(item.name)
            
            Image("heading")
        }
    }
}
