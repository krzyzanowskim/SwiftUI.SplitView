import SwiftUI
import SplitView

struct ContentView: View {
    @State var orientation1: SplitViewOrientation = .horizontal
    @State var orientation2: SplitViewOrientation = .vertical
    @State var orientation3: SplitViewOrientation = .vertical

    var body: some View {
        SplitView(orientation: $orientation1) {
            SampleContent()
            SampleContent()
            SplitView(orientation: $orientation2) {
                SampleContent()
                SampleContent()
                SampleContent()
                SampleContent()
                SampleContent()
            }
            .onTapGesture {
                orientation2.toggle()
            }
            SampleContent()
            SampleContent()
            SampleContent()
            SplitView(orientation: $orientation3) {
                SampleContent()
                SampleContent()
                SampleContent()
                SampleContent()
                SampleContent()
            }
            .onTapGesture {
                orientation3.toggle()
            }
        }
        .onTapGesture {
            orientation1.toggle()
        }
    }
}

struct SampleContent: View {
    @State var color: Color = .Pastel.random(.oklab)

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(color)
                .onTapGesture {
                    color = .Pastel.random(.oklab)
                }

            HStack {
                Text("Lorem ipsum")
            }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
