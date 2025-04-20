#import <UIKit/UIKit.h>
#include "Prefs/YTMUltimateSettingsController.h"
#include "Headers/Localization.h"

@interface YTMAccountButton : UIButton
- (id)initWithTitle:(id)arg1 identifier:(id)arg2 icon:(id)arg3 actionBlock:(void (^)(BOOL finished))arg4;
@end

@interface YTMAvatarAccountView : UIView
@end

@interface UIView (Private)
- (id)_viewControllerForAncestor;
@end

@interface YTISupportedMessageRendererIcons : NSObject
@property (nonatomic, assign, readwrite) int iconType;
@end

@interface YTIMessageRenderer : NSObject
@property (nonatomic, strong, readwrite) YTISupportedMessageRendererIcons *icon;
@end

@interface YTMLightweightMessageCell : UIView
@end

@interface YTMMessageView : UIView
@property (nonatomic, weak, readwrite) YTMLightweightMessageCell *delegate;
@end

%group SettingsPage

%hook YTMAvatarAccountView
- (void)setAccountMenuUpperButtons:(id)arg1 lowerButtons:(id)arg2 {
    // Tạo icon có kích thước và style giống biểu tượng hệ thống "Cài đặt"
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(24, 24)];
    UIImage *icon = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightLight];
        UIImage *gearImage = [[UIImage systemImageNamed:@"gearshape"] imageByApplyingSymbolConfiguration:config];

        UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
        UIImageView *gearImageView = [[UIImageView alloc] initWithImage:gearImage];
        gearImageView.contentMode = UIViewContentModeScaleAspectFit;
        gearImageView.clipsToBounds = YES;
        gearImageView.tintColor = [UIColor whiteColor];
        gearImageView.frame = imageView.bounds;

        [imageView addSubview:gearImageView];
        [imageView.layer renderInContext:rendererContext.CGContext];
    }];

    // Tạo nút "IOSMOD.NET"
    YTMAccountButton *button = [[%c(YTMAccountButton) alloc] initWithTitle:@"IOSMOD.NET" identifier:@"ytmult" icon:icon actionBlock:^(BOOL arg4) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[YTMUltimateSettingsController alloc] init]];
        [nav setModalPresentationStyle:UIModalPresentationFullScreen];
        [self._viewControllerForAncestor presentViewController:nav animated:YES completion:nil];
    }];

    button.tintColor = [UIColor redColor];

    // Thêm nút vào danh sách phía dưới
    NSMutableArray *arrDown = [[NSMutableArray alloc] init];
    [arrDown addObjectsFromArray:arg2];
    [arrDown addObject:button];

    // Loại bỏ nút "Premium"
    NSMutableArray *arrUp = [[NSMutableArray alloc] init];
    for (YTMAccountButton *yt_button in arg1) {
        if (![[yt_button.titleLabel text] containsString:@"Premium"]) {
            [arrUp addObject:yt_button];
        }
    }

    %orig(arrUp, arrDown);
}
%end

@interface YTMAvatarAccountViewController : UIViewController
@end

@interface YTMNavigationDrawerPromoView : UIView
@end

// Remove the subscribe to premium button on new versions
%hook YTMNavigationDrawerPromoView
- (void)loadModel:(id)model {
    if ([self._viewControllerForAncestor isKindOfClass:%c(YTMAvatarAccountViewController)]) {
        return [self removeFromSuperview];
    }

    %orig(model);
}
%end

%hook YTMMessageView
- (void)setMessageText:(id)arg1 {
    if (![self.delegate isKindOfClass:%c(YTMLightweightMessageCell)]) {
        return %orig;
    }

    YTMLightweightMessageCell *msgCell = (YTMLightweightMessageCell *)self.delegate;
    YTIMessageRenderer *renderer = [msgCell valueForKey:@"_renderer"];

    if (renderer.icon.iconType != 187) {
        return %orig;
    }

    %orig(LOC(@"REGIONAL_RESTRICTION"));
}
%end
%end

%ctor {
    %init(SettingsPage);
}
