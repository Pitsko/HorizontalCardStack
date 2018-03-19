//
//  ViewController.swift
//  HorizontalCardStack
//
//  Created by andrei.pitsko on 03/12/2018.
//  Copyright (c) 2018 andrei.pitsko. All rights reserved.
//

import HorizontalCardStack

class ExampleViewController: UIViewController {

    fileprivate var scaleX: CGFloat = 0.0
    fileprivate var scaleY: CGFloat = 0.0
    fileprivate let offSetDecorationViewStateChange: CGFloat = 0.4 // 40 % of collectionView

    let colors = [UIColor(red: 48.0/255.0, green: 173.0/255.0, blue: 99.0/255.0, alpha: 1.0),
                         UIColor(red: 241.0/255.0, green: 155.0/255.0, blue: 44.0/255.0, alpha: 1.0),
                         UIColor(red: 80.0/255.0, green: 170.0/255.0, blue: 241.0/255.0, alpha: 1.0)]

    @IBOutlet weak var cardStack: UICollectionView!
    
    fileprivate let layout = HorizontalCardStackLayout()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout.register(UINib(nibName: "LeftDecorationView", bundle: nil), forDecorationViewOfKind: LeftDecorationView.identifier)
        layout.leftDecorationViewIdentifier = LeftDecorationView.identifier
        
        layout.register(UINib(nibName: "RightDecorationView", bundle: nil), forDecorationViewOfKind: RightDecorationView.identifier)
        layout.rigthDecorationViewIdentifier = RightDecorationView.identifier

        cardStack.register(StackBaseCardCell.classForCoder(), forCellWithReuseIdentifier: StackBaseCardCell.identifier)
        
        layout.delegate = self
        
        cardStack.collectionViewLayout = layout
        cardStack.dataSource = self
        layout.gesturesEnabled = true
        layout.cardSize = CGSize(width: cardStack.bounds.width - 8*2,  height: cardStack.bounds.height - layout.offset - CGFloat(layout.stackSize) * layout.verticalOffsetBetweenCardsInTopStack)
        cardStack.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ExampleViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StackBaseCardCell.identifier, for: indexPath)
        cell.backgroundColor = colors[indexPath.item % colors.count]

        return cell
    }
    
    
}

extension ExampleViewController: HorizontalCardStackLayoutDelegate {
    func topCardWasChanged(_ index: Int) {
        //
    }
    
    func cardWasMoved(_ index: Int, isLeftDirection: Bool) {
        //
    }
    
    //The gist of the animation is scale up one view and scale down the other view.
    func updateDecorationViews(_ velocity: CGFloat, width: CGFloat, frameOrigin: CGPoint, translationPosition: Float) {
        
        if velocity > 0 {
            for view in cardStack.subviews {
                if view is LeftDecorationView {
                    
                    if frameOrigin.x > layout.offSetFromOriginX {
                        scaleUp(translationPosition, view: view, name: "next_active_icon")
                        
                        if frameOrigin.x >= offSetDecorationViewStateChange * cardStack.frame.width {
                            changeScaleWhenActiveState(view, name: "next_active_icon")
                        }
                        
                        view.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                    }
                } else if view is RightDecorationView {
                    
                    if -frameOrigin.x < offSetDecorationViewStateChange*cardStack.frame.width {
                        scaleDown(-translationPosition, view: view, name: "discard_Inactive_icon")
                    }
                }
            }
        } else {
            for view in cardStack.subviews {
                
                if view is LeftDecorationView {
                    
                    if frameOrigin.x <= offSetDecorationViewStateChange*cardStack.frame.width {
                        scaleDown(translationPosition, view: view, name: "next_Inactive_icon")
                    }
                    
                } else if view is RightDecorationView {
                    
                    if frameOrigin.x < -layout.offSetFromOriginX {
                        
                        scaleUp(-translationPosition, view: view, name: "discard_active_icon")
                        
                        if frameOrigin.x <= -((0.4 * cardStack.frame.width)) {
                            
                            changeScaleWhenActiveState(view, name: "discard_active_icon")
                        }
                        
                        view.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                    }
                }
            }
        }
    }

    //scaling changes at the time from inactive to active state
    func changeScaleWhenActiveState(_ view: UIView, name: String) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(.easeInOut)
        view.backgroundColor = UIColor(patternImage: UIImage(named: name)!)
        scaleX = scaleX + layout.activeScaleState < layout.maxThresholdScale ? (scaleX + layout.activeScaleState): layout.maxThresholdScale
        scaleY = scaleY + layout.activeScaleState < layout.maxThresholdScale ? (scaleY + layout.activeScaleState): layout.maxThresholdScale
        UIView.commitAnimations()
    }
    
    //start Scaling
    func scaleUp(_ translationPosition: Float, view: UIView, name: String) {
        view.backgroundColor = UIColor(patternImage: UIImage(named: name)!)
        view.isHidden = false
        view.layer.opacity = translationPosition - layout.offSetOpacity
        view.layer.zPosition = layout.zIndexDecorationView
        scaleX = CGFloat(translationPosition) < layout.maxThresholdScale ? CGFloat(translationPosition): layout.maxThresholdScale
        scaleY = CGFloat(translationPosition) < layout.maxThresholdScale ? CGFloat(translationPosition): layout.maxThresholdScale
    }
    
    //end Scaling
    func scaleDown(_ translationPosition: Float, view: UIView, name: String) {
        view.layer.opacity = translationPosition
        view.backgroundColor = UIColor(patternImage: UIImage(named: name)!)
        scaleX = CGFloat(translationPosition) > layout.minThresholdScale ?   CGFloat(translationPosition) : layout.minThresholdScale
        scaleY = CGFloat(translationPosition) > layout.minThresholdScale ?   CGFloat(translationPosition) : layout.minThresholdScale
        view.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
    }

    
    func shouldCardBeMoved(_ isLeftDirection: Bool) -> Bool? {
        return true
    }
    
    
}
