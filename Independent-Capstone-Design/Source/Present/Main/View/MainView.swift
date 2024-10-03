import SwiftUI

struct MainView: View {
    @State private var isPresentedTestingView: Bool = false
    
    var body: some View {
        VStack {
            Button(action: {
                isPresentedTestingView = true
            },
                   label: {
                Text("테스트 진행")
            })
            .fullScreenCover(isPresented: $isPresentedTestingView,
                             content: {
                TestingView()
            })
        }
    }
}

#Preview {
    MainView()
}
