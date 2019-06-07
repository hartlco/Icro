//
//  WindowToolbarHelper.m
//  Icro
//
//  Created by martin on 06.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

#import "WindowToolbarHelper.h"
#import <UIKit/NSToolbar+UIKitAdditions.h>

@implementation WindowToolbarHelper

- (void)applyStyleToWindow:(UIWindowScene *)windowScene {
    windowScene.titlebar.titleVisibility = UITitlebarTitleVisibilityHidden;
}

@end
