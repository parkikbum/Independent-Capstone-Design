protocol FallDetectionProcessorDelegate: AnyObject {
    func getMidYChangeAlgorithmResult(state: PerformState, result: Bool?)
}
