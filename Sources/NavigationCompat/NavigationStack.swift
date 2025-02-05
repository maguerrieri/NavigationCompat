import Foundation
import SwiftUI

import SwiftUIBackports

class PathHolder<Data>: ObservableObject {
    @Published var path: [Data]
    
    init(path: [Data] = []) {
        self.path = path
    }
}

@available(iOS, deprecated: 16, message: "Use SwiftUI's Navigation API beyond iOS 15")
@available(macOS, deprecated: 13, message: "Use SwiftUI's Navigation API beyond macOS 12")
@available(tvOS, deprecated: 16, message: "Use SwiftUI's Navigation API beyond tvOS 15")
public struct NavigationStackCompat<Root: View, Data: Hashable>: View {
    @Binding var path: [Data]
    @Backport.StateObject var pathHolder: PathHolder<Data>

    var root: Root

    var erasedPath: Binding<[AnyHashable]> {
        Binding(
            get: { path.map(AnyHashable.init) },
            set: { newValue in
                path = newValue.map { anyHashable in
                    guard let data = anyHashable.base as? Data else {
                        fatalError("Cannot add \(type(of: anyHashable.base)) to stack of \(Data.self)")
                    }
                    return data
                }
            }
        )
    }

    @Backport.StateObject var destinationBuilder = DestinationBuilderHolder()
    
    public var body: some View {
#if os(macOS)
        VStack {
            if self.path.isEmpty {
                self.root
            } else if let data = self.path.last {
                self.destinationBuilder.build(data)
                    .transition(.move(edge: .trailing))
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.path.removeLast()
                    }
                } label: {
                    Label("back", systemImage: "chevron.left")
                }
                .disabled(self.path.isEmpty)
            }
        }
        .environmentObject(NavigationPathHolder(self.erasedPath))
        .environmentObject(self.destinationBuilder)
#else
        NavigationView {
            Router(rootView: self.root, screens: self.$path)
                .environmentObject(NavigationPathHolder(self.erasedPath))
                .environmentObject(self.destinationBuilder)
        }
        .navigationViewStyle(.stack)
#endif
    }
    
    init(path: Binding<[Data]>, pathHolder: PathHolder<Data>, @ViewBuilder root: () -> Root) {
        self._path = path
        self._pathHolder = .init(wrappedValue: pathHolder)

        self.root = root()
    }

    public init(path: Binding<[Data]>, @ViewBuilder root: () -> Root) {
        self.init(path: path, pathHolder: .init(), root: root)
    }
}

public extension NavigationStackCompat where Data == AnyHashable {
    init(@ViewBuilder root: () -> Root) {
        let pathHolder = PathHolder<Data>()
        let path = Binding(
            get: { pathHolder.path },
            set: { pathHolder.path = $0 }
        )
        self.init(path: path, pathHolder: pathHolder, root: root)
    }
}

public extension NavigationStackCompat where Data == AnyHashable {
    init(path: Binding<NavigationPathCompat>, @ViewBuilder root: () -> Root) {
        let path = Binding(
            get: { path.wrappedValue.elements },
            set: { path.wrappedValue.elements = $0 }
        )
        self.init(path: path, root: root)
    }
}
