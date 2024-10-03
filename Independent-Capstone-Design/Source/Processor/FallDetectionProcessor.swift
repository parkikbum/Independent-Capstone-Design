import Foundation
import Vision

final class FallDetectionProcessor {
    weak var resultDelegate: FallDetectionProcessorDelegate?
    
    private var midYValues: [CGFloat] = []
    
    //골반 중심 좌표의 변화량을 이용한 낙상 분석 알고리즘
    func getMidPositionsAlgorithm(positions: [VNHumanBodyPoseObservation.JointName: CGPoint]) {
        let leftHipYPosition = positions[.leftHip]?.y ?? 0
        let rightHipYPosition = positions[.rightHip]?.y ?? 0
        let midYPosition = (leftHipYPosition + rightHipYPosition) / 2.0
        
        midYValues.append(midYPosition)
        
        //연속된 5개의 프레임 마다
        if midYValues.count > 4 {
            let sum = midYValues.reduce(1, +)
            let mean = CGFloat(sum) / CGFloat(midYValues.count)
            print("meanValue is : ", mean)
            let result = judgeFallMidPosition(value: mean,
                                              threshold: 0.75)
            midYValues.removeAll()
            resultDelegate?.getMidYChangeAlgorithmResult(state: .done, result: result)
        } else {
            resultDelegate?.getMidYChangeAlgorithmResult(state: .progress, result: nil)
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
    
    func angleFallDetectionAlgorithm(positions: [VNHumanBodyPoseObservation.JointName: CGPoint]) {
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
        
        print("angle Degree is : ", angleInDegrees)

        resultDelegate?.getAngleAlgorithmResult(state: .done,
                                                result: judgeFallAngle(value: angleInDegrees,
                                                                       threshold: 55))
    }
    
    private func judgeFallAngle(value: CGFloat,
                                threshold: CGFloat) -> Bool {
        if value <= threshold {
            return true
        } else {
            return false
        }
    }

}
