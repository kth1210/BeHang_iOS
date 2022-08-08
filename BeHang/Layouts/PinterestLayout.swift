//
//  PinterestLayout.swift
//  BeHang
//
//  Created by 김태현 on 2022/08/03.
//

import UIKit

// 레이아웃에서 사진의 높이, 모든 항목의 높이를 동적으로 계산하는, 높이가 필요할 때 정보를 제공하는 protocol
protocol PinterestLayoutDelegate: AnyObject {
    //사진의 높이를 요청하는 메소드
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {
    //delegate 참조 유지
    weak var delegate: PinterestLayoutDelegate!
    
    //columns, cell padding 값 속성
    fileprivate var numberOfColumns = 2
    fileprivate var cellPadding: CGFloat = 6
    
    //연산된 속성을 캐시하는 배열, prepare()을 호출할 때 , 모든 아이템에 대한 속성을 연산하고 캐시로 이들을 추가,
    //collection view가 레이아웃 속성을 요청할 때, 효율적으로 이를 할 수 있고 이들을 매 시간 다시 연산하는 것 대신에 캐시에게 요청 가능
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    //content size를 저장하기 위해 선언한 속성
    fileprivate var contentHeight: CGFloat = 0
    
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    //collection view의 콘텐츠 사이즈를 반환하는 메소드의 재정의
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        //cache가 비어 있고 collection view가 존재할 때만 레이아웃 속성 연산
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        
        //열 넓이 기반 모든 column에 대해 x좌표와 함께 xOffset 배열을 채우고 선언
        //yOffset 배열은 모든 열에 대한 y위치를 추적
        //각 열의 첫번째 항목의 offset이기 때문에 yOffset의 각 값을 0으로 초기화
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        //단 하나의 섹션만 있는 레이아웃은 첫번째 섹션의 모든 아이템 반복
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            //프레임 계산, 넓이는 cellWidth, cell들 사이의 padding이 제거됨
            //사진의 높이는 delegate에게 요청, 이 높이를 기반으로 frame height를 연산하고 상단, 하단을 위해 cellPadding 미리 정의
            //현재 열의 x, y offset과 결합하여 속성에 의해 사용되는 insertFrame 생성
            let photoHeight = delegate.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath)
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            //인스턴스 생성하고 insertFrame을 사용하여 자체 프레임 설정, attributes를 캐시로 추가
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            //새롭게 계산된 프레임으로 여기기 위해 contentHeight를 확장
            //프레임 기반 현재 열에 대한 yOffset 증가
            //다음 아이템을 다음 열로 위치 시킴
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
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
