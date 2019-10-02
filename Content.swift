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
            Image("heading")
            
            GeometryReader { geo in
                ZStack {
                    ForEach((0...144), id: \.self) { p in
                        Path {
                            let side = min(geo.size.width, geo.size.height) * 0.485
                            $0.move(to: .init(x: geo.size.width / 2, y: (geo.size.height / 2) - side - 2))
                            $0.addLine(to: .init(x: geo.size.width / 2, y: (geo.size.height / 2) - side + (p == 0 ? 10 : 4)))
                        }.stroke(Color("halo"), style: .init(lineWidth: p == 0 ? 1.5 : 1, lineCap: .round)).rotationEffect(.degrees(Double(p) * 2.5))
                    }
                }
            }
            .rotationEffect(.degrees(places.heading))
            .navigationBarTitle(item.name)
        }
    }
}
