//
//  StackCollectionViewLayout.swift
//  BuddyHOPP
//
//  Created by pradeep burugu on 7/22/16.
//  Copyright © 2016 Buddyhopp SA. All rights reserved.
//

public protocol StackCellProtocol {
    func willDragFinish()
}

public protocol HorizontalCardStackLayoutDelegate: class {
    func topCardWasChanged(_ index: Int)
    func cardWasMoved(_ index: Int, isLeftDirection: Bool)
    func updateDecorationViews(_ velocity: CGFloat, width: CGFloat, frameOrigin: CGPoint, translationPosition: Float)
    
    /**
        A signal that tells the Stack if it should move the card when a drag finishes. **Sending any value different than `nil` will override the default behavior**, which is to move if the card is passed a certain point on the left/right. If the value is not sent immediately, the card will stay in position until a value is sent.
     */
    func shouldCardBeMoved(_ isLeftDirection: Bool) -> Bool?
}

open class HorizontalCardStackLayout: UICollectionViewLayout, UIGestureRecognizerDelegate {
    
    open var leftDecorationViewIdentifier: String?
    open var rigthDecorationViewIdentifier: String?

    open class var topCardZIndex: Int {
        return 1000
    }
    
    open weak var delegate: HorizontalCardStackLayoutDelegate?
    
    private var hiddedCardsByIndex = [Int]()
    
    
    private var index: Int = 0 {
        didSet {
            collectionView?.performBatchUpdates({ [weak self] in
                _ = self?.invalidateLayout()
                if !self!.theLastDragDirectionIsLeft {
                     self?.draggedCellPath = nil
                }
            }, completion: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                    
                strongSelf.draggedCellPath = nil
                strongSelf.delegate?.topCardWasChanged(strongSelf.index)
            })
        }
    }
    
    private var currentIndexWithoutHiddenItems: Int {
        return indexWithoutHiddenItems(index) ?? 0
    }
    
    // number of cells to be shown on the colleciton view
    open var stackSize: Int = 3
    
    //default card size
    open var cardSize: CGSize = CGSize(width: 180, height: 300)
    
    open var cardInsets: UIEdgeInsets = UIEdgeInsets.zero
    
    //enable/disable gesture on the layout
    open var gesturesEnabled: Bool = false {
        didSet {
            if (gesturesEnabled) {
                let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                collectionView?.addGestureRecognizer(recognizer)
                panGestureRecognizer = recognizer
                panGestureRecognizer!.delegate = self
                
            } else {
                if let recognizer = panGestureRecognizer {
                    collectionView?.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
    
    private var theLastDragDirectionIsLeft = true
    
    //drag current indexPath
    private var draggedCellPath: IndexPath?
    
    private var initialCellCenter: CGPoint?
    
    //offset between the cards vertically.
    open let verticalOffsetBetweenCardsInTopStack: CGFloat = 5.0
    
    private let centralCardYPosition = 70
    
    //drag the cell
    private var panGestureRecognizer: UIPanGestureRecognizer?
    
    //minimum distance to be swiped on y-axis
    private let minimumYPanDistanceToSwipe: CGFloat = 10
    
    //minimum distance to be swiped on x-axis
    private let minimumXPanDistanceToSwipe: CGFloat = UIScreen.main.bounds.width/3
    
    //Offset from top of the collectionview
    open let offset: CGFloat = 0.0
    
    private let scaleStep: CGFloat = 0.04
    
    open let offSetDecorationView: CGFloat = 40.0
    open let decorationView: CGSize = CGSize(width: 64, height: 64) //default size for decoration view
    open let zIndexDecorationView: CGFloat = 999.5 // position of decoration views on layout
    
    open let maxThresholdScale: CGFloat = 1.15  // scaling max level
    open let minThresholdScale: CGFloat = 0.2  // scaling min level
    open let maxThresholdOpacity: Float = 1.0  // opacity max level
    open let maxThresholdTranslation: CGFloat = 1.0  // translation max level
    
    open let offSetFromOriginX: CGFloat = 33.0
    open let offSetOpacity: Float = 0.2 // opacity should not change as soon as view translation begins so subtract with minimum offSet.
    
    open let activeScaleState: CGFloat = 0.15 // increase scaling by 0.15 for decoration views in an active state.
    open let middleY: CGFloat = 35.0   // property is used to set the decoration view y - axis.
    
    
    // MARK: - Getting the Collection View Information
    
    override open var collectionViewContentSize : CGSize {
        return collectionView!.frame.size
    }
    
    // MARK: - Providing Layout Attributes
    
    open func reset() {
        draggedCellPath = nil
        hiddedCardsByIndex.removeAll()
        if index != 0 {
            index = 0
        }
    }
    
    open func hideCardWithIndex(_ index: Int) {
        hiddedCardsByIndex.append(index)
        if hiddedCardsByIndex.count == collectionView!.numberOfItems(inSection: 0) - 1 {
            gesturesEnabled = false
        } 
    }
    
    var collectionRect: CGRect!
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let indexPaths = indexPathsForElementsInRect(rect)
        
        var layoutAttributes = indexPaths.flatMap { self.layoutAttributesForItem(at: $0)}
        
        if  let leftDecorationViewIdentifier = leftDecorationViewIdentifier {
            let leftLayoutItem = layoutAttributesForDecorationView(ofKind: leftDecorationViewIdentifier, at: IndexPath(index: 0)) as! DecorationViewAttributes
            layoutAttributes.append(leftLayoutItem)
        }
        if let rigthDecorationViewIdentifier = rigthDecorationViewIdentifier {
            let rightLayoutItem = layoutAttributesForDecorationView(ofKind: rigthDecorationViewIdentifier, at: IndexPath(index: 0)) as! DecorationViewAttributes
            layoutAttributes.append(rightLayoutItem)
        }
        return layoutAttributes
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var result = UICollectionViewLayoutAttributes(forCellWith: indexPath)

        let itemWithoutHidden = indexWithoutHiddenItems(indexPath.item)
        
        
        if let itemWithoutHidden = itemWithoutHidden {
            let diff = itemWithoutHidden >= currentIndexWithoutHiddenItems ? (itemWithoutHidden - currentIndexWithoutHiddenItems) : (collectionView!.numberOfItems(inSection: 0) - hiddedCardsByIndex.count - currentIndexWithoutHiddenItems + itemWithoutHidden)
            
            if (diff < stackSize) {
                result = layoutAttributesForTopStackItemWithInitialAttributes(result)
            }
            else {
                result = layoutAttributesForBottomStackItemWithInitialAttributes(result, isLeftDirection: theLastDragDirectionIsLeft)
            }

            if indexPath.item == draggedCellPath?.item  {
                //workaround for zIndex
                result.transform3D = CATransform3DMakeTranslation(0, 0, 100000)
                result.zIndex = 100000
            } else {
                result.transform3D = CATransform3DConcat(CATransform3DMakeTranslation(0, 0, CGFloat(HorizontalCardStackLayout.topCardZIndex - diff)), result.transform3D)
                result.zIndex = HorizontalCardStackLayout.topCardZIndex - diff
            }
        } else {
            result = layoutAttributesForBottomStackItemWithInitialAttributes(result, isLeftDirection: theLastDragDirectionIsLeft)

        }
        //zIndex used to invert the cells to be started from index 0 to so on.
        result.isHidden = hiddedCardsByIndex.filter({$0 == indexPath.item}).count != 0
        
        if indexPath.item == draggedCellPath?.item  {
            //workaround for zIndex
            result.transform3D = CATransform3DMakeTranslation(0, 0, 100000)
            result.zIndex = 100000
            
        }
        return result
    }
    // MARK: - Implementation
    
    private func indexPathsForElementsInRect(_ rect: CGRect) -> [IndexPath] {
        
        var result = [IndexPath]()
        
        let count = collectionView!.numberOfItems(inSection: 0)
        
        let topStackCount = min(count - hiddedCardsByIndex.count, stackSize)

        var i = 0
        while  result.count < topStackCount  {
            if index + i < count {
                let newIndex = index + i
                if hiddedCardsByIndex.filter({$0 == newIndex}).count == 0 {
                    result.append(IndexPath(item: newIndex, section: 0))
                }
            } else {
                let newIndex = i - (count  - index)
                if hiddedCardsByIndex.filter({ $0 == newIndex}).count == 0 {
                    result.append(IndexPath(item: newIndex, section: 0))
                }
            }
            i = i + 1
        }
        
        return result
    }
    
    private func layoutAttributesForTopStackItemWithInitialAttributes(_ attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        if let itemWithoutHidden = indexWithoutHiddenItems(attributes.indexPath.row) {
            let stackPosition = itemWithoutHidden >= currentIndexWithoutHiddenItems ? (itemWithoutHidden - currentIndexWithoutHiddenItems) : (collectionView!.numberOfItems(inSection: 0) - hiddedCardsByIndex.count - currentIndexWithoutHiddenItems + itemWithoutHidden)

            configureAttributes(attributes, forStackPosition: stackPosition)
            attributes.isHidden = false
        }
    
        return attributes
    }
    
    private func layoutAttributesForBottomStackItemWithInitialAttributes(_ attributes: UICollectionViewLayoutAttributes, isLeftDirection: Bool = true) -> UICollectionViewLayoutAttributes {
        
        if isLeftDirection {
            attributes.frame = frameForDeletedCard()
        } else {
            configureAttributes(attributes, forStackPosition: stackSize - 1)
        }
        
        attributes.isHidden = true
        
        return attributes
    }
    
    private func configureAttributes(_ attributes: UICollectionViewLayoutAttributes, forStackPosition stackPosition: Int) {
        let scale = pow((1 - scaleStep), CGFloat(stackPosition))
        
        let y = offset +  verticalOffsetBetweenCardsInTopStack * CGFloat(stackPosition) + (1.0 - scale / 2.0) * cardSize.height
        let x = collectionView!.frame.size.width / 2.0
        
        attributes.center = CGPoint(x: x, y: y)
        attributes.size = cardSize
        
        attributes.transform3D = CATransform3DMakeScale(scale, scale, 1.0)
    }
    
    private func frameForDeletedCard() -> CGRect {
        
        let x = -3 * cardSize.width
        let y = offset
        
        let width = cardSize.width
        let height = cardSize.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    // MARK: - Handling the Pan Gesture
    
    @objc open func handlePan(_ sender: UIPanGestureRecognizer) {
        
      switch sender.state {
        case .began:
            let initialPanPoint = sender.location(in: collectionView)
            findDraggingCellByCoordinate(initialPanPoint)
        case .changed:
            let newCenter = sender.translation(in: collectionView!)
            updateCenterPositionOfDraggingCell(newCenter)
        case .ended:
            if let indexPath = draggedCellPath {
                finishedDragging(collectionView!.cellForItem(at: indexPath)!)
            }
        default:
            break
      }
    
    }
    
    private func findDraggingCellByCoordinate(_ touchCoordinate: CGPoint) {
        if let indexPath = collectionView?.indexPathForItem(at: touchCoordinate) {
            if indexPath.item >= index {
                draggedCellPath = IndexPath(item: index, section: 0)
                initialCellCenter = collectionView?.cellForItem(at: draggedCellPath!)?.center
            }
        }
    }
    
    private func updateCenterPositionOfDraggingCell(_ touchCoordinate:CGPoint) {
        if let strongDraggedCellPath = draggedCellPath {
            if let cell = collectionView?.cellForItem(at: strongDraggedCellPath) {
                
                var cellFrame = cell.frame
                //Pans horizontally.
                cellFrame.origin.x = initialCellCenter!.x + touchCoordinate.x
                cell.center = CGPoint(x: cellFrame.origin.x, y: self.initialCellCenter!.y)
                
                let velocity = panGestureRecognizer?.velocity(in: collectionView)
                
                let translation = panGestureRecognizer?.translation(in: collectionView)
            
                let position = (translation!.x / (0.4 * (collectionView!.frame.width))) > maxThresholdTranslation ? maxThresholdTranslation : (translation!.x / (0.4 * (collectionView!.frame.width)))
                
                delegate?.updateDecorationViews(velocity!.x, width: cellFrame.width, frameOrigin: cell.frame.origin, translationPosition: Float(position))

                
            }
        }
    }
    
    private func finishedDragging(_ cell: UICollectionViewCell) {
        
        // Default behaviour (in case signal sends nil, use default behaviour)
        // if delta is less that minimum distances then the cell will be moved back to it's original position.
        let deltaX = cell.center.x - initialCellCenter!.x
        theLastDragDirectionIsLeft = deltaX < 0
        let shouldCardBeMovedAccordingToDefaultBehavior = (abs(deltaX) > (0.4 * collectionView!.frame.width))

        let shouldCardBeMovedAccordingToDelegate = delegate?.shouldCardBeMoved(theLastDragDirectionIsLeft)
        
        let shouldCardBeMoved = shouldCardBeMovedAccordingToDelegate ?? shouldCardBeMovedAccordingToDefaultBehavior
        
        if let draggedCellPath = draggedCellPath, draggedCellPath.item == index {
            if !shouldCardBeMoved {
                if let cell = collectionView?.cellForItem(at: draggedCellPath) {
                    
                    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                        [weak self] () in guard let strongSelf = self else { return }
                        
                        cell.center = strongSelf.initialCellCenter!
                    }, completion: nil)
                }
            } else {
                if let cell = collectionView?.cellForItem(at: draggedCellPath) {
                    if let stackCell = cell as? StackCellProtocol {
                        stackCell.willDragFinish()
                    }
                    
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                        _ = (cell.center = CGPoint(x: (self.theLastDragDirectionIsLeft ? -1.5 : 2.5) * cell.frame.size.width, y: self.initialCellCenter!.y))
                    }, completion: {
                        [weak self] _ in  guard let strongSelf = self else { return }
                        
                        strongSelf.delegate?.cardWasMoved(strongSelf.index, isLeftDirection: strongSelf.theLastDragDirectionIsLeft)
                        strongSelf.updateToNextIndex()
                    })
                }
            }
        }
        initialCellCenter = CGPoint(x: 0, y: 0)
    }
    
    private func updateToNextIndex() {
        var wasFound = false
        for i in  (index+1 ..< collectionView!.numberOfItems(inSection: 0)) {
            if hiddedCardsByIndex.filter({ $0 == i}).count == 0 {
                index = i
                wasFound = true
                break
            }
        }
        
        if !wasFound {
            for i in 0 ..< index {
                if hiddedCardsByIndex.filter ({ $0 == i}).count == 0 {
                    index = i
                    break
                }
            }
        }
    }
    
    //MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        var result = true
        
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            
            let velocity = panGesture.velocity(in: collectionView)
            
            result = fabs(velocity.y) < fabs(velocity.x)
            
        }
        return result
    }
    
    private func indexWithoutHiddenItems(_ index: Int) -> Int? {
        
        if hiddedCardsByIndex.filter({$0 == index}).count == 1 {
            return nil
        }
        
        let realIndex = index - hiddedCardsByIndex.filter {$0 < index}.count
        return realIndex
    }
    
    override open func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
        
        let decorationAttributes: DecorationViewAttributes
        
        if elementKind == leftDecorationViewIdentifier {
            
            guard let leftDecorationViewIdentifier = leftDecorationViewIdentifier else {return nil}
            
            decorationAttributes = DecorationViewAttributes(forDecorationViewOfKind: leftDecorationViewIdentifier, with: indexPath)
            
            decorationAttributes.frame = CGRect(x: 28, y: collectionView!.frame.height/2 - middleY, width: decorationView.width, height: decorationView.height)

        } else {
            guard let rigthDecorationViewIdentifier = rigthDecorationViewIdentifier else {return nil}

            decorationAttributes = DecorationViewAttributes(forDecorationViewOfKind: rigthDecorationViewIdentifier, with: indexPath)
            decorationAttributes.frame = CGRect(x: collectionView!.frame.width - (offSetDecorationView + 56), y: collectionView!.frame.height/2 - middleY , width: decorationView.width, height: decorationView.height)
        }
    
        return decorationAttributes
    }

    override open class var layoutAttributesClass : AnyClass {
        return DecorationViewAttributes.self
    }
    
}

