import UIKit

public class LocusView: UIView {
    
    // MARK:  Constans
    
    static public let defaultCircleDiameter: CGFloat = 40.0
    
    static public let defaultCircleColor = UIColor.white
    static public let defaultTailColor = UIColor(white: 1.0, alpha: 0.5)
    
    static public let defaultAnimationDuration:  TimeInterval = 0.5
    static public let defaultTailHistorySeconds: TimeInterval = 0.3
    
    // MARK:  Public Ivars
    
    // 左上原点の (0.0, 0.0) <-> (1.0, 1.0)
    @IBInspectable public var currentPoint: CGPoint {
        get {
            return normalize(point: circleLayer.position)
        }
        set {
            pointHistories.removeAll()
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            circleLayer.removeAllAnimations()
            circleLayer.position = realize(point: newValue)
            tailLayer.path = nil
            CATransaction.commit()
        }
    }
    
    @IBInspectable public var circleDiameter: CGFloat = LocusView.defaultCircleDiameter {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            let rect = CGRect(x: 0, y: 0, width: circleDiameter, height: circleDiameter)
            circleLayer.path    = UIBezierPath(ovalIn: rect).cgPath
            circleLayer.bounds  = rect
            tailLayer.lineWidth = circleDiameter
            CATransaction.commit()
        }
    }
    
    @IBInspectable public var circleColor: UIColor = LocusView.defaultCircleColor {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            circleLayer.fillColor = circleColor.cgColor
            CATransaction.commit()
        }
    }
    
    @IBInspectable public var tailColor: UIColor = LocusView.defaultTailColor {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            tailLayer.strokeColor = tailColor.cgColor
            CATransaction.commit()
        }
    }
    
    @IBInspectable public var animationDuration:  TimeInterval = LocusView.defaultAnimationDuration
    
    @IBInspectable public var tailHistorySeconds: TimeInterval = LocusView.defaultTailHistorySeconds
    
    // MARK:  Private Constants
    
    private let circleLayer: CAShapeLayer = { () -> CAShapeLayer in
        let circleLayer = CAShapeLayer()
        circleLayer.strokeColor = UIColor.clear.cgColor
        
        circleLayer.fillColor = defaultCircleColor.cgColor // circleColor の didSet でも変えているけど初期値を入れておく
        
        // circleDiameter の didSet でも変えているけど初期値をきちんと入れておく
        let rect = CGRect(x: 0, y: 0, width: defaultCircleDiameter, height: defaultCircleDiameter)
        circleLayer.path     = UIBezierPath(ovalIn: rect).cgPath
        circleLayer.bounds   = rect
        
        return circleLayer
    }()
    
    private let tailLayer: CAShapeLayer = { () -> CAShapeLayer in
        let tailLayer = CAShapeLayer()
        tailLayer.fillColor = UIColor.clear.cgColor
        tailLayer.lineJoin  = CAShapeLayerLineJoin.round
        tailLayer.lineCap   = CAShapeLayerLineCap.round
        
        // tailColor の didSet でも変えているけど初期値を入れておく
        tailLayer.strokeColor = defaultTailColor.cgColor
        tailLayer.lineWidth   = defaultCircleDiameter
        
        return tailLayer
    }()
    
    private let timerInterval: TimeInterval = 1.0 / 100.0 // 100 Hz ってことで

    // MARK:  Private Ivars
    
    private var timer: Timer?
    
    private var pointHistories: [CGPoint] = []
    
    private var pointHistoriesMaxCount: Int {
        return Int(tailHistorySeconds / timerInterval)
    }
    
    private var currentPresentationPoint: CGPoint {
        let point: CGPoint
        if let p = circleLayer.presentation() {
            point = p.position
        }
        else {
            point = circleLayer.position
        }
        return normalize(point: point)
    }
    
    private var bezierPathFromPointHistories: UIBezierPath {
        // pointHistories から隣合う重複を排除（単純な uniq ではないよ）して逆順にした配列を生成しとく
        // ここで隣合う距離が近いやつも排除しとくと割と綺麗な path になる
        let uniqPoints: [CGPoint] = { () -> [CGPoint] in
            var uniqPoints: [CGPoint] = []
            var beforePoint: CGPoint = currentPresentationPoint
            for point in pointHistories.reversed() {
                // 単純な重複削除
                if point == beforePoint {
                    continue
                }
                // 距離が近ければ削除。だいたい 0.5 くらいで良いと思う。あまり大きくしすぎるとカクカクになる。
                let distance: CGFloat = sqrt(pow(point.x - beforePoint.x, 2.0) + pow(point.y - beforePoint.y, 2.0)) * (bounds.size.width + bounds.size.height / 2.0)
                if distance < 0.5 {
                    continue
                }
                beforePoint = point
                uniqPoints.append(point)
            }
            return uniqPoints
        }()

        let path: UIBezierPath = UIBezierPath()
        path.move(to: realize(point: currentPresentationPoint)) // 最初と最後は必ず現在の値
        for p in uniqPoints {
            path.addLine(to: realize(point: p))
        }
        return path
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
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK:  UIView
    
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        if let _ = window {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        tailLayer.path = bezierPathFromPointHistories.cgPath
    }
    
    // MARK:  Move to Position
    
    public func move(to point: CGPoint) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut))
        
        circleLayer.position = realize(point: point)
        tailLayer.path = bezierPathFromPointHistories.cgPath
        
        CATransaction.commit()
    }
    
    // MARK:  Convert Position
    
    private func normalize(point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x / bounds.size.width, y: point.y / bounds.size.height)
    }
    
    private func realize(point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x * bounds.size.width, y: point.y * bounds.size.height)
    }
    
    // MARK:  Timer
    
    private func startTimer() {
        stopTimer()
        let timer = Timer(timeInterval: timerInterval, target: self, selector: Selector(("fireTimer:")), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
    
    private func stopTimer() {
        if let timer = timer, timer.isValid {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    // @objc や @IBAction を付けておけば Objective-C の msg_send() が効くので NSTimer からの呼び出しも private で定義出来る。
    @objc private func fireTimer(_ timer: Timer) {
        pointHistories.append(currentPresentationPoint)
        while pointHistories.count > pointHistoriesMaxCount {
            pointHistories.removeFirst()
        }
        setNeedsLayout()
    }
    
}
