//
//  CubeView.m
//
//  Created by Jesse Boyes on 2/20/12.
//  Copyright (c) 2012 Jesse. All rights reserved.
//

#import "CubeView.h"
#import <QuartzCore/QuartzCore.h>

#define kPullActionThreshold 80

@interface CubeView (Private)

- (void)performInitialLayout;
- (void)layoutPanes;
- (void)setupContentSize;
- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view;

@end

@implementation CubeView

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame delegate:(id<CubeViewDelegate>)del orientation:(CubeOrientation)co
{
    self = [super initWithFrame:frame];
    if (self) {
        delegate = del;
        orientation = co;
        [self performSelectorOnMainThread:@selector(performInitialLayout) withObject:nil waitUntilDone:NO];
    }
    return self;
}

- (void)performInitialLayout
{
    // Initialization code
    scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.delegate = self;
    [self setupContentSize];
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:scrollView];
    frontPane = [[delegate viewForPage:0 cubeView:self] retain];
    if ([delegate numPagesForCubeView:self] > 1) {
        bottomPane = [[delegate viewForPage:1 cubeView:self] retain];
    }
    scrollView.layer.contentsScale = [[UIScreen mainScreen] scale];
    [self layoutPanes];
}

- (void)reload
{
    [self setupContentSize];
    [frontPane removeFromSuperview];
    [topPane removeFromSuperview];
    [bottomPane removeFromSuperview];
    [frontPaneShade removeFromSuperview];
    [topPaneShade removeFromSuperview];
    [bottomPaneShade removeFromSuperview];
    [frontPane release];
    [bottomPane release], bottomPane = nil;
    [topPane release], topPane = nil;
    [frontPaneShade release], frontPaneShade = nil;
    [bottomPaneShade release], bottomPaneShade = nil;
    [topPaneShade release], topPaneShade = nil;

    frontPane = [[delegate viewForPage:currentPage cubeView:self] retain];
    if (currentPage > 0) {
        topPane = [[delegate viewForPage:currentPage-1 cubeView:self] retain];
    }
    if (currentPage < [delegate numPagesForCubeView:self]-1) {
        bottomPane = [[delegate viewForPage:currentPage+1 cubeView:self] retain];
    }

    [topEdgePane removeFromSuperview];
    [topEdgePane release], topEdgePane = nil;
    [bottomEdgePane removeFromSuperview];
    [bottomEdgePane release], bottomEdgePane = nil;
    [self layoutPanes];
}

- (void)setupContentSize
{
    if (orientation == CubeOrientationVertical) {
        if ([delegate numPagesForCubeView:self] > 2) {
            scrollView.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height * 3);
        } else {
            scrollView.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height * 2);
        }
    } else {
        if ([delegate numPagesForCubeView:self] > 2) {
            scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
        } else {
            scrollView.contentSize = CGSizeMake(self.bounds.size.width * 2, self.bounds.size.height);
        }
    }
    
}

- (void)layoutPanes
{
    NSUInteger max = [delegate numPagesForCubeView:self];
    // only one of startX or startY will be used, based on orientation.
    CGFloat startX = 0.0, startY = 0.0;

    if (orientation == CubeOrientationHorizontal) {
        if (currentPage >= max-1) {
            startX = scrollView.contentSize.width - scrollView.bounds.size.width;
        } else if (currentPage > 0) {
            startX = scrollView.bounds.size.width;
        }
    } else {
        if (currentPage >= max-1) {
            startY =  scrollView.contentSize.height - scrollView.bounds.size.height;
        } else if (currentPage > 0) {
            startY = scrollView.bounds.size.height;
        }
    }

    if (topPane) {
        if (orientation == CubeOrientationHorizontal) {
            topPane.layer.anchorPoint = CGPointMake(1.0, 0.5);
            topPane.frame = CGRectMake(startX - topPane.bounds.size.width, 0.0, topPane.bounds.size.width, topPane.bounds.size.height);
        } else {
            topPane.layer.anchorPoint = CGPointMake(0.5, 1.0);
            topPane.frame = CGRectMake(0.0, startY - topPane.bounds.size.height, topPane.bounds.size.width, topPane.bounds.size.height);
        }
        [scrollView addSubview:topPane];
        if (!topPaneShade || !topPaneShade.superview) {
            [topPaneShade release];
            topPaneShade = [[UIView alloc] initWithFrame:topPane.bounds];
            topPaneShade.backgroundColor = [UIColor blackColor];
            [topPane addSubview:topPaneShade];
        }
    }

    if (orientation == CubeOrientationHorizontal) {
        frontPane.layer.anchorPoint = CGPointMake(1.0, 0.5);
        frontPane.frame = CGRectMake(startX, 0.0, frontPane.bounds.size.width, frontPane.bounds.size.height);
    } else {
        frontPane.layer.anchorPoint = CGPointMake(0.5, 1.0);
        frontPane.frame = CGRectMake(0.0, startY, frontPane.bounds.size.width, frontPane.bounds.size.height);
    }
    [scrollView addSubview:frontPane];

    if (bottomPane) {
        if (orientation == CubeOrientationHorizontal) {
            bottomPane.layer.anchorPoint = CGPointMake(0.0, 0.5);
            bottomPane.frame = CGRectMake(startX + bottomPane.bounds.size.width, 0.0, bottomPane.bounds.size.width, bottomPane.bounds.size.height);
        } else {
            bottomPane.layer.anchorPoint = CGPointMake(0.5, 0.0);
            bottomPane.frame = CGRectMake(0.0, startY + bottomPane.bounds.size.height, bottomPane.bounds.size.width, bottomPane.bounds.size.height);
        }
        [scrollView addSubview:bottomPane];
        if (!bottomPaneShade || !bottomPaneShade.superview) {
            [bottomPaneShade release];
            bottomPaneShade = [[UIView alloc] initWithFrame:bottomPane.bounds];
            bottomPaneShade.backgroundColor = [UIColor blackColor];
            [bottomPane addSubview:bottomPaneShade];
        }
    }

    if (!frontPaneShade || !frontPaneShade.superview) {
        [frontPaneShade release];
        frontPaneShade = [[UIView alloc] initWithFrame:frontPane.bounds];
        frontPaneShade.backgroundColor = [UIColor blackColor];
    }

    if (currentPage == 0 && !topEdgePane && [delegate respondsToSelector:@selector(topEdgePaneForCubeView:)]) {
        topEdgePane = [[delegate topEdgePaneForCubeView:self] retain];
        if (orientation == CubeOrientationHorizontal) {
            topEdgePane.layer.anchorPoint = CGPointMake(1.0, 0.5);
            topEdgePane.frame = CGRectMake(-topEdgePane.bounds.size.width, 0, topEdgePane.bounds.size.width, topEdgePane.bounds.size.height);
        } else {
            topEdgePane.layer.anchorPoint = CGPointMake(0.5, 1.0);
            topEdgePane.frame = CGRectMake(0, -topEdgePane.bounds.size.height, topEdgePane.bounds.size.width, topEdgePane.bounds.size.height);
        }
        [scrollView addSubview:topEdgePane];
    } else if (currentPage == max-1 && !bottomEdgePane && [delegate respondsToSelector:@selector(bottomEdgePaneForCubeView:)]) {
        bottomEdgePane = [[delegate bottomEdgePaneForCubeView:self] retain];
        if (orientation == CubeOrientationHorizontal) {
            bottomEdgePane.layer.anchorPoint = CGPointMake(0.0, 0.5);
            bottomEdgePane.frame = CGRectMake(scrollView.contentSize.width, 0, bottomEdgePane.bounds.size.width, bottomEdgePane.bounds.size.height);
        } else {
            bottomEdgePane.layer.anchorPoint = CGPointMake(0.5, 0.0);
            bottomEdgePane.frame = CGRectMake(0, scrollView.contentSize.height, bottomEdgePane.bounds.size.width, bottomEdgePane.bounds.size.height);
        }
        [scrollView addSubview:bottomEdgePane];
    }

    scrollView.contentOffset = CGPointMake(startX, startY);
}

- (void)setTopEdgePaneHidden:(BOOL)hidden
{
    topEdgePane.hidden = hidden;
}

- (void)setCurrentPage:(NSUInteger)page
{
    currentPage = page;
    [self reload];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}


#pragma mark - ScrollViewDelegate methods

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)sv
{
    // TODO: Set up to arrive at the top of the content here.
    return YES;
}


- (void)scrollViewDidScroll:(UIScrollView *)sv
{
    if (orientation == CubeOrientationHorizontal) {
        CALayer *layer;
        CATransform3D xRotationTransform;

        CGFloat frontPaneOffset = 0;
        if (currentPage == 0) {
            frontPaneOffset = 0;
        } else {
            if (currentPage >= [delegate numPagesForCubeView:self]-1) {
                frontPaneOffset = sv.contentSize.width - sv.bounds.size.width;
            } else {
                frontPaneOffset = sv.bounds.size.width;
            }
        }
        
        // Set up appropriate anchors for front pane.
        // n.b. Changing the anchorPoint will move the view, so save and restore the frame.
        if (frontPaneOffset - sv.contentOffset.x > 0 && frontPane.layer.anchorPoint.x != 0.0) {
            [self setAnchorPoint:CGPointMake(0.0, 0.5) forView:frontPane];
        } else if (frontPaneOffset - sv.contentOffset.x < 0 && frontPane.layer.anchorPoint.x != 1.0) {
            [self setAnchorPoint:CGPointMake(1.0, 0.5) forView:frontPane];
        }
        
        // Top panel rotation
        if (topPane != nil) {
            CGFloat topAngle = (((sv.contentOffset.x - (frontPaneOffset - sv.bounds.size.width))/sv.bounds.size.width) * 90.0);
            layer = topPane.layer;
            xRotationTransform = sv.layer.transform;
            xRotationTransform.m34 = 1.0 / -500;
            xRotationTransform = CATransform3DRotate(xRotationTransform, topAngle * M_PI / 180.0f, 0.0f, -1.0f, 0.0f);
            layer.transform = xRotationTransform;
        }

        // Scrolling down
        // Front panel rotation
        CGFloat frontAngle = -(((sv.bounds.size.width-(sv.contentOffset.x - frontPaneOffset))/sv.bounds.size.width) * 90.0) + 90.0;
        layer = frontPane.layer;
        xRotationTransform = sv.layer.transform;
        xRotationTransform.m34 = 1.0 / -500;
        xRotationTransform = CATransform3DRotate(xRotationTransform, frontAngle * M_PI / 180.0f, 0.0f, -1.0f, 0.0f);
        layer.transform = xRotationTransform;
        
        // Bottom panel rotation
        if (bottomPane != nil) {
            CGFloat bottomAngle = -(((sv.bounds.size.width-(sv.contentOffset.x - frontPaneOffset))/sv.bounds.size.width) * 90.0);
            layer = bottomPane.layer;
            xRotationTransform = sv.layer.transform;
            xRotationTransform.m34 = 1.0 / -500;
            xRotationTransform = CATransform3DRotate(xRotationTransform, bottomAngle * M_PI / 180.0f, 0.0f, -1.0f, 0.0f);
            layer.transform = xRotationTransform;
        }

        // Edges
        if (topEdgePane != nil) {
            CGFloat edgeAngle = 180.0-(((sv.bounds.size.width-(sv.contentOffset.x - frontPaneOffset))/sv.bounds.size.width) * 90.0);
            layer = topEdgePane.layer;
            xRotationTransform = sv.layer.transform;
            xRotationTransform.m34 = 1.0 / -500;
            xRotationTransform = CATransform3DRotate(xRotationTransform, edgeAngle * M_PI / 180.0f, 0.0f, -1.0f, 0.0f);
            layer.transform = xRotationTransform;
        } else if (bottomEdgePane != nil) {
            CGFloat edgeAngle = -(((sv.bounds.size.width-(sv.contentOffset.x - frontPaneOffset))/sv.bounds.size.width) * 90.0);
            layer = bottomEdgePane.layer;
            xRotationTransform = sv.layer.transform;
            xRotationTransform.m34 = 1.0 / -500;
            xRotationTransform = CATransform3DRotate(xRotationTransform, edgeAngle * M_PI / 180.0f, 0.0f, -1.0f, 0.0f);
            layer.transform = xRotationTransform;
        }

        // Adjust shading
        if (!frontPaneShade.superview) {
            [frontPaneShade removeFromSuperview];
            [frontPane addSubview:frontPaneShade];
        }
        bottomPaneShade.alpha = (bottomPane.frame.origin.x - sv.contentOffset.x)/sv.bounds.size.width;
        topPaneShade.alpha = (sv.contentOffset.x - (frontPaneOffset - sv.bounds.size.height))/sv.bounds.size.width;
        frontPaneShade.alpha = ABS(sv.contentOffset.x - frontPaneOffset)/sv.bounds.size.width;
    } else { // Vertically-oriented rotation
        CALayer *layer;
        CATransform3D yRotationTransform;
        
        CGFloat frontPaneOffset = 0;
        if (currentPage == 0) {
            frontPaneOffset = 0;
        } else if (currentPage >= [delegate numPagesForCubeView:self]-1) {
            frontPaneOffset = sv.contentSize.height - sv.bounds.size.height;
        } else {
            frontPaneOffset = sv.bounds.size.height;
        }
        
        // Set up appropriate anchors for front pane.
        // n.b. Changing the anchorPoint will move the view, so save and restore the frame.
        if (frontPaneOffset - sv.contentOffset.y > 0 && frontPane.layer.anchorPoint.y != 0.0) {
            [self setAnchorPoint:CGPointMake(0.5, 0.0) forView:frontPane];
        } else if (frontPaneOffset - sv.contentOffset.y < 0 && frontPane.layer.anchorPoint.y != 1.0) {
            [self setAnchorPoint:CGPointMake(0.5, 1.0) forView:frontPane];
        }
        
        // Top panel rotation
        if (topPane != nil) {
            CGFloat topAngle = (((sv.contentOffset.y - (frontPaneOffset - sv.bounds.size.height))/sv.bounds.size.height) * 90.0);
            layer = topPane.layer;
            yRotationTransform = sv.layer.transform;
            yRotationTransform.m34 = 1.0 / -500;
            yRotationTransform = CATransform3DRotate(yRotationTransform, topAngle * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
            layer.transform = yRotationTransform;
        }
        
        // Scrolling down
        // Front panel rotation
        CGFloat frontAngle = -(((sv.bounds.size.height-(sv.contentOffset.y - frontPaneOffset))/sv.bounds.size.height) * 90.0) + 90.0;
        layer = frontPane.layer;
        yRotationTransform = sv.layer.transform;
        yRotationTransform.m34 = 1.0 / -500;
        yRotationTransform = CATransform3DRotate(yRotationTransform, frontAngle * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
        layer.transform = yRotationTransform;

        // Bottom panel rotation
        if (bottomPane != nil) {
            CGFloat bottomAngle = -(((sv.bounds.size.height-(sv.contentOffset.y - frontPaneOffset))/sv.bounds.size.height) * 90.0);
            layer = bottomPane.layer;
            yRotationTransform = sv.layer.transform;
            yRotationTransform.m34 = 1.0 / -500;
            yRotationTransform = CATransform3DRotate(yRotationTransform, bottomAngle * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
            layer.transform = yRotationTransform;
        }

        // Edges
        if (topEdgePane != nil) {
            layer = topEdgePane.layer;
            // Check pull-action threshold and unfold the view if we're past it.
            if ([delegate respondsToSelector:@selector(supportsPullActionTop:)] && [delegate supportsPullActionTop:self] && sv.contentOffset.y < -kPullActionThreshold) {
                if (!topEdgeExtended) {
                    [UIView animateWithDuration:0.2 animations:^(void) {
                        layer.transform = sv.layer.transform;
                    }];
                    topEdgeExtended = YES;
                }
            } else {
                if (topEdgeExtended) {
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:0.2];
                }
                CGFloat edgeAngle = 180.0-(((sv.bounds.size.height-(sv.contentOffset.y - frontPaneOffset))/sv.bounds.size.height) * 90.0);
                yRotationTransform = sv.layer.transform;
                yRotationTransform.m34 = 1.0 / -500;
                yRotationTransform = CATransform3DRotate(yRotationTransform, edgeAngle * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
                layer.transform = yRotationTransform;
                if (topEdgeExtended) {
                    [UIView commitAnimations];
                    topEdgeExtended = NO;
                }
            }
        } else if (bottomEdgePane != nil) {
            layer = bottomEdgePane.layer;
            // Check pull-action threshold and unfold the view if we're past it.
            if ([delegate respondsToSelector:@selector(supportsPullActionTop:)] && [delegate supportsPullActionTop:self] &&
                sv.contentOffset.y > (sv.contentSize.height - sv.bounds.size.height + kPullActionThreshold)) {
                if (!bottomEdgeExtended) {
                    [UIView animateWithDuration:0.2 animations:^(void) {
                        layer.transform = sv.layer.transform;
                    }];
                    bottomEdgeExtended = YES;
                }
            } else {
                if (bottomEdgeExtended) {
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:0.2];
                }
                CGFloat edgeAngle = -(((sv.bounds.size.height-(sv.contentOffset.y - frontPaneOffset))/sv.bounds.size.height) * 90.0);
                yRotationTransform = sv.layer.transform;
                yRotationTransform.m34 = 1.0 / -500;
                yRotationTransform = CATransform3DRotate(yRotationTransform, edgeAngle * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
                layer.transform = yRotationTransform;
                if (bottomEdgeExtended) {
                    [UIView commitAnimations];
                    bottomEdgeExtended = NO;
                }
            }
        }

        
        
        // Adjust shading
        if (!frontPaneShade.superview) {
            [frontPaneShade removeFromSuperview];
            [frontPane addSubview:frontPaneShade];
        }
        bottomPaneShade.alpha = (bottomPane.frame.origin.y - sv.contentOffset.y)/sv.bounds.size.height;
        topPaneShade.alpha = (sv.contentOffset.y - (frontPaneOffset - sv.bounds.size.height))/sv.bounds.size.height;
        frontPaneShade.alpha = ABS(sv.contentOffset.y - frontPaneOffset)/sv.bounds.size.height;
    }

    // Check for page crossovers
    NSUInteger max = [delegate numPagesForCubeView:self];
    // Up a page
    if ((orientation == CubeOrientationVertical && ((scrollView.contentOffset.y <= 0.0 && currentPage > 0) ||
                                                     (scrollView.contentOffset.y <= scrollView.bounds.size.height && currentPage == max-1 && max > 2))) ||
        (orientation == CubeOrientationHorizontal && ((scrollView.contentOffset.x <= 0.0 && currentPage > 0) ||
                                                       (scrollView.contentOffset.x <= scrollView.bounds.size.width && currentPage == max-1 && max > 2))))
    {
        [self pageUp];
    } 
    // Down a page
    else if ((orientation == CubeOrientationVertical && ((scrollView.contentOffset.y >= scrollView.bounds.size.height*2) ||
                                                          (scrollView.contentOffset.y >= scrollView.bounds.size.height && currentPage == 0))) ||
             (orientation == CubeOrientationHorizontal && ((scrollView.contentOffset.x >= scrollView.bounds.size.width*2) ||
                                                            (scrollView.contentOffset.x >= scrollView.bounds.size.width && currentPage == 0))))
    {
        [self pageDown];
    }
}

- (void)resetTransforms
{
    // Weird.  But resetting the transforms after a successful scroll seems to fix a lot of quirky geometry issues.
    frontPane.layer.transform = scrollView.layer.transform;
    topPane.layer.transform = scrollView.layer.transform;
    bottomPane.layer.transform = scrollView.layer.transform;
}

- (void)pageUp
{
    // Get out of the way of touch interactions
    [frontPaneShade removeFromSuperview];
    
    [frontPane removeFromSuperview];
    [topPane removeFromSuperview];
    [bottomPane removeFromSuperview];
    [frontPaneShade removeFromSuperview];
    [topPaneShade removeFromSuperview];
    [bottomPaneShade removeFromSuperview];
    [bottomEdgePane removeFromSuperview];
    [bottomEdgePane release], bottomEdgePane = nil;
    
    currentPage--;
    [bottomPane release];
    bottomPane = [frontPane retain];
    [frontPane release];
    frontPane = [topPane retain];
    [topPane release];
    if (currentPage > 0) {
        topPane = [[delegate viewForPage:currentPage-1 cubeView:self] retain];
    } else {
        topPane = nil;
    }
    [self layoutPanes];

    [self resetTransforms];
}

- (void)pageDown
{
    NSUInteger max = [delegate numPagesForCubeView:self];

    // Get out of the way of touch interactions
    [frontPaneShade removeFromSuperview];
    
    if (currentPage < max-1) {
        [frontPane removeFromSuperview];
        [topPane removeFromSuperview];
        [bottomPane removeFromSuperview];
        [frontPaneShade removeFromSuperview];
        [topPaneShade removeFromSuperview];
        [bottomPaneShade removeFromSuperview];
        [topEdgePane removeFromSuperview];
        [topEdgePane release], topEdgePane = nil;
        
        currentPage++;
        [topPane release];
        topPane = [frontPane retain];
        [frontPane release];
        frontPane = [bottomPane retain];
        if (currentPage < max-1) {
            bottomPane = [[delegate viewForPage:currentPage+1 cubeView:self] retain];
        } else {
            bottomPane = nil;
        }
        [self layoutPanes];
    }

    [self resetTransforms];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (topEdgeExtended) {
        topEdgeExtended = NO;
        [delegate pullTopActionTriggered:self topActionFrame:[topEdgePane convertRect:topEdgePane.frame toView:self.superview]];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self resetTransforms];
}

@end
