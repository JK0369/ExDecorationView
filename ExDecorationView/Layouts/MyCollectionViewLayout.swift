//
//  MyCollectionViewLayout.swift
//  ExDecorationView
//
//  Created by Jake.K on 2022/03/07.
//

import UIKit

protocol MyLayoutDelegate: AnyObject {
  func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath) -> CGFloat
}

final class MyCollectionViewLayout: UICollectionViewLayout {
  private enum Metric {
    static let numberOfColumns = 2.0
    static let cellPadding = 6.0
  }
  
  weak var delegate: MyLayoutDelegate?
  private var cachedAttributes = [UICollectionViewLayoutAttributes]()
  private var contentHeight = 0.0
  private var contentWidth: CGFloat {
    guard let collectionView = self.collectionView else { return 0.0 }
    let insets = collectionView.contentInset
    let contentWidth = collectionView.bounds.width - (insets.left + insets.right)
    return contentWidth
  }
  
  // MARK: Required
  override var collectionViewContentSize: CGSize {
    CGSize(width: self.contentWidth, height: self.contentHeight)
  }
  override func prepare() {
    super.prepare()
    guard let collectionView = self.collectionView else { return }
    
    self.cachedAttributes.removeAll()
    let columnWidth = self.contentWidth / Metric.numberOfColumns
    let xOffsetList = (0...Int(Metric.numberOfColumns))
      .map { (column) -> CGFloat in
        let offset = columnWidth * CGFloat(column)
        return offset
      }
    
    var columnCount = 0
    var yOffsetList = [CGFloat](repeating: 0, count: Int(Metric.numberOfColumns))
    (0...Int(collectionView.numberOfItems(inSection: 0)))
      .forEach { [weak self] in
        let indexPath = IndexPath(item: $0, section: 0)
        let imageHeight = delegate?.collectionView(collectionView, heightForImageAtIndexPath: indexPath) ?? 0
        let totalHeight = Metric.cellPadding * 2 + imageHeight
        let frame = CGRect(
          x: xOffsetList[columnCount],
          y: yOffsetList[columnCount],
          width: columnWidth,
          height: totalHeight
        )
        let insetFrame = frame.insetBy(dx: Metric.cellPadding, dy: Metric.cellPadding)
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = insetFrame
        self?.cachedAttributes.append(attributes)
        
        self?.contentHeight = max(self?.contentHeight ?? 0, insetFrame.maxY)
        yOffsetList[columnCount] = yOffsetList[columnCount] + totalHeight
        columnCount = columnCount < (Int(Metric.numberOfColumns) - 1) ? (columnCount + 1) : 0
      }
  }
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    super.layoutAttributesForElements(in: rect)
    var attributesResult = [UICollectionViewLayoutAttributes]()
    
    guard
      let lastIndex = self.cachedAttributes.indices.last,
      let matchIndex = self.getIndexUsingBinarySearch(rect, start: 0, end: lastIndex)
    else { return attributesResult }
    
    // 찾은 rect의 상단보다 아래에 있는 것들
    _ = self.cachedAttributes[..<matchIndex].reversed()
      .filter { rect.minY <= $0.frame.maxY }
      .map { attributesResult.append($0) }
    
    // 찾은 rect의 하단보다 위에 있는 것들
    _ = self.cachedAttributes[matchIndex...]
      .filter { $0.frame.minY <= rect.maxY }
      .map { attributesResult.append($0) }
    
    return attributesResult
  }
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    super.layoutAttributesForItem(at: indexPath)
    return self.cachedAttributes[indexPath.item]
  }
  
  // MARK: SupplementaryView, DecorationView
//  override func layoutAttributesForSupplementaryView(
//    ofKind elementKind: String,
//    at indexPath: IndexPath
//  ) -> UICollectionViewLayoutAttributes? {
//    super.initialLayoutAttributesForAppearingDecorationElement(ofKind: elementKind, at: indexPath)
//  }
  override func layoutAttributesForDecorationView(
    ofKind elementKind: String,
    at indexPath: IndexPath
  ) -> UICollectionViewLayoutAttributes? {
    super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    let attributes = self.cachedAttributes[indexPath.row]
    attributes.frame = attributes.frame.insetBy(dx: -20, dy: -20)
    return attributes
  }
  
  private func getIndexUsingBinarySearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
    if end < start { return nil }
    
    let mid = (start + end) / 2
    let attr = self.cachedAttributes[mid]
    
    /// intersects: 교집합
    if attr.frame.intersects(rect) {
      return mid
    } else {
      if attr.frame.maxY < rect.minY {
        return self.getIndexUsingBinarySearch(rect, start: (mid + 1), end: end)
      } else {
        return self.getIndexUsingBinarySearch(rect, start: start, end: (mid - 1))
      }
    }
  }
}
