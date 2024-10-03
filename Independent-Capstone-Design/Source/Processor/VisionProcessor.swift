import Vision
import VisionKit

final class VisionProcessor {
    weak var pointsDelegate: VisionProcessorDelegate?
    private var request: VNDetectHumanBodyPoseRequest?
    private let jointsType: [VNHumanBodyPoseObservation.JointName] = [
        .nose,
        .leftShoulder, .rightShoulder,
        .leftElbow, .leftElbow, .leftWrist,
        .rightElbow, .rightElbow, .rightWrist,
        .leftHip, .rightHip,
        .leftKnee, .leftAnkle,
        .rightKnee, .rightAnkle
    ]
    
    init() {
        setRequestHandler()
    }
    
    private func setRequestHandler() {
        request = VNDetectHumanBodyPoseRequest(completionHandler: { [weak self] request, error in
            guard let self else { return }
            guard let results = request.results as? [VNHumanBodyPoseObservation] else { return }
            self.handleObservation(observations: results)
        })
    }
    
    func poseEstimation(buffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer)
        do {
            if let request {
                try handler.perform([request])
            }
        } catch {
            print("포즈 추정 실패 . . . . . . 흑흑")
        }
    }
    
    func handleObservation(observations: [VNHumanBodyPoseObservation]) {
        guard let observation = observations.first else { return }
        
        var jointPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        for joint in jointsType {
            if let point = try? observation.recognizedPoint(joint) {
                jointPoints[joint] = CGPoint(x: point.location.x,
                                             y: 1 - point.location.y)
            }
        }
        
        pointsDelegate?.getEstimatedPoint(points: jointPoints)
    }
}
