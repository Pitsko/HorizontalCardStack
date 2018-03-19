//
//  StackBaseCardCell.swift
//  BuddyHOPP
//
//  Created by Andrei Pitsko on 8/23/16.
//  Copyright © 2016 Buddyhopp Inc. All rights reserved.
//
import HorizontalCardStack

class StackBaseCardCell: UICollectionViewCell, StackCellProtocol {
    
    @IBOutlet private var borderView: UIView!
    
    private let overlayView = UIView()

    class var identifier: String {
        return "StackBaseCardCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderView.layer.borderWidth = 1.0
        borderView.layer.borderColor = UIColor.black.cgColor
        
        borderView.addSubview(overlayView)

        overlayView.backgroundColor = UIColor.white
        overlayView.alpha = 0.8
        
        
        overlayView.topAnchor.constraint(equalTo: borderView.topAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor).isActive = true
        overlayView.leadingAnchor.constraint(equalTo: borderView.layoutMarginsGuide.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: borderView.layoutMarginsGuide.trailingAnchor).isActive = true
        
    }
    
    internal func willDragFinish() {
        isUserInteractionEnabled = false
        overlayView.isHidden = false

    }

    private var expectedCenter: CGPoint = CGPoint.zero
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let shouldShowOverlay = layoutAttributes.zIndex < HorizontalCardStackLayout.topCardZIndex
        overlayView.isHidden = !shouldShowOverlay
        isUserInteractionEnabled = !shouldShowOverlay
        
        expectedCenter = layoutAttributes.center
        
    }
    
}
