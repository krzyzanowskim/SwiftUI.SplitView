# SplitView

Experimental SwiftUI.SplitView (Vertical/Horizontal) view.

Why? Because NSSplitView takes too much energy from whoever willing to make it work predictably.

https://user-images.githubusercontent.com/758033/180766261-ad9ce52f-cb9b-4112-bd9c-1df6cb777033.mp4

# Use

```
import SplitView

struct ContentView: View {

    var body: some View {
        SplitView(orientation: .constant(.horizontal)) {
            SampleContent()
            SampleContent()
            SplitView(orientation: .constant(.vertical)) {
                SampleContent()
                SampleContent()
                SampleContent()
            }
            SampleContent()
            SampleContent()
            SplitView(orientation: .constant(.vertical)) {
                SampleContent()
                SampleContent()
                SampleContent()
            }
        }
    }
    
}

private struct SampleContent: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.yellow)

            HStack {
                Text("Lorem ipsum")
            }
        }
    }
}
```

Work in progress 👷‍♂️
