import SwiftUI

public extension Color {

    enum Pastel {
        case `default`
        case oklab

        var color: Color {
            switch self {
            case .default:
                return Color(
                    hue: .random(in: 0...1),
                    saturation: .random(in: 0.25...0.95),
                    brightness: .random(in: 0.85...0.95)
                )
            case .oklab:
                let chroma: Double = 0.07
                let hue: Angle = .init(degrees: .random(in: 0...360))
                return Color(
                    lightness: 0.84,
                    a: chroma * cos(hue.radians),
                    b: chroma * sin(hue.radians)
                )
            }
        }

        static func random(_ mode: Pastel = .default) -> Color {
            mode.color
        }

    }


    /// A `Color` defined in the OKLab color space.
    ///
    /// - Parameters:
    ///   - l: Perceived lightness.
    ///   - a: How green/red the color is.
    ///   - b: How blue/yellow the color is.
    private init(lightness l: Double, a: Double, b: Double, opacity: Double = 1) {
        let l_ = l + 0.3963377774 * a + 0.2158037573 * b
        let m_ = l - 0.1055613458 * a - 0.0638541728 * b
        let s_ = l - 0.0894841775 * a - 1.2914855480 * b

        let l = l_ * l_ * l_
        let m = m_ * m_ * m_
        let s = s_ * s_ * s_

        let r = +4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
        let g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
        let b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s

        self.init(.sRGBLinear, red: r, green: g, blue: b, opacity: opacity)
    }
}
