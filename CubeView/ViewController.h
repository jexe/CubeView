//
//  ViewController.h
//  CubeView
//
//  Created by Jesse Boyes on 9/8/12.
//  Copyright (c) 2012 Gilt Groupe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CubeView.h"

@interface ViewController : UIViewController<CubeViewDelegate> {
    CubeView *_masterCubeView;
}

@end
