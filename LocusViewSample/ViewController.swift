import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var locusView: DPLocusView!
    
    @IBOutlet weak var controlPanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var locusPanGestureRecognizer:   UIPanGestureRecognizer!
    
    @IBOutlet weak var diameterLabel:           UILabel!
    @IBOutlet weak var animationDurationLabel:  UILabel!
    @IBOutlet weak var tailHistorySecondsLabel: UILabel!
    
    @IBAction func handlePanGestureRecognizer(sender: UIPanGestureRecognizer) {
        guard let targetView = sender.view else {
            return
        }
        
        let location = sender.locationInView(targetView)
        let normalizedPoint = CGPointMake(location.x / targetView.bounds.size.width, location.y / targetView.bounds.size.height)
        
        switch sender {
        case controlPanGestureRecognizer:
            locusView.moveToPoint(normalizedPoint)
        case locusPanGestureRecognizer:
            locusView.currentPoint = normalizedPoint
        default:
            break
        }
    }
    
    @IBAction func valueChangedDiameterSlider(sender: UISlider) {
        diameterLabel.text = String(format: "%.2f", arguments: [sender.value])
        locusView.circleDiameter = CGFloat(sender.value)
    }
    
    @IBAction func valueChangedAnimationDurationSlider(sender: UISlider) {
        animationDurationLabel.text = String(format: "%.2f", arguments: [sender.value])
        locusView.animationDuration = NSTimeInterval(sender.value)
    }
    
    @IBAction func valueChangedTailHistorySecondsSlider(sender: UISlider) {
        tailHistorySecondsLabel.text = String(format: "%.2f", arguments: [sender.value])
        locusView.tailHistorySeconds = NSTimeInterval(sender.value)
    }
}
