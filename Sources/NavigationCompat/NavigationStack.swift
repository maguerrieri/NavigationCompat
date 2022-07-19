import Foundation
import SwiftUI

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
  @ObservedObject var pathHolder: PathHolder<Data>

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

  @StateObject var destinationBuilder = DestinationBuilderHolder()

  public var body: some View {
    NavigationView {
      Router(rootView: root, screens: $path)
        .environmentObject(NavigationPathHolder(erasedPath))
        .environmentObject(destinationBuilder)
    }.navigationViewStyle(supportedNavigationViewStyle)
  }

  init(path: Binding<[Data]>, pathHolder: PathHolder<Data>, @ViewBuilder root: () -> Root) {
    _path = path
    self.root = root()
    self.pathHolder = pathHolder
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

private var supportedNavigationViewStyle: some NavigationViewStyle {
  #if os(macOS)
    .automatic
  #else
    .stack
  #endif
}
