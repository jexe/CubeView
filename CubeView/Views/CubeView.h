//
//  CubeView.h
//
//  Created by Jesse Boyes on 2/20/12.
//  Copyright (c) 2012 Jesse. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CubeOrientationVertical,
    CubeOrientationHorizontal
} CubeOrientation;

@class CubeView;
@protocol CubeViewDelegate <NSObject>

- (NSUInteger)numPagesForCubeView:(CubeView *)cubeView;
- (UIView *)viewForPage:(NSUInteger)page cubeView:(CubeView *)cubeView;

@optional

- (UIView *)topEdgePaneForCubeView:(CubeView *)cubeView;
- (UIView *)bottomEdgePaneForCubeView:(CubeView *)cubeView;

- (BOOL)supportsPullActionTop:(CubeView *)cubeView;
- (BOOL)supportsPullActionBottom:(CubeView *)cubeView;

- (void)pullTopActionTriggered:(CubeView *)cubeView topActionFrame:(CGRect)frame;

@end

@interface CubeView : UIView <UIScrollViewDelegate> {
    UIScrollView *scrollView;
    UIView *frontPane;
    UIView *bottomPane;
    UIView *topPane;
    UIView *topEdgePane;
    UIView *bottomEdgePane;

    UIView *frontPaneShade;
    UIView *bottomPaneShade;
    UIView *topPaneShade;
    UIView *topEdgePaneShade;
    UIView *bottomEdgePaneShade;

    NSUInteger currentPage;
    CubeOrientation orientation;

    id<CubeViewDelegate> delegate;

    BOOL topEdgeExtended, bottomEdgeExtended; // Whether the current edge has been extended for a pull-to-refresh action
}

- (id)initWithFrame:(CGRect)frame delegate:(id<CubeViewDelegate>)del orientation:(CubeOrientation)co;

- (void)setTopEdgePaneHidden:(BOOL)hidden;

- (void)setCurrentPage:(NSUInteger)page;

- (void)reload;

@end
