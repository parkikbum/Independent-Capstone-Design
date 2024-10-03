import SwiftUI
import Combine
import Vision


final class TestingViewModel: ObservableObject {
    @Published private var previewImage: UIImage = .init()
    @Published var drawingImage: UIImage = .init()
    @Published var midFallState: Bool = false
    @Published var angleFallState: Bool = false
    @Published var ratioFallState: Bool = false
    
    private var visionProcessor: VisionProcessor
    private var fallDetectionProcessor: FallDetectionProcessor
    var videoProcessor: VideoProcessor
    
    
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
    func getRatioAlgorithmResult(state: PerformState, result: Bool?) {
        if state == .done {
            guard let result else { return }
            ratioFallState = ratioFallState ? true : result
        }
    }
    
    func getMidYChangeAlgorithmResult(state: PerformState, result: Bool?) {
        if state == .done {
            guard let result else { return }
            midFallState = midFallState ? true : result
        }
    }
    
    func getAngleAlgorithmResult(state: PerformState, result: Bool?) {
        if state == .done {
            guard let result else { return }
            angleFallState = angleFallState ? true : result
        }
    }
}
