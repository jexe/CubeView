CubeView
========

CubeView is a simple way to map normal UIViews onto a 3D "cube."

CubeView steals touches and physics from UIScrollView, ensuring natural
iOS-like interactions. It's designed to be very lightweight and easy to
integrate.


CubeViewDelegate
================

To integrate into your project, you must have a CubeViewDelegate that at least
implements the following:

`- (NSUInteger)numPagesForCubeView:(CubeView *)cubeView`
Returns the number of faces total for this cube.

`- (UIView *)viewForPage:(NSUInteger)page cubeView:(CubeView *)cubeView`
Returns one face of the cube as a UIView.  The view should be the same
width/height as the cubeView itself.

