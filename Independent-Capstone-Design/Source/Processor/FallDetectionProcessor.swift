import Foundation
import Vision

final class FallDetectionProcessor {
    weak var resultDelegate: FallDetectionProcessorDelegate?
    
    private var midYValues: [CGFloat] = []
    
    func perform(positions: [VNHumanBodyPoseObservation.JointName: CGPoint]) {
        midPositionsAlgorithm(positions: positions)
        angleFallDetectionAlgorithm(positions: positions)
        bodyRatioFallDetectionAlgorithm(positions: positions)
    }
    
    func resetAllData() {
        midYValues.removeAll()
    }
    
    private func midPositionsAlgorithm(positions: [VNHumanBodyPoseObservation.JointName: CGPoint]) {
        let leftHipYPosition = positions[.leftHip]?.y ?? 0
        let rightHipYPosition = positions[.rightHip]?.y ?? 0
        let midYPosition = (leftHipYPosition + rightHipYPosition) / 2.0
        
        midYValues.append(midYPosition)
        
        if midYValues.count > 4 {
            let sum = midYValues.reduce(1, +)
            let mean = CGFloat(sum) / CGFloat(midYValues.count)
            let result = judgeFallMidPosition(value: mean,
                                              threshold: 0.75)
            midYValues.removeAll()
            resultDelegate?.getMidYChangeAlgorithmResult(state: .done, 
                                                         result: result,
                                                         value: mean)
        } else {
            resultDelegate?.getMidYChangeAlgorithmResult(state: .progress, 
                                                         result: nil,
                                                         value: 0)
        }
        
    }
    
    
    private func judgeFallMidPosition(value: CGFloat,
                                      threshold: CGFloat) -> Bool {
        if value <= threshold {
            return false
        } else {
            return true
        }
    }
    
    private func angleFallDetectionAlgorithm(positions: [VNHumanBodyPoseObservation.JointName: CGPoint]) {
        let nosePoistionX = positions[.nose]?.x ?? 0
        let nosePoistionY = positions[.nose]?.y ?? 0
        
        let rightAnkleX = positions[.rightAnkle]?.x ?? 0
        let leftAnkleX = positions[.leftAnkle]?.x ?? 0
        
        let leftAnkleY = positions[.leftAnkle]?.y ?? 0
        let rightAnkleY = positions[.rightAnkle]?.y ?? 0
        
        let midAnkleX = (leftAnkleX + rightAnkleX) / 2.0
        let midAnkleY = (leftAnkleY + rightAnkleY) / 2.0
        
        let deltaX = midAnkleX - nosePoistionX
        let deltaY = midAnkleY - nosePoistionY
        
        let arcTanAngle = atan2(deltaY, deltaX)
        var angleInDegrees = arcTanAngle * (180 / .pi)
        angleInDegrees = abs(angleInDegrees)
        
        if angleInDegrees > 90 {
            angleInDegrees = 180 - angleInDegrees
        }

        resultDelegate?.getAngleAlgorithmResult(state: .done,
                                                result: judgeFallAngle(value: angleInDegrees,
                                                                       threshold: 55),
                                                value: angleInDegrees)
    }
    
    private func judgeFallAngle(value: CGFloat,
                                threshold: CGFloat) -> Bool {
        if value <= threshold {
            return true
        } else {
            return false
        }
    }
    
    
    private func bodyRatioFallDetectionAlgorithm(positions: [VNHumanBodyPoseObservation.JointName: CGPoint]) {
        let leftTop = positions[.rightWrist] ?? .zero
        let rightTop = positions[.leftWrist] ?? .zero
        let leftBottom = positions[.rightAnkle] ?? .zero
        
        let width = abs(leftTop.x - rightTop.x)
        let height = abs(leftTop.y - leftBottom.y)
        
        let result = judgeFallRatio(value: (width / height),
                                    threshold: 1.0)
        
        resultDelegate?.getRatioAlgorithmResult(state: .done,
                                                result: result,
                                                value: (width / height))
    }
    
    ///Value: 가로 / 세로 의 비율
    private func judgeFallRatio(value: CGFloat,
                                threshold: CGFloat) -> Bool {
        if value >= 1.0 {
            return true
        } else {
            return false
        }
    }
    
    
    

}
