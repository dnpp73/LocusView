import UIKit

class DPLocusView: UIView {
    
    // MARK:  Constans
    
    static let defaultCircleDiameter: CGFloat = 40.0
    
    static let defaultCircleColor: UIColor = UIColor.whiteColor()
    static let defaultTailColor:   UIColor = UIColor(white: 1.0, alpha: 0.5)
    
    static let defaultAnimationDuration:  NSTimeInterval = 0.5
    static let defaultTailHistorySeconds: NSTimeInterval = 1.0
    
    // MARK:  Public Ivars
    
    // 左上原点の (0.0, 0.0) <-> (1.0, 1.0)
    @IBInspectable var currentPoint: CGPoint {
        get {
            return normalizePoint(circleLayer.position)
        }
        set {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            circleLayer.removeAllAnimations()
            circleLayer.position = realizePoint(newValue)
            tailLayer.path = bezierPathFromPointHistories.CGPath
            CATransaction.commit()
        }
    }
    
    @IBInspectable var circleDiameter: CGFloat = defaultCircleDiameter {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            let rect = CGRectMake(0, 0, circleDiameter, circleDiameter)
            circleLayer.path   = UIBezierPath(ovalInRect: rect).CGPath
            circleLayer.bounds = rect
            tailLayer.path     = bezierPathFromPointHistories.CGPath
            CATransaction.commit()
        }
    }
    
    @IBInspectable var circleColor: UIColor = defaultCircleColor {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            circleLayer.fillColor = circleColor.CGColor
            CATransaction.commit()
        }
    }
    
    @IBInspectable var tailColor: UIColor = defaultTailColor {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            tailLayer.fillColor   = tailColor.CGColor
            CATransaction.commit()
        }
    }
    
    @IBInspectable var animationDuration:  NSTimeInterval = defaultAnimationDuration
    
    @IBInspectable var tailHistorySeconds: NSTimeInterval = defaultTailHistorySeconds
    
    // MARK:  Private Constants
    
    private let circleLayer: CAShapeLayer = { () -> CAShapeLayer in
        let circleLayer = CAShapeLayer()
        circleLayer.strokeColor = UIColor.clearColor().CGColor
        
        circleLayer.fillColor = defaultCircleColor.CGColor // circleColor の didSet でも変えているけど初期値を入れておく
        
        // circleDiameter の didSet でも変えているけど初期値をきちんと入れておく
        let rect = CGRectMake(0, 0, defaultCircleDiameter, defaultCircleDiameter)
        circleLayer.path     = UIBezierPath(ovalInRect: rect).CGPath
        circleLayer.bounds   = rect
        
        return circleLayer
    }()
    
    private let tailLayer: CAShapeLayer = { () -> CAShapeLayer in
        let tailLayer = CAShapeLayer()
        tailLayer.strokeColor = UIColor.clearColor().CGColor
        
        // tailColor の didSet でも変えているけど初期値を入れておく
        tailLayer.fillColor = defaultTailColor.CGColor
        
        return tailLayer
    }()
    
    private let timerInterval: NSTimeInterval = 1.0 / 60.0 // 60 fps ってことで

    // MARK:  Private Ivars
    
    private var timer: NSTimer?
    
    private var pointHistories: [CGPoint] = []
    
    private var pointHistoriesMaxCount: Int {
        get {
            return Int(tailHistorySeconds / timerInterval)
        }
    }
    
    private var currentPresentationPoint: CGPoint {
        get {
            let point: CGPoint
            if let p = circleLayer.presentationLayer() as? CALayer {
                point = p.position
            }
            else {
                point = circleLayer.position
            }
            return normalizePoint(point)
        }
    }
    
    private var bezierPathFromPointHistories: UIBezierPath {
        get {
            // pointHistories から隣合う重複を排除（単純な uniq ではないよ）して逆順にした配列を生成しとく
            let uniqPoints: [CGPoint] = { () -> [CGPoint] in
                var uniqPoints: [CGPoint] = []
                var beforePoint: CGPoint = currentPresentationPoint
                for point in pointHistories.reverse() {
                    if point == beforePoint {
                        continue
                    }
                    beforePoint = point
                    uniqPoints.append(point)
                }
                return uniqPoints
            }()
            
            func makeMoveToPoint(fromPoint: CGPoint, toPoint: CGPoint) -> CGPoint {
                let rx: CGFloat, ry: CGFloat
                if toPoint.x > fromPoint.x && toPoint.y >= fromPoint.y {
                    // 第 1 象限のときは第 2 象限に
                    rx = -1.0
                    ry =  1.0
                }
                else if fromPoint.x >= toPoint.x && toPoint.y > fromPoint.y {
                    // 第 2 象限のときは第 3 象限に
                    rx = -1.0
                    ry = -1.0
                }
                else if fromPoint.x > toPoint.x && fromPoint.y >= toPoint.y {
                    // 第 3 象限のときは第 4 象限に
                    rx =  1.0
                    ry = -1.0
                }
                else {
                    // 第 4 象限のときは第 1 象限に
                    rx =  1.0
                    ry =  1.0
                }
                let angle  = atan2(abs(toPoint.y-fromPoint.y), abs(toPoint.x-fromPoint.x))
                let real   = realizePoint(toPoint)
                let radius = circleDiameter / 2.0
                let dx     = sin(angle) * radius * rx
                let dy     = cos(angle) * radius * ry
                return CGPointMake(real.x + dx, real.y + dy)
            }
            
            let path: UIBezierPath = UIBezierPath()
            path.moveToPoint(realizePoint(currentPresentationPoint)) // 最初と最後は必ず現在の値
            
            var b = currentPresentationPoint
            for p in uniqPoints {
                path.addLineToPoint(makeMoveToPoint(b, toPoint: p))
                b = p
            }
            if let last = uniqPoints.last {
                path.addLineToPoint(realizePoint(last))
            }
            for p in uniqPoints.reverse() {
                path.addLineToPoint(makeMoveToPoint(b, toPoint: p))
                b = p
            }
            
            path.addLineToPoint(realizePoint(currentPresentationPoint)) // 最初と最後は必ず現在の値
            return path
        }
    }

    // MARK:  Initializer

    deinit {
        stopTimer()
    }
    
    private func commonInit() {
        // tail から順番に addSubLayer しないと重なり順が変になるよ
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.addSublayer(tailLayer)
        layer.addSublayer(circleLayer)
        CATransaction.commit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK:  UIView
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if let _ = window {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tailLayer.path = bezierPathFromPointHistories.CGPath
    }
    
    // MARK:  Move to Position
    
    internal func moveToPoint(point: CGPoint) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        
        circleLayer.position = realizePoint(point)
        tailLayer.path = bezierPathFromPointHistories.CGPath
        
        CATransaction.commit()
    }
    
    // MARK:  Convert Position
    
    private func normalizePoint(point: CGPoint) -> CGPoint {
        return CGPointMake(point.x / bounds.size.width, point.y / bounds.size.height);
    }
    
    private func realizePoint(point: CGPoint) -> CGPoint {
        return CGPointMake(point.x * bounds.size.width, point.y * bounds.size.height);
    }
    
    // MARK:  Timer
    
    private func startTimer() {
        stopTimer()
        let timer = NSTimer(timeInterval: timerInterval, target: self, selector: Selector("fireTimer:"), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        self.timer = timer
    }
    
    private func stopTimer() {
        if let timer = timer where timer.valid {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    // @objc や @IBAction を付けておけば Objective-C の msg_send() が効くので NSTimer からの呼び出しも private で定義出来る。
    @objc private func fireTimer(timer: NSTimer) {
        pointHistories.append(currentPresentationPoint)
        while pointHistories.count > pointHistoriesMaxCount {
            pointHistories.removeFirst()
        }
        setNeedsLayout()
    }
    
}