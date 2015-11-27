import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var locusView: DPLocusView!
    
    @IBOutlet weak var controlPanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var locusPanGestureRecognizer:   UIPanGestureRecognizer!
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        locusView.currentPoint = CGPointMake(0.5, 0.5)
//    }
    
    @IBAction func handleControlPanGestureRecognizer(sender: UIPanGestureRecognizer) {
        guard sender == controlPanGestureRecognizer, let targetView = sender.view else {
            return
        }
        let location = sender.locationInView(targetView)
        let normalizedPoint = CGPointMake(location.x / targetView.bounds.size.width, location.y / targetView.bounds.size.height)
        locusView.moveToPoint(normalizedPoint)
    }
    
    @IBAction func handleLocusPanGestureRecognizer(sender: UIPanGestureRecognizer) {
        guard sender == locusPanGestureRecognizer, let targetView = sender.view where targetView == locusView else {
            return
        }
        let location = sender.locationInView(targetView)
        let normalizedPoint = CGPointMake(location.x / targetView.bounds.size.width, location.y / targetView.bounds.size.height)
        locusView.currentPoint = normalizedPoint
    }
    
}
