import SwiftUI
import Combine
import Vision


final class TestingViewModel: ObservableObject {
    @Published private var previewImage: UIImage = .init()
    @Published var drawingImage: UIImage = .init()
    @Published var midFallState: Bool = false
    private var midFallValue: [Double] = []
    @Published var angleFallState: Bool = false
    private var angleFallValue: [Double] = []
    @Published var ratioFallState: Bool = false
    private var ratioFallValue: [Double] = []
    
    private var visionProcessor: VisionProcessor
    private var fallDetectionProcessor: FallDetectionProcessor
    var videoProcessor: VideoProcessor
    
    
    private var resultDatas = [ResultData]()
    
    
    init(videoProcessor: VideoProcessor,
         visionProcessor: VisionProcessor,
         fallDetectionProcessor: FallDetectionProcessor) {
        self.videoProcessor = videoProcessor
        self.visionProcessor = visionProcessor
        self.fallDetectionProcessor = fallDetectionProcessor
        
        videoProcessor.bufferDelegate = self
        visionProcessor.pointsDelegate = self
        fallDetectionProcessor.resultDelegate = self
    }
    
    
    func drawPoseOnImage(points: [VNHumanBodyPoseObservation.JointName: CGPoint]) {
        let renderer = UIGraphicsImageRenderer(size: previewImage.size)
        drawingImage = renderer.image { context in
            previewImage.draw(in: CGRect(origin: .zero, size: previewImage.size))
            for (_, point) in points {
                let circleRect = CGRect(
                    x: point.x * previewImage.size.width - 3,
                    y: point.y * previewImage.size.height - 3,
                    width: 6,
                    height: 6
                )
                context.cgContext.setFillColor(UIColor.red.cgColor)
                context.cgContext.fillEllipse(in: circleRect)
            }
        }
    }
    
    func resetAllFallState() {
        midFallState = false
        midFallValue.removeAll()
        angleFallState = false
        angleFallValue.removeAll()
        ratioFallState = false
        ratioFallValue.removeAll()
        fallDetectionProcessor.resetAllData()
    }
    
    func saveFallStateResult(videoIndex: Int) {
        let fileManager = FileManager.default
        
        let fileName = "\(videoIndex).csv"
        
        var documentURL = fileManager.urls(for: .documentDirectory,
                                           in: .userDomainMask).first!
        do {
            documentURL.appendPathComponent(fileName,
                                            conformingTo: .utf8PlainText)
            let fileData = makeFallStateCSVFile().data(using: .utf8)
            try fileData?.write(to: documentURL)
        } catch {
            print("write Error")
        }
    }
    
    func addResult(videoName: String) {
        resultDatas.append(.init(videoName: videoName,
                                 midFallState: midFallState,
                                 angleFallState: angleFallState,
                                 ratioFallState: ratioFallState))
    }
    
    private func makeFallStateCSVFile() -> String {
        let header = "videoName, midFallState, angleFallState, ratioFallState, totalState\n"
        let stateResultData = resultDatas.map { "\($0.videoName), \($0.midFallState), \($0.angleFallState), \($0.ratioFallState), \($0.midFallState && $0.angleFallState && $0.ratioFallState)"}
        
        let ratioValueResultData = ratioFallValue.map { "\($0),"}
        let ratioStringData = "\nratioValue," + ratioValueResultData.joined(separator: " ")
        
        let midValueResultData = midFallValue.map { "\($0),"}
        let midValueStringData = "\nmidValue," + midValueResultData.joined(separator: " ")
        
        let angleResultData = angleFallValue.map { "\($0),"}
        let angleStringData = "\nangleValue," + angleResultData.joined(separator: " ")
        
        let stringData = header + stateResultData.joined(separator: "\n") + ratioStringData + midValueStringData + angleStringData
        
        return stringData
    }
    
}

extension TestingViewModel: VideoProcessorDelegate {
    func getFrameBuffer(pixelBuffer: CVPixelBuffer, time: CMTime) {
        visionProcessor.poseEstimation(buffer: pixelBuffer)
        guard let image = UIImage(pixelBuffer: pixelBuffer) else { return }
        previewImage = image
    }
}

extension TestingViewModel: VisionProcessorDelegate {
    func getEstimatedPoint(points: [VNHumanBodyPoseObservation.JointName : CGPoint]) {
        drawPoseOnImage(points: points)
        fallDetectionProcessor.perform(positions: points)
    }
}

extension TestingViewModel: FallDetectionProcessorDelegate {
    func getRatioAlgorithmResult(state: PerformState, 
                                 result: Bool?,
                                 value: Double) {
        ratioFallValue.append(value)
        if state == .done {
            guard let result else { return }
            ratioFallState = ratioFallState ? true : result
        }
    }
    
    func getMidYChangeAlgorithmResult(state: PerformState, 
                                      result: Bool?,
                                      value: Double) {
        midFallValue.append(value)
        if state == .done {
            guard let result else { return }
            midFallState = midFallState ? true : result
        }
    }
    
    func getAngleAlgorithmResult(state: PerformState, 
                                 result: Bool?,
                                 value: Double) {
        angleFallValue.append(value)
        if state == .done {
            guard let result else { return }
            angleFallState = angleFallState ? true : result
        }
    }
}
