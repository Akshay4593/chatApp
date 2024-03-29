//
//  FloatingTextField.swift
//  ChatApp
//
//  Created by Akshay Shedge on 18/09/19.
//  Copyright © 2019 Akshay Shedge. All rights reserved.
//

import Foundation
import UIKit


// add new style here, for more customization according to your app design.
enum TextFieldStyle {
    case green
    case red
    case gray
}

@IBDesignable class FloatingTextField: UITextField {
    
    @IBInspectable var highlightColour: UIColor? = .gray
    var noInputHighlightColor: UIColor? = .gray
    let placeholderLabel = UILabel()
    let bottomLayer = CAShapeLayer()
    
    lazy var strokeEndAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 1
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        return animation
    }()
    
    lazy var strokeStartAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.toValue = 0
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        return animation
    }()
    
    override var text: String?{
        willSet{
            self.setStyle(style: .gray)
            self.animatePlaceholderLabelUp()
        }
    }
    
    override func awakeFromNib() {
        
        setupPlaceholderLabel()
        animatePlaceHolderLabelDown()
    }
    
    fileprivate func setupPlaceholderLabel() {
        addSubview(placeholderLabel)
        self.delegate = self
        
        // need these to work animate properly
        self.placeholderLabel.minimumScaleFactor = 0.3
        self.placeholderLabel.adjustsFontSizeToFitWidth = true
        self.placeholderLabel.lineBreakMode = .byClipping
        self.placeholderLabel.numberOfLines = 0
        
        self.placeholderLabel.text = self.placeholder
        self.placeholder?.removeAll()
        
        //Bottom Line CAlayer name
        bottomLayer.name = "bottomLine"
        
        // Change colour
        self.placeholderLabel.font = self.font
        self.placeholderLabel.textColor = .lightGray
        self.borderStyle = .none
        self.setBottomBorder(color: .lightGray)
        
    }
    
    // MARK:- Use this function to set default colour of Floating label's text- Can be customized.
    func setStyle(style: TextFieldStyle) {
        layoutIfNeeded()
        
        switch style {
        case .green:
            self.setBottomBorder(color: #colorLiteral(red: 0.1093588177, green: 0.5, blue: 0.1868519905, alpha: 1))
            animatePlaceholderLabelUp()
            
        case .gray:
            self.setBottomBorder(color: .lightGray)
            self.placeholderLabel.textColor = .lightGray
            
        case .red:
            self.setBottomBorder(color: #colorLiteral(red: 1, green: 0.1511251674, blue: 0.08996533756, alpha: 0.8503050086))
            self.placeholderLabel.textColor = .red
        }
        
    }
    
    func showWrongInput() {
        
        if noInputHighlightColor != nil {
            self.setBottomBorder(color: noInputHighlightColor!)
            self.placeholderLabel.textColor = noInputHighlightColor!
            self.placeholderLabel.alpha = 0.8
            
        }
        else{
            setStyle(style: .red)
        }
    }
    
}

// MARK:- TextField delegate functions.

extension FloatingTextField : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if !Thread.isMainThread {
            print("Called from background thread")
            return
        }
        
        self.setBottomBorder(color: highlightColour!)
        animatePlaceholderLabelUp()
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.setStyle(style: .gray)
        if textField.text == "" {
            if noInputHighlightColor != nil {
                self.setBottomBorder(color: noInputHighlightColor!)
            }
            else{
                self.setBottomBorder(color: .red)
            }
            animatePlaceHolderLabelDown()
        }
    }
}

// MARK:- Floating Label Animation functions.

extension FloatingTextField {
    
    fileprivate func setBottomBorder(color: UIColor) {
        
        let existingBottomLayer = layer.sublayers?.filter({ layer in
            layer.name == bottomLayer.name })
        
        if (existingBottomLayer?.count)! > 0 {
            guard let bottomShapelayer = existingBottomLayer![0] as? CAShapeLayer else { return }
            bottomShapelayer.strokeColor = color.cgColor
        }
        else {
            
            let bezPath = UIBezierPath()
            bezPath.move(to: CGPoint(x: bounds.minX, y: bounds.maxY + 1))
            bezPath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY + 1))
            bottomLayer.path = bezPath.cgPath
            bottomLayer.opacity = 0.8
            bottomLayer.lineCap = .round
            bottomLayer.strokeColor = color.cgColor
            bottomLayer.lineWidth = 0.6
            
            bottomLayer.strokeStart = 0.5
            bottomLayer.strokeEnd = 0.5
            
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = 0.5
            animationGroup.animations = [strokeStartAnimation,strokeEndAnimation]
            animationGroup.isRemovedOnCompletion = false
            animationGroup.fillMode = .forwards
            
            bottomLayer.add(animationGroup, forKey: "strokeAnimation")
            layer.addSublayer(bottomLayer)
        }
    }
    
    fileprivate func animatePlaceholderLabelUp() {
        
        let heightSmall = self.bounds.height * 0.5
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.placeholderLabel.frame = CGRect(x: 0,
                                                     y: self.bounds.minY - heightSmall,
                                                     width: self.bounds.width,
                                                     height: heightSmall )
                self.placeholderLabel.textColor =  self.highlightColour
            })
        }
    }
    
    fileprivate func animatePlaceHolderLabelDown() {
        let heightlarge = self.bounds.height * 0.95
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.placeholderLabel.frame = CGRect(x: 0,
                                                     y: 0,
                                                     width: self.bounds.width,
                                                     height: heightlarge)
            })
        }
    }
}
