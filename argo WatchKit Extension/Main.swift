import SwiftUI

struct Main: View {
    @ObservedObject var user: User
    @ObservedObject var places: Places
    @State private var creating = false
    var add: (String) -> Void

    var body: some View {
        List {
            Add()
                .onTapGesture {
                self.creating = true
            }
            Section(header: Text(.init("Main.header"))) {
                ForEach(places.session.items.reversed(), id: \.self) { item in
                    NavigationLink(destination: Navigation(user: self.user, mark: item)) {
                        Mark(mark: item)
                    }
                }
            }
        }
        .navigationBarTitle("Main.title")
        .sheet(isPresented: $creating) {
            Create {
                self.add($0)
                self.creating = false
            }
        }
    }
}
private struct Add: View {
    var body: some View {
        HStack {
            Image(systemName: "plus.circle.fill").padding(.leading, 5)
            .foregroundColor(Color("halo"))
            
            Text(.init("Main.add")).padding(.leading, 2)
        }
    }
}

private struct Mark: View {
    var mark: Session.Item

    var body: some View {
        Text(mark.name)
    }
}
