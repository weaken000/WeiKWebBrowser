//
//  WKFlowLayout.m
//  WKWebView_demo
//
//  Created by mc on 2018/4/11.
//  Copyright © 2018年 weaken. All rights reserved.
//

#import "WKFlowLayout.h"


@implementation WKFlowLayout {
    NSMutableArray<UICollectionViewLayoutAttributes *> *_attributesArray;
    NSMutableArray *_tranlationArray;
    NSMutableArray *_beginOffsetArray;
    CGFloat _totalH;
    NSMutableArray *_frameArray;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    CGFloat itemW = self.collectionView.bounds.size.width;
    self.itemSize = CGSizeMake(itemW, itemW / 0.7);
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.minimumLineSpacing = 0;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}
//大小变换的二次函数
double scaleZoom(float limitY, float minScale, float currentY) {
    double a = (minScale - 1) / limitY / limitY;
    return a * currentY * currentY + 1;
}

double scaleY(float radius, float currentD) {
    return sqrt(radius * radius - currentD * currentD);
}
//
//- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
//    NSMutableArray *atts = [NSMutableArray array];
//    for (int i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
//        [atts
//         addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]];
//    }
//    return atts;
//}
//
//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
//     UICollectionViewLayoutAttributes *atti = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
//    CGRect frame = CGRectZero;
//    frame.size   = CGSizeMake(self.collectionView.bounds.size.width, 50 * indexPath.row);
//    frame.origin = CGPointMake(0, self.collectionView.contentOffset.y + 25 * indexPath.row);
//    atti.frame   = frame;
//    return atti;
//}
//
//- (NSDictionary *)updateHeightForIndexPath:(NSIndexPath *)indexPath {
//    return nil;
//}



- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {

    NSArray *tmp = [NSArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    if (CGSizeEqualToSize(self.itemSize, CGSizeZero)) {
        return tmp;
    }

    if (!_attributesArray) {
        _attributesArray = [NSMutableArray array];
        _totalH = _itemCount * self.itemSize.height;
        NSArray *tmp = [super layoutAttributesForElementsInRect:
                        CGRectMake(0, 0, self.collectionView.bounds.size.width, _totalH)];
        [_attributesArray addObjectsFromArray:[[NSArray alloc] initWithArray:tmp copyItems:YES]];
        self.collectionView.contentOffset = CGPointMake(0, _totalH);
        return tmp;
    }

    CGFloat startPointY = rect.origin.y;//找到临界点
    NSInteger currentIndex = startPointY / self.itemSize.height;//根据临界点，找到indexPath
    NSInteger start = MAX(currentIndex - 3, 0);
    NSInteger end   = MIN(currentIndex + 3, _attributesArray.count);

    NSMutableArray *resetArray = [NSMutableArray array];

    for (NSInteger i = start; i < end; i++) {
        UICollectionViewLayoutAttributes *att = [_attributesArray objectAtIndex:i];
        CGFloat distance = att.indexPath.row * self.itemSize.height - startPointY;
        CGFloat progress = distance / self.itemSize.height * 6;
        
        CGFloat translation;
        if (progress > 0) {
            translation = fabs(progress) * self.itemSize.height / 15;
        }
        else {
            translation = fabs(progress) * self.itemSize.height / 2.2;
        }

        att.transform = CGAffineTransformMakeTranslation(0, translation);
        [resetArray addObject:att];
    }

    return resetArray;

//    for (UICollectionViewLayoutAttributes *att in tmp) {
//        CGFloat distance = CGRectGetMaxY(visiableRect) - att.frame.origin.y;
//        CGFloat normalD = fabs(distance/400.0);
//        CGFloat zoom = 1 - 0.25 * normalD;
//        CGAffineTransform transform = CGAffineTransformIdentity;
//        transform = CGAffineTransformScale(transform, zoom, zoom);
////        transform = CGAffineTransformTranslate(transform, 0, -100);
//        att.transform = transform;
//    }
//    return tmp;

    //return [self updateAttributesWithContentoffsetY:self.collectionView.contentOffset.y];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)updateAttributesWithContentoffsetY:(CGFloat)offsetY {

    if (!_attributesArray) {//缓存所有配置
        [self setupBegin];
        return _attributesArray;
    }

    CGRect visiableRect = [self visiableRect];
    CGFloat progress = self.collectionView.contentOffset.y / _totalH;
    for (int i = 0; i < _attributesArray.count; i++) {

        UICollectionViewLayoutAttributes *att = [_attributesArray objectAtIndex:i];
        CGFloat t = [[_tranlationArray objectAtIndex:i] floatValue];

        CGFloat distance = CGRectGetMaxY(visiableRect) - att.frame.origin.y;
        CGFloat normalD = fabs(distance/400.0);
        CGFloat zoom = 1 - 0.25 * normalD;
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformScale(transform, zoom, zoom);
        transform = CGAffineTransformTranslate(transform, 0, 100);
        att.transform = transform;

    }

    return _attributesArray;
}


- (void)setupBegin {
    _attributesArray = [NSMutableArray array];
    _totalH = _itemCount * self.itemSize.height;
    NSArray *tmp = [super layoutAttributesForElementsInRect:
                    CGRectMake(0, 0, self.collectionView.bounds.size.width, _totalH)];
    [_attributesArray addObjectsFromArray:tmp.copy];

    //滚动到底部
    self.collectionView.contentOffset = CGPointMake(0, _totalH);

    CGFloat totalTranslationY = [_attributesArray lastObject].frame.origin.y;
    CGFloat progress = self.collectionView.contentOffset.y / _totalH;

    _tranlationArray = [NSMutableArray arrayWithCapacity:tmp.count];

    for (int i = 0; i < _attributesArray.count; i++) {
        CGFloat t = totalTranslationY - i * self.itemSize.height - i * 80;
        [_tranlationArray addObject:@(t)];

        UICollectionViewLayoutAttributes *att = [_attributesArray objectAtIndex:i];
        att.transform = CGAffineTransformMakeTranslation(0, t * progress);
    }
}

- (CGFloat)translationYWithContentoffsetY:(CGFloat)contentOffsetY forLayoutAttribure:(UICollectionViewLayoutAttributes *)layoutAttribute {


    return 0;
}

- (CGRect)visiableRect {
    CGRect visiableRect = CGRectZero;
    visiableRect.origin = self.collectionView.contentOffset;
    visiableRect.size = self.collectionView.bounds.size;
    return visiableRect;
}

@end
