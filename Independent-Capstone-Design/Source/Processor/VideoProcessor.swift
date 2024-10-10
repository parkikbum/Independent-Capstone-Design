import AVFoundation

final class VideoProcessor {
    private var player: AVPlayer?
    private var videoOutput: AVPlayerItemVideoOutput?
    private var displayLink: CADisplayLink?
    weak var bufferDelegate: VideoProcessorDelegate?
    private var playerItemObserver: NSKeyValueObservation?
    var videoPlayEndCompletion: (() -> Void)?
    
    
    func startProcessing(videoName: String) {
        guard let path = Bundle.main.path(forResource: videoName,
                                          ofType: "mp4") else { return }
        let url = URL(filePath: path)
        setAsset(url: url)
    }
    
    private func setAsset(url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        let videoOutputSetting: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: videoOutputSetting)
        playerItem.add(videoOutput!)
        
        player = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidEnd),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
        playerItemObserver = playerItem.observe(\.status, options: [.new]) { [weak self] item, change in
            guard let self else { return }
            if item.status == .failed {
                print("Video play back Failed")
            }
        }
        
        displayLink = CADisplayLink(target: self,
                                    selector: #selector(displayLinkStarting))
        displayLink?.add(to: .main, forMode: .common)
        
        player?.play()
    }
    
    
    @objc
    private func displayLinkStarting() {
        guard let videoOutput = videoOutput, let currentTime = player?.currentTime() else { return }
        
        if videoOutput.hasNewPixelBuffer(forItemTime: currentTime) {
            guard let buffer = videoOutput.copyPixelBuffer(forItemTime: currentTime,
                                                           itemTimeForDisplay: nil) else { return }
            bufferDelegate?.getFrameBuffer(pixelBuffer: buffer,
                                           time: currentTime)
        }
    }
    
    @objc
    private func playerItemDidEnd() {
        videoPlayEndCompletion?()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        playerItemObserver?.invalidate()
    }
    
    
}
