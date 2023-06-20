//
//  DiscoverCardFlowLayout.swift
//  omnii
//
//  Created by huyang on 2023/6/2.
//

import UIKit

private let maxScaleOffset: CGFloat = 180
private let minScale: CGFloat = 13.0 / 19.0
private let minAlpha: CGFloat = 1

final class DiscoverCardFlowLayout: UICollectionViewFlowLayout {
    
    private var lastCollectionViewSize: CGSize = CGSize.zero

    required init?(coder aDecoder: NSCoder) {
      fatalError()
    }
    
    override init() {
        super.init()
        scrollDirection = .horizontal
        itemSize = CGSize(width: 190.rpx, height: 337.rpx)
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)

        guard let collectionView = collectionView else { return }

        if collectionView.bounds.size != lastCollectionViewSize {
            configureInset()
            lastCollectionViewSize = collectionView.bounds.size
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attribute = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }
        
        centerScaledAttribute(attribute: attribute)
        
        return attribute
    }
  
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        guard case let newAttributesArray as [UICollectionViewLayoutAttributes] = NSArray(array: attributes, copyItems: true) else {
            return nil
        }
        
        newAttributesArray.forEach { attribute in
            centerScaledAttribute(attribute: attribute)
        }
        
        return newAttributesArray
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                             withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = collectionView else {
            return proposedContentOffset
        }

        let proposedRect = CGRect(x: proposedContentOffset.x,
                                  y: 0,
                                  width: collectionView.bounds.width,
                                  height: collectionView.bounds.height)
        
        guard let layoutAttributes = layoutAttributesForElements(in: proposedRect), layoutAttributes.count > 0 else {
            return proposedContentOffset
        }

        var shouldBeChosenAttributes: UICollectionViewLayoutAttributes?
        var shouldBeChosenIndex: Int = -1

        let proposedCenterX = proposedRect.midX
      
        for (i, attributes) in layoutAttributes.enumerated() {
            guard attributes .representedElementCategory == .cell else { continue }
            
            guard let currentChosenAttributes = shouldBeChosenAttributes else {
                shouldBeChosenAttributes = attributes
                shouldBeChosenIndex = i
                continue
            }
            
            if (abs(attributes.frame.midX - proposedCenterX) < abs(currentChosenAttributes.frame.midX - proposedCenterX)) {
                shouldBeChosenAttributes = attributes
                shouldBeChosenIndex = i
            }
            
        }
        
        // Adjust the case where a quick but small scroll occurs.
        if (abs(collectionView.contentOffset.x - proposedContentOffset.x) < itemSize.width) {
            
            if velocity.x < -0.3 {
                shouldBeChosenIndex = shouldBeChosenIndex > 0 ? shouldBeChosenIndex - 1 : shouldBeChosenIndex
                
            } else if velocity.x > 0.3 {
            
                shouldBeChosenIndex = shouldBeChosenIndex < layoutAttributes.count - 1 ?
                shouldBeChosenIndex + 1 : shouldBeChosenIndex
            }
            
            shouldBeChosenAttributes = layoutAttributes[shouldBeChosenIndex]
        }
        
        guard let finalAttributes = shouldBeChosenAttributes else {
            return proposedContentOffset
        }
        
        return CGPoint(x: finalAttributes.frame.midX - collectionView.bounds.size.width / 2,
                       y: proposedContentOffset.y)
    }

}

extension DiscoverCardFlowLayout {
    
    private func centerScaledAttribute(attribute: UICollectionViewLayoutAttributes) {
        guard let collectionView = collectionView else { return }
        
        let visibleRect = CGRect(x: collectionView.contentOffset.x,
                                 y: collectionView.contentOffset.y,
                                 width: collectionView.bounds.size.width,
                                 height: collectionView.bounds.size.height)
        let visibleCenterX = visibleRect.midX
        let distanceFromCenter = visibleCenterX - attribute.center.x
        let distance = min(abs(distanceFromCenter), maxScaleOffset)
        let scale = distance * (minScale - 1) / maxScaleOffset + 1
        attribute.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        attribute.alpha = distance * (minAlpha - 1) / maxScaleOffset + 1
    }
  
    private func configureInset() -> Void {
        guard let collectionView = collectionView else { return }
        
        let inset = collectionView.bounds.size.width / 2 - itemSize.width / 2
        collectionView.contentInset  = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        collectionView.contentOffset = CGPoint(x: -inset, y: 0)
    }
    
}
