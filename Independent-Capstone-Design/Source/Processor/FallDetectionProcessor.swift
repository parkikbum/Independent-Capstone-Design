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

}
