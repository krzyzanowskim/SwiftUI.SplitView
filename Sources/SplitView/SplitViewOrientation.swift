import Foundation

public enum SplitViewOrientation {
    case vertical
    case horizontal

    public mutating func toggle() {
        switch self {
        case .vertical:
            self = .horizontal
        case .horizontal:
            self = .vertical
        }
    }
}
