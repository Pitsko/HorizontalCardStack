//
//  RightDecorationView.swift
//  BuddyHOPP
//
//  Created by pradeep burugu on 7/28/16.
//  Copyright © 2016 Buddyhopp Inc. All rights reserved.
//

import HorizontalCardStack

class RightDecorationView: UICollectionReusableView {
    
    
    class var identifier: String {
        return "rightDecorationView"
    }
    
    override internal func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let decorationAttributes = layoutAttributes as! DecorationViewAttributes
        backgroundColor = decorationAttributes.backgroundColor
        layer.opacity = 0.0
        isHidden = true
        transform = CGAffineTransform(scaleX: 0.2, y: 0.2)

    }
    
}
