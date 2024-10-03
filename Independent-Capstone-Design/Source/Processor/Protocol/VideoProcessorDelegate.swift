import Foundation
import AVFoundation

protocol VideoProcessorDelegate: AnyObject {
    func getFrameBuffer(pixelBuffer: CVPixelBuffer,
                        time: CMTime)
}
