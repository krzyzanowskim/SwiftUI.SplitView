//
//  ContentView.swift
//  SplitLayout
//
//  Created by Marcin Krzyzanowski on 23/07/2022.
//

import SwiftUI
import SequenceBuilder

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

private struct DragState: Equatable {
    var location: CGPoint = .zero
    var distance: CGPoint = .zero
    static let zero = DragState()
}

public struct SplitView<Content: Collection>: View  where Content.Element: View{

    private let content: Content
    @Binding private var orientation: SplitViewOrientation
    @Binding private var separatorSize: Double

    @GestureState private var dragState: DragState = .zero
    @State private var offsets: [Int: CGPoint] = [:]

    public init(
        orientation: Binding<SplitViewOrientation> = .constant(.horizontal),
        separatorSize: Binding<Double> = .constant(10),
        @SequenceBuilder content: () -> Content)
    {
        self._orientation = orientation
        self._separatorSize = separatorSize
        self.content = content()
    }

    public init(
        orientation: SplitViewOrientation = .horizontal,
        separatorSize: Binding<Double> = .constant(10),
        @SequenceBuilder content: () -> Content
    ) {
        self._orientation = .constant(orientation)
        self._separatorSize = separatorSize
        self.content = content()
    }

    public var body: some View {
        switch orientation {
        case .horizontal:
            HStack(spacing: 0) {
                contentView
            }
        case .vertical:
            VStack(spacing: 0) {
                contentView
            }
        }
    }

    private var contentView: some View {
        ForEach(sequence: content) { (index, content) in
            GeometryReader { geometry in
                if index == 0 { // first
                    switch orientation {
                    case .horizontal:
                        let newWidth = geometry.size.width - dragState.distance.x
                        if newWidth.isZero || newWidth < 0 {
                            EmptyView()
                        } else {
                            content
                                .frame(width: newWidth)
                        }
                    case .vertical:
                        let newHeight = geometry.size.height - dragState.distance.y
                        if newHeight.isZero || newHeight < 0 {
                            EmptyView()
                        } else {
                            content
                                .frame(height: newHeight)
                        }
                    }
                } else if index == self.content.count - 1 { // last
                    switch orientation {
                    case .horizontal:
                        let newWidth = geometry.size.width + dragState.distance.x
                        if newWidth.isZero || newWidth < 0 {
                            EmptyView()
                        } else {
                            content
                                .frame(width: newWidth)
                                .offset(x: -dragState.distance.x, y: 0)
                        }
                    case .vertical:
                        let newHeight = geometry.size.height + dragState.distance.y
                        if newHeight.isZero || newHeight < 0 {
                            EmptyView()
                        } else {
                            content
                                .frame(height: newHeight)
                                .offset(x: 0, y: -dragState.distance.y)
                        }
                    }
                } else { // middle
                    switch orientation {
                    case .horizontal:
                        content
                            .offset(x: -dragState.distance.x, y: 0)
                    case .vertical:
                        content
                            .offset(x: 0, y: -dragState.distance.y)
                    }
                }
            }

            if index != self.content.count - 1 { // not last
                Group {
                    switch orientation {
                    case .horizontal:
                        SplitDivider(orientation: $orientation)
                            .size(separatorSize)
                            .offset(x: -dragState.distance.x, y: 0)
                    case .vertical:
                        SplitDivider(orientation: $orientation)
                            .size(separatorSize)
                            .offset(x: 0, y: -dragState.distance.y)
                    }
                }
                .simultaneousGesture(
                    DragGesture()
                        .updating($dragState) { value, state, _ in
                            state = DragState(
                                location: value.location,
                                distance: CGPoint(
                                    x: value.startLocation.x - value.location.x,
                                    y: value.startLocation.y - value.location.y
                                )
                            )
                        }
                        .onEnded { value in
                            //offsets[index] = value.distance
                        }
                )
            }
        }
    }

    private struct SplitDivider: View {
        @Binding var orientation: SplitViewOrientation

        var body: some View {
            Rectangle()
                .foregroundColor(Color(NSColor.separatorColor))
        }

        func size(_ value: Double) -> some View {
            switch orientation {
            case .horizontal:
                return self.frame(width: value)
            case .vertical:
                return self.frame(height: value)
            }
        }
    }
}


struct ContentView: View {
    @State var orientation1: SplitViewOrientation = .horizontal
    @State var orientation2: SplitViewOrientation = .vertical

    var body: some View {
//        VSplitView {
        SplitView(orientation: $orientation1) {
            EditorContent()
            EditorContent()
            SplitView(orientation: $orientation2) {
                EditorContent()
                EditorContent()
            }
            .onTapGesture {
                orientation2.toggle()
            }
        }
        .onTapGesture {
            orientation1.toggle()
        }
    }
}

struct EditorContent: View {
    @State var color: Color = .Pastel.random(.oklab)

    var body: some View {
        Rectangle()
            .foregroundColor(color)
            .onTapGesture {
                color = .Pastel.random(.oklab)
            }
    }
}


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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
