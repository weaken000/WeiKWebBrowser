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
    CGFloat kMaxStrenthLength;
    CGFloat kMinCompressLength;
    
    
    CGFloat _lastContentoffsetY;
}

- (instancetype)init {
    if (self == [super init]) {
        
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    CGFloat itemW = self.collectionView.bounds.size.width;
    kMaxStrenthLength = itemW / 0.7 * 0.5;
    kMinCompressLength = 40.0;
    self.itemSize = CGSizeMake(itemW, itemW/0.7);
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.minimumLineSpacing = 0;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSArray *updatedAttrs = [self updateAttributesWithContentoffsetY:self.collectionView.contentOffset.y];
    return updatedAttrs;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)updateAttributesWithContentoffsetY:(CGFloat)offsetY {
    
    if (!_attributesArray) {//缓存所有配置
        
        _attributesArray = [NSMutableArray array];
        NSArray *tmp = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, self.collectionView.bounds.size.width, self.itemCount * self.itemSize.height)];
        [_attributesArray addObjectsFromArray:tmp.copy];
        
        int i = 0;
        while (_attributesArray.count - 4 - i > 0) {//后四个以外隐藏，高度为0
            UICollectionViewLayoutAttributes *att = [_attributesArray objectAtIndex:i];
            att.frame = CGRectMake(0, 0, self.itemSize.width, 0);
            i++;
        }

        //展开
        CGFloat y = 0;
        CGFloat itemH = kMinCompressLength;
        for (int j = i; j < _attributesArray.count; j++) {
            UICollectionViewLayoutAttributes *att = [_attributesArray objectAtIndex:j];
            CGRect attFrame = att.frame;
            attFrame.origin.y = y;
            attFrame.size.height = itemH;
            att.frame = attFrame;
            y += itemH;
            itemH = itemH * (1 + 0.4);
        }
        return _attributesArray;
    }
    
    //根据offsetY进行配置
    CGRect visiableRect = CGRectZero;
    visiableRect.origin = self.collectionView.contentOffset;
    visiableRect.size   = self.collectionView.bounds.size;
    
    if (_lastContentoffsetY > offsetY) {//向下拉、展开
        
    }
    else {//向上拉、压缩
        
    }
    
    _lastContentoffsetY = offsetY;
    return _attributesArray;
}

@end
