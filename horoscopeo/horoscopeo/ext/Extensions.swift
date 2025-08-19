//
//  NibInstantiatable.swift
//  horoscopeo
//
//  Created by Azizbek Asadov on 11.08.2025.
//


import UIKit.UIColor
import UIKit.UIButton
import Stevia

extension TimeInterval {
    var formatTimeInterval: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter.string(from: self) ?? "00:00:00"
    }
}

extension UIButton {
    func startPulsatingAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.5 // Adjust the duration as needed
        pulseAnimation.fromValue = 0.95
        pulseAnimation.toValue = 1.0
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude // Infinite repeat
        
        layer.add(pulseAnimation, forKey: "pulsate")
    }
    
    func stopPulsatingAnimation() {
        layer.removeAnimation(forKey: "pulsate")
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(hex: Int) {
       self.init(
           red: (hex >> 16) & 0xFF,
           green: (hex >> 8) & 0xFF,
           blue: hex & 0xFF
       )
   }
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension UIStackView {
    
    @discardableResult
    func removeArrandedViews() -> Self {
        self.arrangedSubviews.forEach { $0.removeFromSuperview() }
        return self
    }
    
    @discardableResult
    func addArrangedViews(_ views: [UIView]) -> Self {
        views.forEach {
            self.addArrangedSubview($0)
        }
        return self
    }
}


extension UIView {
    func inContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = .init(hex: 0x2D6974).withAlphaComponent(0.25)
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
        
        view.subviews(self)
        view.fillContainer(padding: 12.0)
        
        return view
    }
}

import UIKit

extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.visibleViewController(from: rootViewController)
    }
    
    public var visibleViewControllerIgnoringBottomTabBar: UIViewController? {
        return UIWindow.visibleViewController(from: rootViewController,
                                              shouldIgnoreBottomTabBar: true)
    }
    
    public static func visibleViewController(from viewController: UIViewController?,
                                             shouldIgnoreBottomTabBar: Bool = false) -> UIViewController? {
        switch viewController {
        case let navigationController as UINavigationController:
            return UIWindow.visibleViewController(from: navigationController.visibleViewController,
                                                  shouldIgnoreBottomTabBar: shouldIgnoreBottomTabBar)
            
        case let tabBarController as UITabBarController:
            return UIWindow.visibleViewController(from: tabBarController.selectedViewController,
                                                  shouldIgnoreBottomTabBar: shouldIgnoreBottomTabBar)
            
        case let presentingViewController where viewController?.presentedViewController != nil:
            return UIWindow.visibleViewController(from: presentingViewController?.presentedViewController,
                                                  shouldIgnoreBottomTabBar: shouldIgnoreBottomTabBar)
        default:
            return viewController
        }
    }
    
    func closeAllModalControllers(completion: (()->Void)? = nil) {
        rootViewController?.dismiss(animated: true) {
            completion?()
        }
    }
    
    private func dismissModalNavigationControllerRecursively() {
        guard let navigationController = rootViewController?.presentedViewController as? UINavigationController else {
            return
        }
        
        navigationController.dismiss(animated: true) { [weak self] in
            self?.dismissModalNavigationControllerRecursively()
        }
    }
}
import UIKit.UIView

extension UIView {
    func round(_ corners: UIRectCorner, radii: CGFloat) {
        let path = UIBezierPath(
            roundedRect:self.bounds,
            byRoundingCorners:corners,
            cornerRadii: CGSize(width: radii, height:  radii)
        )

        let maskLayer = CAShapeLayer()

        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
}

extension UIView {
    // Start rotation
    func startRotation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1.0
        rotation.isCumulative = true
        rotation.repeatCount = .greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }

    // Stop rotation
    func stopRotation() {
        self.layer.removeAnimation(forKey: "rotationAnimation")
    }
    
    func animateBounce() {
        self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 6.0,
                       options: .allowUserInteraction) { [weak self] in
            self?.transform = .identity
        }
    }
    
    func setGradientBorderLayer(with colors: [UIColor], withLineWidth lineWidth: CGFloat = 1, cornerRadius: CGFloat = 0) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: self.frame.size)
        gradient.colors = colors.map { $0.cgColor }
        
        let shape = CAShapeLayer()
        shape.lineWidth = lineWidth
        shape.path = UIBezierPath(roundedRect: self.frame, cornerRadius: cornerRadius).cgPath
        shape.strokeColor = UIColor(hex: 0xFC7AFF).cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        self.layer.addSublayer(gradient)
        return gradient
    }
}

extension UIView {
    func fadeIn(_ duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.alpha = 1.0
    }, completion: completion)  }

    func fadeOut(_ duration: TimeInterval = 0.5, delay: TimeInterval = 1.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.alpha = 0.3
    }, completion: completion)
   }
}


import Foundation
import UIKit


extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes([.traits: [
            UIFontDescriptor.TraitKey.weight: weight]
                                                            ])
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}

extension NSMutableAttributedString {
    static func + (left: NSMutableAttributedString, right: NSMutableAttributedString) -> NSMutableAttributedString {
        let result = NSMutableAttributedString()
        result.append(left)
        result.append(right)
        return result
    }
}


import UIKit

public protocol NibInstantiatable {
    static func nibName() -> String
}

extension NibInstantiatable {
    static func nibName() -> String {
        return String(describing: self)
    }
}

extension NibInstantiatable where Self: UIView {
    static func fromNib() -> Self {
        let bundle = Bundle(for: self)
        let nib = bundle.loadNibNamed(nibName(), owner: self, options: nil)
        return nib!.first as! Self
    }
}


import UIKit

extension UIViewController {
    @objc
    func popCurrentViewController() {
        Navigation.close(self)
    }
    
    func withNavigation(isTransparent: Bool = false) -> UINavigationController {
        let nav = isTransparent ? TranslucentNavigationController(rootViewController: self) : CoreNavigationController(rootViewController: self)
        nav.overrideUserInterfaceStyle = .dark
        return nav
    }
}

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension String {
    var image: UIImage? {
        .init(named: self)
    }
}

extension Sequence {
    func createMatrix<S: Sequence>(from sequence: S, withColumns columns: Int) -> [[S.Element]] {
        var matrix: [[S.Element]] = []
        var currentRow: [S.Element] = []

        for element in sequence {
            if currentRow.count < columns {
                currentRow.append(element)
            } else {
                matrix.append(currentRow)
                currentRow = [element]
            }
        }

        if !currentRow.isEmpty {
            matrix.append(currentRow)
        }

        return matrix
    }
    
    func createMatrix(withColumns columns: Int) -> [[Self.Element]] {
        var matrix: [[Self.Element]] = []
        var currentRow: [Self.Element] = []

        for element in self {
            if currentRow.count < columns {
                currentRow.append(element)
            } else {
                matrix.append(currentRow)
                currentRow = [element]
            }
        }

        if !currentRow.isEmpty {
            matrix.append(currentRow)
        }

        return matrix
    }
}

extension Sequence {
    subscript<R>(range: R) -> [Element] where R: RangeExpression, R.Bound == Int {
        var result: [Element] = []
        
        for (index, element) in self.enumerated() {
            if range.contains(index) {
                result.append(element)
            }
        }
        return result
    }
}



import Foundation
import ObjectiveC

#if canImport(UIKit)
import UIKit

public protocol Clickable {
    var tapAction: () -> Void { get set }
    var longPressAction: () -> Void { get set }
    
    func addTapGesture(tapAction: @escaping () -> Void) -> Void
    func addLongPressGesture(duration: Double, longPressAction: @escaping () -> Void) -> Void
    func handleTap(sender: UITapGestureRecognizer) -> Void
    func handleLongPress(sender: UILongPressGestureRecognizer)
}

extension UIView: Clickable {
    
    private static var _tapAction = [String:(() -> Void)]()
    private static var _longPressAction = [String:(() -> Void)]()
    
    // Declare a global var to produce a unique address as the associated object handle
    private static var tapActionObjectHandle: UInt8 = 0
    private static var longPressActionObjectHandle: UInt8 = 1
    
    public var tapAction: () -> Void {
        get {
            return objc_getAssociatedObject(self, &UIView.tapActionObjectHandle) as! (() -> Void)
        }
        set {
            objc_setAssociatedObject(self, &UIView.tapActionObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var longPressAction: () -> Void {
        get {
            return objc_getAssociatedObject(self, &UIView.longPressActionObjectHandle) as! (() -> Void)
        }
        set {
            objc_setAssociatedObject(self, &UIView.longPressActionObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Handle tap
    @objc public func handleTap(sender: UITapGestureRecognizer) {
        self.tapAction()
    }
    
    /// Handle long press
    @objc public func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            self.longPressAction()
        }
    }
    
    /// Tap gesture
    public func addTapGesture(tapAction: @escaping () -> Void) {
        let tap = UITapGestureRecognizer(target: self , action: #selector(self.handleTap(sender:)))
        self.tapAction = tapAction
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    /// Long press
    public func addLongPressGesture(duration: Double = 0.5, longPressAction: @escaping () -> Void) {
        let longPress = UILongPressGestureRecognizer(target: self , action: #selector(self.handleLongPress(sender:)))
        self.longPressAction = longPressAction
        longPress.minimumPressDuration = duration
        longPress.delaysTouchesBegan = true
        self.addGestureRecognizer(longPress)
        self.isUserInteractionEnabled = true
    }
}

#endif

extension UIView {
    func spinMultipleTimesAndThenRotate(toDegree targetDegree: CGFloat, totalRotations: CGFloat, duration: TimeInterval, completion: (() -> Void)? = nil) {
        let totalRotationDegrees = 360 * totalRotations
        let initialTransform = self.transform

        UIView.animate(withDuration: duration, animations: {
            // Spin multiple times
            self.transform = self.transform.rotated(by: .pi * totalRotations)
        }) { _ in
            // After multiple spins, rotate to the target degree
            UIView.animate(withDuration: duration, animations: {
                self.transform = initialTransform.rotated(by: .pi * (totalRotations + (targetDegree / 180)))
            }, completion: { _ in
                // Call completion block if provided
                completion?()
            })
        }
    }
}
