//
//  DismissDetailTransition.m
//  Phonon
//
//  Created by Carl Pan on 2/28/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import "DismissDetailTransition.h"

@implementation DismissDetailTransition

#pragma mark - UIViewControllerAnimatedTransitioning Protocol Methods

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // From detail to view controller
    UIViewController *detail = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [UIView animateWithDuration:0.3 animations:^{
        detail.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [detail.view removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

@end
