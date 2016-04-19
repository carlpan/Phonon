//
//  DetailViewController.m
//  Phonon
//
//  Created by Carl Pan on 2/28/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import "PhotoController.h"
#import "DetailViewController.h"
#import "MetadataView.h"

@interface DetailViewController ()

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIDynamicAnimator *animator;

@property (strong, nonatomic) MetadataView *metadataView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.view.clipsToBounds = YES;
    
    
    self.metadataView = [[MetadataView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 400.0f)];
    self.metadataView.alpha = 0.0;
    self.metadataView.photo = self.photo;
    [self.view addSubview:self.metadataView];
    
    // Set image view
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -320.0f, 320.0f, 320.0f)];
    [self.view addSubview:self.imageView];
    
    [PhotoController imageForPhoto:self.photo size:@"standard_resolution" completion:^(UIImage *image) {
        self.imageView.image = image;;
    }];
    
    // Tap to dismiss view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector((close))];
    [self.view addGestureRecognizer:tap];
    
    // Dynamic animator
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGPoint point = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    // Make a new snap behavior
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.imageView snapToPoint:point];
    [self.animator addBehavior:snap];
    
    // Animate meta data view transition
    self.metadataView.center = point;
    [UIView animateWithDuration:0.5 delay:0.7 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:kNilOptions animations:^{
        self.metadataView.alpha = 1.0;
    } completion:nil];
}

- (void)close {
    // On close
    // Remove all behaviors of our animator
    [self.animator removeAllBehaviors];
    
    // Add a new behavior
    // Snap to the bottom
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.imageView snapToPoint:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMaxY(self.view.bounds) + 180.0f)];
    [self.animator addBehavior:snap];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
