//
//  PresentDetailTransition.m
//  Phonon
//
//  Created by Carl Pan on 2/28/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import "PresentDetailTransition.h"

@implementation PresentDetailTransition

#pragma mark - UIViewControllerAnimatedTransitioning Protocol Methods

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Gives view controller we are animating to
    UIViewController *detail = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Need to add to container view when transition to some view
    UIView *containerView = [transitionContext containerView];
    detail.view.alpha = 0.0;
    
    // Set detail view frame
    CGRect frame = containerView.bounds;
    frame.origin.y += 20.0;
    frame.size.height -= 20.0;
    detail.view.frame = frame;
    
    // Add to container view
    [containerView addSubview:detail.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        detail.view.alpha = 1.0;
    }completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3; // third of a second
}

@end
