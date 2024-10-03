import SwiftUI


struct TestingView: View {
    @ObservedObject private var viewModel = TestingViewModel(videoProcessor: .init(),
                                                             visionProcessor: .init(),
                                                             fallDetectionProcessor: .init())
    
    var body: some View {
        VStack {
            Image(uiImage: viewModel.drawingImage)
            
            VStack {
                HStack {
                    Text("중심 하강 낙상 여부 : ")
                    Text(viewModel.midFallState ? "낙상" : "비낙상")
                        .font(.largeTitle)
                        .foregroundStyle(viewModel.midFallState ? .red : .blue)
                }
                
                HStack {
                    Text("지면 각도 낙상 여부 : ")
                    Text(viewModel.angleFallState ? "낙상" : "비낙상")
                        .font(.largeTitle)
                        .foregroundStyle(viewModel.angleFallState ? .red : .blue)
                }
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
