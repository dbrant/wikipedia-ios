#import "UIViewController+WMFArticlePresentation.h"
@import WMF;
#import "Wikipedia-Swift.h"
#import "WMFArticleViewController.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIViewController (WMFArticlePresentation)

- (WMFArticleViewController *)wmf_pushArticleWithURL:(NSURL *)url dataStore:(MWKDataStore *)dataStore theme:(WMFTheme *)theme restoreScrollPosition:(BOOL)restoreScrollPosition animated:(BOOL)animated {
    return [self wmf_pushArticleWithURL:url
                              dataStore:dataStore
                                  theme:theme
                  restoreScrollPosition:restoreScrollPosition
                               animated:animated
                  articleLoadCompletion:^{
                  }];
}

- (WMFArticleViewController *)wmf_pushArticleWithURL:(NSURL *)url dataStore:(MWKDataStore *)dataStore theme:(WMFTheme *)theme restoreScrollPosition:(BOOL)restoreScrollPosition animated:(BOOL)animated articleLoadCompletion:(dispatch_block_t)articleLoadCompletion {
    if (!restoreScrollPosition) {
        url = [url wmf_URLWithFragment:nil];
    }

    WMFArticleViewController *vc = [[WMFArticleViewController alloc] initWithArticleURL:url dataStore:dataStore theme:theme];
    vc.articleLoadCompletion = articleLoadCompletion;
    [self wmf_pushArticleViewController:vc animated:animated];
    return vc;
}

- (void)wmf_pushArticleWithURL:(NSURL *)url dataStore:(MWKDataStore *)dataStore theme:(WMFTheme *)theme animated:(BOOL)animated {
    [self wmf_pushArticleWithURL:url dataStore:dataStore theme:theme restoreScrollPosition:NO animated:animated];
}

- (nullable UINavigationController *)wmf_tabBarControllerSelectedNavigationController {
    UITabBarController *tab = nil;
    if ([self isKindOfClass:[UITabBarController class]]) {
        tab = (UITabBarController *)self;
    } else if (self.tabBarController) {
        tab = self.tabBarController;
    } else {
        NSAssert(false, @"Unexpected view controller hierarchy - missing UITabBarController");
    }

    UIViewController *selectedVC = [tab selectedViewController];

    UINavigationController *nav = nil;
    if ([selectedVC isKindOfClass:[UINavigationController class]]) {
        nav = (UINavigationController *)selectedVC;
    } else {
        NSAssert(false, @"Unexpected view controller hierarchy - missing UINavigationController");
    }

    return nav;
}

- (void)wmf_pushArticleViewController:(WMFArticleViewController *)viewController animated:(BOOL)animated {
    if (self.parentViewController != nil && self.parentViewController.navigationController) {
        [self.parentViewController wmf_pushArticleViewController:viewController animated:animated];
    } else if (self.presentingViewController != nil) {
        UIViewController *presentingViewController = self.presentingViewController;
        [presentingViewController dismissViewControllerAnimated:YES
                                                     completion:^{
                                                         [presentingViewController wmf_pushArticleViewController:viewController animated:animated];
                                                     }];
    } else if (self.navigationController != nil) {
        [self.navigationController pushViewController:viewController animated:animated];
    } else {
        UINavigationController *nav = [self wmf_tabBarControllerSelectedNavigationController];
        [nav pushViewController:viewController animated:animated];
    }
}

- (void)wmf_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.navigationController != nil) {
        [self.navigationController pushViewController:viewController animated:animated];
    } else if ([self isKindOfClass:[UITabBarController class]]) { // WMFAppViewController
        UINavigationController *nav = [self wmf_tabBarControllerSelectedNavigationController];
        [nav pushViewController:viewController animated:animated];
    } else if (self.presentingViewController != nil) {
        UIViewController *presentingViewController = self.presentingViewController;
        [presentingViewController dismissViewControllerAnimated:YES
                                                     completion:^{
                                                         [presentingViewController wmf_pushViewController:viewController animated:animated];
                                                     }];
    } else if (self.parentViewController != nil) {
        [self.parentViewController wmf_pushViewController:viewController animated:animated];
    } else {
        UINavigationController *nav = [self wmf_tabBarControllerSelectedNavigationController];
        if (!nav) {
            NSAssert(false, @"Unexpected view controller hierarchy");
        }
        [nav pushViewController:viewController animated:animated];
    }
}

@end

NS_ASSUME_NONNULL_END
