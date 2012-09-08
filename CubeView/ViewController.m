//
//  ViewController.m
//  CubeView
//
//  Created by Jesse Boyes on 9/8/12.
//  Copyright (c) 2012 Gilt Groupe. All rights reserved.
//

#import "ViewController.h"

#define kNumRows 3

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _masterCubeView = [[CubeView alloc] initWithFrame:self.view.bounds
                                       delegate:self
                                    orientation:CubeOrientationVertical];

    [self.view addSubview:_masterCubeView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_masterCubeView removeFromSuperview];
    [_masterCubeView release];
    _masterCubeView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)dealloc
{
    [_masterCubeView release], _masterCubeView = nil;
    [super dealloc];
}

- (UIColor *)randomColor {
    return [UIColor colorWithRed:(rand() % 1000)/1000.0F
                           green:(rand() % 1000)/1000.0F
                            blue:(rand() % 1000)/1000.0F
                           alpha:1.0];
}

#pragma mark - CubeViewDelegate

- (NSUInteger)numPagesForCubeView:(CubeView *)cubeView
{
    if (cubeView == _masterCubeView) {
        return 10;
    } else {
        return 2;
    }
}

- (UIView *)viewForPage:(NSUInteger)page cubeView:(CubeView *)cubeView
{
    // The Master cube contains three smaller "cubes" on each face.
    if (cubeView == _masterCubeView) {
        UIView *view = [[UIView alloc] initWithFrame:cubeView.bounds];
        CGFloat rowHeight = cubeView.bounds.size.height/kNumRows;
        for (int i=0; i < kNumRows; i++) {
            CGRect rowRect = CGRectMake(0, rowHeight*i, cubeView.bounds.size.width, rowHeight);
            CubeView *subCube = [[CubeView alloc] initWithFrame:rowRect
                                                       delegate:self orientation:CubeOrientationHorizontal];
            [view addSubview:subCube];
            [subCube release];
        }
        return [view autorelease];
    } else {
        UIView *view = [[UIView alloc] initWithFrame:cubeView.bounds];
        view.backgroundColor = [self randomColor];
        return [view autorelease];
    }
}

@end
