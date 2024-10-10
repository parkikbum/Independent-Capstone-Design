protocol FallDetectionProcessorDelegate: AnyObject {
    func getMidYChangeAlgorithmResult(state: PerformState, result: Bool?, value: Double)
    func getAngleAlgorithmResult(state: PerformState, result: Bool?, value: Double)
    func getRatioAlgorithmResult(state: PerformState, result: Bool?, value: Double)
}
