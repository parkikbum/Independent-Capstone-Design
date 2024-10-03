import SwiftUI


struct TestingView: View {
    @ObservedObject private var viewModel = TestingViewModel(videoProcessor: .init(),
                                                             visionProcessor: .init(),
                                                             fallDetectionProcessor: .init())
    
    var body: some View {
        VStack {
            Image(uiImage: viewModel.drawingImage)
            
            HStack {
                Text("낙상 여부 : ")
                Text(viewModel.fallState ? "낙상" : "비낙상")
                    .font(.largeTitle)
                    .foregroundStyle(viewModel.fallState ? .red : .blue)
            }
        }
        .overlay {
        }
        .onAppear {
            viewModel.videoProcessor.startProcessing(videoName: "1")
        }
    }
}

#Preview {
    TestingView()
}
