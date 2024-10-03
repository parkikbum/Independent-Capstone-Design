import Vision

protocol VisionProcessorDelegate: AnyObject {
    func getEstimatedPoint(points: [VNHumanBodyPoseObservation.JointName: CGPoint])
}
