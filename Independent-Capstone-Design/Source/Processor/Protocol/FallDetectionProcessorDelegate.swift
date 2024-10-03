protocol FallDetectionProcessorDelegate: AnyObject {
    func getMidYChangeAlgorithmResult(state: PerformState, result: Bool?)
    func getAngleAlgorithmResult(state: PerformState, result: Bool?)
    func getRatioAlgorithmResult(state: PerformState, result: Bool?)
}
