//
//  LeftDecorationView.swift
//  BuddyHOPP
//
//  Created by pradeep burugu on 7/28/16.
//  Copyright © 2016 Buddyhopp Inc. All rights reserved.
//

import HorizontalCardStack

class LeftDecorationView: UICollectionReusableView {
    
    class var identifier: String {
        return "leftDecorationView"
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let decorationAttributes = layoutAttributes as! DecorationViewAttributes
        backgroundColor = decorationAttributes.backgroundColor
        layer.opacity = 0.0
        isHidden = true // To avoid weird UI behaviror hide it until the user starts to swipe.
        transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
    }
}
