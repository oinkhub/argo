import Foundation

final class Marks: ObservableObject {
    struct Item: Identifiable, Hashable {
        var id = UUID()
        var name = ""
    }
    
    @Published var items = [Item]()
}
