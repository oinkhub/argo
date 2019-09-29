import SwiftUI

struct Main: View {
    @ObservedObject var user: User
    @ObservedObject var marks: Marks

    var body: some View {
        List {
            Add()
            Section {
                ForEach(marks.items, id: \.self) {
                    Mark(mark: $0)
                }
            }
        }.navigationBarTitle("Argo")
    }
}
private struct Add: View {
    var body: some View {
        HStack {
            Image(systemName: "plus.circle.fill").padding(.leading, 5)
            .foregroundColor(Color("halo"))
            
            Text("Add").padding(.leading, 2)
        }
    }
}

private struct Mark: View {
    var mark: Marks.Item

    var body: some View {
        Text("hello")
    }
}
