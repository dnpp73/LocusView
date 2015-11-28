import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var locusView: LocusView!
    
    @IBOutlet weak var controlPanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var locusPanGestureRecognizer:   UIPanGestureRecognizer!
    
    @IBOutlet weak var diameterLabel:            UILabel!
    @IBOutlet weak var diameterSlider:           UISlider!
    @IBOutlet weak var animationDurationLabel:   UILabel!
    @IBOutlet weak var animationDurationSlider:  UISlider!
    @IBOutlet weak var tailHistorySecondsLabel:  UILabel!
    @IBOutlet weak var tailHistorySecondsSlider: UISlider!
    
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
        diameterLabel.text       = String(format: "%.2f", arguments: [sender.value])
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
    
    @IBAction func touchUpInsideRestoreDefaultButton(sender: UIButton) {
        let diameter             = LocusView.defaultCircleDiameter
        diameterSlider.value     = Float(diameter)
        diameterLabel.text       = String(format: "%.2f", arguments: [diameter])
        locusView.circleDiameter = CGFloat(diameter)
        
        let animationDuration         = LocusView.defaultAnimationDuration
        animationDurationSlider.value = Float(animationDuration)
        animationDurationLabel.text   = String(format: "%.2f", arguments: [animationDuration])
        locusView.animationDuration   = NSTimeInterval(animationDuration)
        
        let tailHistorySeconds         = LocusView.defaultTailHistorySeconds
        tailHistorySecondsSlider.value = Float(tailHistorySeconds)
        tailHistorySecondsLabel.text   = String(format: "%.2f", arguments: [tailHistorySeconds])
        locusView.tailHistorySeconds   = NSTimeInterval(tailHistorySeconds)
        
        locusView.circleColor = LocusView.defaultCircleColor
        locusView.tailColor   = LocusView.defaultTailColor
    }
    
    private var randomColor: UIColor {
        get {
            func randomFloat() -> CGFloat {
                return CGFloat(arc4random_uniform(50)) / CGFloat(100.0) + CGFloat(0.5)
            }
            return UIColor(red: randomFloat(), green: randomFloat(), blue: randomFloat(), alpha: randomFloat())
        }
    }
    
    @IBAction func touchUpInsideRandomCircleColorButton(sender: UIButton) {
        locusView.circleColor = randomColor
    }
    
    @IBAction func touchUpInsideRandomTailColorButton(sender: UIButton) {
        locusView.tailColor = randomColor
    }
    
}
