import UIKit

@IBDesignable

public class EZYGradientView: UIView
{
    
    //MARK:- Properties
    /// First color of gradient i.e. it appears on top when angleº set to 0.0.
    @IBInspectable public var firstColor: UIColor = UIColor.white
        {
        didSet
        {
            if gradientLayer != nil
            {
                self.updateColors()
            }
        }
    }
    
    /// Second color of gradient i.e. it appears in bottom when angleº set to 0.0.
    @IBInspectable public var secondColor: UIColor = UIColor.white
        {
        didSet
        {
            if gradientLayer != nil
            {
                self.updateColors()
            }
        }
    }
    
    /// Angleº will describe the tilt of gradient.
    @IBInspectable public var angleº: Float = 45.0
        {
        didSet
        {
            // handle negative angles
            if angleº < 0.0 {
                angleº = 360.0 + angleº
            }
            
            // offset of 45 is needed to make logic work
            angleº = angleº + 45
            
            let multiplier = Int(angleº / 360)
            if (multiplier > 0)
            {
                angleº = angleº - Float(360 * multiplier)
            }
            
            if gradientLayer != nil
            {
                self.updatePoints()
            }
        }
    }
    
    /// Color ratio will describe the proportion of colors. It's value ranges from 0.0 to 1.0 default is 0.5.
    @IBInspectable public var colorRatio: Float = 0.5
        {
        didSet
        {
            assert(colorRatio >= 0 || colorRatio <= 1, "Color Ratio: Valid range is from 0.0 to 1.0")
            if gradientLayer != nil
            {
                self.updateLocation()
            }
        }
    }
    
    /// Fade intensity will describe the disperse of colors. It's value ranges from 0.0 to 1.0 default is 0.0.
    @IBInspectable public var fadeIntensity: Float = 0.0
        {
        didSet
        {
            assert(colorRatio >= 0 || colorRatio <= 1, "Fade Intensity: Valid range is from 0.0 to 1.0")
            if gradientLayer != nil
            {
                self.updateLocation()
            }
        }
    }
    
    /// Is blur allow to add visual effect on gradient view. Can't be change during run-time.
    @IBInspectable public var isBlur: Bool = false
        {
        didSet
        {
            if gradientLayer != nil
            {
                self.checkBlurStatusAndUpdateOpacity()
            }
        }
    }
    /// Blur opacity will describe the transparency of blur. It's value ranges from 0.0 to 1.0 default is 0.0. It is suggested to set EZYGradientView background color as clear color for better results.
    @IBInspectable public var blurOpacity: Float = 0.0
        {
        didSet
        {
            assert(blurOpacity >= 0 || blurOpacity <= 1, "Blur Opacity: Valid range is from 0.0 to 1.0")
            if gradientLayer != nil
            {
                self.checkBlurStatusAndUpdateOpacity()
            }
        }
    }
    
    private var blurView: UIVisualEffectView?
    public var blurLayer: CALayer?
    public var gradientLayer: CAGradientLayer?
    
    //MARK:- Designated Initializer
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }
    
    //MARK:- Draw Rect with steps
    
    override public func draw(_ rect: CGRect)
    {
        if gradientLayer == nil
        {
            gradientLayer = CAGradientLayer()
            gradientLayer!.frame = self.bounds
            layer.insertSublayer(gradientLayer!, at: 0)
        }
        self.updateColors()
        self.updatePoints()
        self.updateLocation()
        self.checkBlurStatusAndUpdateOpacity()
    }
    /**
     Step 1
     */
    private func updateColors()
    {
        gradientLayer!.colors = [firstColor.cgColor, secondColor.cgColor]
    }
    /*
     Step 2
     */
    private func updatePoints()
    {
        let points = startEndPoints()
        gradientLayer!.startPoint = points.0
        gradientLayer!.endPoint = points.1
    }
    /*
     Step 3
     */
    private func updateLocation()
    {
        let colorLoc = locations()
        gradientLayer!.locations = [NSNumber(value: colorLoc.0), NSNumber(value: colorLoc.1)]
    }
    /*
     Step 4
     */
    private func checkBlurStatusAndUpdateOpacity()
    {
        if isBlur
        {
            if blurView == nil
            {
                let blurEffect = UIBlurEffect(style: .light)
                blurView = UIVisualEffectView(effect: blurEffect)
                blurView?.frame = self.bounds
                blurLayer = blurView?.layer
            }
            gradientLayer!.colors = [blurColor(color: firstColor), blurColor(color: secondColor)]
            self.layer.insertSublayer(blurLayer!, below: gradientLayer)
        }
        else
        {
            blurLayer?.removeFromSuperlayer()
            blurLayer = nil
            blurView = nil
        }
    }
    
    //MARK:- Helpers
    
    private func blurColor(color: UIColor) -> CGColor
    {
        return color.withAlphaComponent(CGFloat(0.9 - (blurOpacity / 2))).cgColor
    }
    
    private func startEndPoints() -> (CGPoint, CGPoint)
    {
        var rotCalX: Float = 0.0
        var rotCalY: Float = 0.0
        
        // to convert from 0...360 range to 0...4
        let rotate = angleº / 90
        
        // 1...4 can be understood to denote the four quadrants
        if rotate <= 1
        {
            rotCalY = rotate
        }
        else if rotate <= 2
        {
            rotCalY = 1
            rotCalX = rotate - 1
        }
        else if rotate <= 3
        {
            rotCalX = 1
            rotCalY = 1 - (rotate - 2)
        }
        else if rotate <= 4
        {
            rotCalX = 1 - (rotate - 3)
        }
        
        let start = CGPoint(x: 1 - CGFloat(rotCalY), y: 0 + CGFloat(rotCalX))
        let end = CGPoint(x: 0 + CGFloat(rotCalY), y: 1 - CGFloat(rotCalX))
        
        return (start, end)
    }
    
    private func locations() -> (Float, Float)
    {
        let divider = fadeIntensity / self.divider()
        return(colorRatio - divider, colorRatio + divider)
    }
    
    private func divider() -> Float
    {
        if colorRatio == 0.1
        {
            return 10
        }
        if colorRatio < 0.5
        {
            let value = 0.5 - colorRatio + 0.5
            return 1 / (1 - value)
        }
        return 1 / (1 - colorRatio)
    }
}
