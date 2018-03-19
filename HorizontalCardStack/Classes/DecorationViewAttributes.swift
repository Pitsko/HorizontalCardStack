//
//  LeftDecorationViewAttributes.swift
//  BuddyHOPP
//
//  Created by pradeep burugu on 8/1/16.
//  Copyright © 2016 Buddyhopp Inc. All rights reserved.
//

import UIKit

open class DecorationViewAttributes: UICollectionViewLayoutAttributes {
    
    open var backgroundColor = UIColor.clear
    
    override open func copy(with zone: NSZone?) -> Any {
       let copy = super.copy(with: zone) as! DecorationViewAttributes
        copy.backgroundColor = backgroundColor
        return copy
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
       return super.isEqual(object)
        && backgroundColor == (object as! DecorationViewAttributes).backgroundColor
    }
    
}
