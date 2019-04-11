import UIKit
import LocusView

final class ViewController: UIViewController {

    @IBOutlet private var locusView: LocusView!
    
    @IBOutlet private var controlPanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet private var locusPanGestureRecognizer:   UIPanGestureRecognizer!

    @IBOutlet private var diameterLabel:            UILabel!
    @IBOutlet private var diameterSlider:           UISlider!
    @IBOutlet private var animationDurationLabel:   UILabel!
    @IBOutlet private var animationDurationSlider:  UISlider!
    @IBOutlet private var tailHistorySecondsLabel:  UILabel!
    @IBOutlet private var tailHistorySecondsSlider: UISlider!
    
    @IBAction private func handlePanGestureRecognizer(_ sender: UIPanGestureRecognizer) {
        guard let targetView = sender.view else {
            return
        }
        
        let location = sender.location(in: targetView)
        let normalizedPoint = CGPoint(x: location.x / targetView.bounds.size.width, y: location.y / targetView.bounds.size.height)
        
        switch sender {
        case controlPanGestureRecognizer:
            locusView.move(to: normalizedPoint)
        case locusPanGestureRecognizer:
            locusView.currentPoint = normalizedPoint
        default:
            break
        }
    }
    
    @IBAction private func valueChangedDiameterSlider(_ sender: UISlider) {
        diameterLabel.text       = String(format: "%.2f", arguments: [sender.value])
        locusView.circleDiameter = CGFloat(sender.value)
    }
    
    @IBAction private func valueChangedAnimationDurationSlider(_ sender: UISlider) {
        animationDurationLabel.text = String(format: "%.2f", arguments: [sender.value])
        locusView.animationDuration = TimeInterval(sender.value)
    }
    
    @IBAction private func valueChangedTailHistorySecondsSlider(_ sender: UISlider) {
        tailHistorySecondsLabel.text = String(format: "%.2f", arguments: [sender.value])
        locusView.tailHistorySeconds = TimeInterval(sender.value)
    }
    
    @IBAction private func touchUpInsideRestoreDefaultButton(_ sender: UIButton) {
        let diameter             = LocusView.defaultCircleDiameter
        diameterSlider.value     = Float(diameter)
        diameterLabel.text       = String(format: "%.2f", arguments: [diameter])
        locusView.circleDiameter = CGFloat(diameter)
        
        let animationDuration         = LocusView.defaultAnimationDuration
        animationDurationSlider.value = Float(animationDuration)
        animationDurationLabel.text   = String(format: "%.2f", arguments: [animationDuration])
        locusView.animationDuration   = TimeInterval(animationDuration)
        
        let tailHistorySeconds         = LocusView.defaultTailHistorySeconds
        tailHistorySecondsSlider.value = Float(tailHistorySeconds)
        tailHistorySecondsLabel.text   = String(format: "%.2f", arguments: [tailHistorySeconds])
        locusView.tailHistorySeconds   = TimeInterval(tailHistorySeconds)
        
        locusView.circleColor = LocusView.defaultCircleColor
        locusView.tailColor   = LocusView.defaultTailColor
    }
    
    private var randomColor: UIColor {
        func randomFloat() -> CGFloat {
            return CGFloat(arc4random_uniform(50)) / CGFloat(100.0) + CGFloat(0.5)
        }
        return UIColor(red: randomFloat(), green: randomFloat(), blue: randomFloat(), alpha: randomFloat())
    }
    
    @IBAction private func touchUpInsideRandomCircleColorButton(_ sender: UIButton) {
        locusView.circleColor = randomColor
    }
    
    @IBAction private func touchUpInsideRandomTailColorButton(_ sender: UIButton) {
        locusView.tailColor = randomColor
    }
    
}
