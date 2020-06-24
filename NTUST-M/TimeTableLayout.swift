//
//  TimeTableLayout.swift
//  NTUST-M
//
//  Created by Jeffery Ho on 2020/6/23.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import UIKit

protocol TimeTableLayoutDelegate: AnyObject {
  func collectionView(_ collectionView: UICollectionView, eventAtIndexPath indexPath: IndexPath) -> TimeTableEvent
}


class TimeTableLayout: UICollectionViewLayout {
    
    enum LayoutType: String {
        case weekday, saturday, sunday
        
        var column: Int {
            switch self {
            case .weekday: return 6
            case .saturday: return 7
            case .sunday: return 8
            }
        }
        
        var keyName: String {
            switch self {
            case .weekday: return "weekday"
            case .saturday: return "saturday"
            case .sunday: return "sunday"
            }
        }
    }
    
    weak var delegate: TimeTableLayoutDelegate?

    var layoutType:LayoutType = .weekday
    private let numberOfColumns = LayoutType.weekday.column
    private let cellPadding: CGFloat = 2

    private var cache: [UICollectionViewLayoutAttributes] = []

    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
      guard let collectionView = collectionView else {
        return 0
      }
      let insets = collectionView.contentInset
      return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
      return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard /*cache.isEmpty,*/ let collectionView = collectionView
            else {
                return
        }
        
        let periodWidth = CGFloat(20)
        let columnWidth = (contentWidth - CGFloat(periodWidth)) / CGFloat(numberOfColumns - 1)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            if column != 0 {
                xOffset.append(CGFloat(periodWidth) + CGFloat(column - 1) * columnWidth)
            } else {
                xOffset.append(0.0)
            }
        }
        
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let event = delegate?.collectionView(collectionView, eventAtIndexPath: indexPath)
            let column = event!.day
            let eventHeight = event!.length
            let titleHeight = CGFloat(30)
            var height = CGFloat(eventHeight) * 60
            var frame: CGRect
            switch event!.type {
            case .course:
                frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            case .periodTitle:
                frame = CGRect(x: xOffset[column], y: yOffset[column], width: periodWidth, height: height)
            case .weekTitle:
                height = titleHeight
                frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            case .corner:
                height = titleHeight
                frame = CGRect(x: xOffset[column], y: yOffset[column], width: periodWidth, height: height)
            }
            
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
      var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
      
      // Loop through the cache and look for items in the rect
      for attributes in cache {
        if attributes.frame.intersects(rect) {
          visibleLayoutAttributes.append(attributes)
        }
      }
      return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
      return cache[indexPath.item]
    }
}
