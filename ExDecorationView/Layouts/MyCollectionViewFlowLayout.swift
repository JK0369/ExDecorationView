//
//  MyCollectionViewFlowLayout.swift
//  ExDecorationView
//
//  Created by Jake.K on 2022/03/07.
//

import UIKit

final class MyCollectionViewFlowLayout: UICollectionViewFlowLayout {
  override var collectionViewContentSize: CGSize {
    return .init(width: 100, height: 100)
  }
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    super.layoutAttributesForElements(in: rect)
  }
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    super.layoutAttributesForItem(at: indexPath)
  }
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    super.shouldInvalidateLayout(forBoundsChange: newBounds)
  }
  
  // SupplementaryView(Optional)
  override func layoutAttributesForSupplementaryView(
    ofKind elementKind: String,
    at indexPath: IndexPath
  ) -> UICollectionViewLayoutAttributes? {
    super.initialLayoutAttributesForAppearingDecorationElement(ofKind: elementKind, at: indexPath)
  }
  // DecorationView(Optional)
  override func layoutAttributesForDecorationView(
    ofKind elementKind: String,
    at indexPath: IndexPath
  ) -> UICollectionViewLayoutAttributes? {
    super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
  }
}

