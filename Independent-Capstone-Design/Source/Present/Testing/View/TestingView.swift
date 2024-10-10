import SwiftUI


struct TestingView: View {
    @ObservedObject private var viewModel = TestingViewModel(videoProcessor: .init(),
                                                             visionProcessor: .init(),
                                                             fallDetectionProcessor: .init())
    @State var index: Int = 1
    
    var body: some View {
        VStack {
            Image(uiImage: viewModel.drawingImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
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
                
                HStack {
                    Text("신체 비율 낙상 여부 : ")
                    Text(viewModel.ratioFallState ? "낙상" : "비낙상")
                        .font(.largeTitle)
                        .foregroundStyle(viewModel.ratioFallState ? .red : .blue)
                }
                
                HStack {
                    Text("종합 낙상 여부 : ")
                    Text((viewModel.midFallState && viewModel.angleFallState && viewModel.ratioFallState) ? "낙상" : "비낙상")
                        .font(.largeTitle)
                        .foregroundStyle((viewModel.midFallState && viewModel.angleFallState && viewModel.ratioFallState) ? .red : .blue)
                }
            }
        }
        .overlay {
        }
        .onAppear {
            viewModel.videoProcessor.startProcessing(videoName: makeAdlFileName())
            viewModel.videoProcessor.videoPlayEndCompletion = {
                viewModel.addResult(videoName: makeAdlFileName())
                viewModel.saveFallStateResult(videoIndex: index)
                index += 1
                viewModel.resetAllFallState()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.videoProcessor.startProcessing(videoName: makeAdlFileName())
                }
            }
        }
    }
    
    func makeAdlFileName() -> String {
        if index < 10 {
            return "output-fall-0\(index)"
        } else {
            return "output-fall-\(index)"
        }
    }
    
}

#Preview {
    TestingView()
}
