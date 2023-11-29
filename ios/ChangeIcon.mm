#import "ChangeIcon.h"

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNChangeIconSpec.h"
#endif

@implementation ChangeIcon
RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {
    return NO;
}

RCT_REMAP_METHOD(getIcon, resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *currentIcon = [[UIApplication sharedApplication] alternateIconName];
        if (currentIcon) {
            resolve(currentIcon);
        } else {
            resolve(@"default");
        }
    });
}

RCT_REMAP_METHOD(changeIcon, iconName:(NSString *)iconName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;

        if ([[UIApplication sharedApplication] supportsAlternateIcons] == NO) {
            reject(@"Error", @"NOT_SUPPORTED", error);
            return;
        }

        NSString *currentIcon = [[UIApplication sharedApplication] alternateIconName];

        if ([iconName isEqualToString:currentIcon]) {
            reject(@"Error", @"ICON_ALREADY_USED", error);
            return;
        }

        NSMutableString *selectorString = [[NSMutableString alloc] initWithCapacity:40];
        [selectorString appendString:@"_setAlternate"];
        [selectorString appendString:@"IconName:"];
        [selectorString appendString:@"completionHandler:"];

        SEL selector = NSSelectorFromString(selectorString);
        IMP imp = [[UIApplication sharedApplication] methodForSelector:selector];
        void (*func)(id, SEL, id, id) = (void (*)(id, SEL, id, id))imp;
        if (func)
        {
            func([UIApplication sharedApplication], selector, iconName, ^(NSError * _Nullable error) {
                if (error) {
                    reject(@"SYSTEM_ERROR", error.localizedDescription, error);
                } else {
                    resolve(iconName);
                }
            });
        }
    });
}

RCT_EXPORT_METHOD(checkIcon:(NSString *)iconName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    if (infoDict) {
        NSDictionary *iconsDict = [infoDict objectForKey:@"CFBundleIcons"];
        if (iconsDict) {
            NSDictionary *alternateIconsDict = [iconsDict objectForKey:@"CFBundleAlternateIcons"];
            if (alternateIconsDict) {
                NSDictionary *iconInfo = [alternateIconsDict objectForKey:iconName];
                if (iconInfo) {
                    resolve(@(YES));
                    return;
                }
            }
        }
    }
    resolve(@(NO));
}

// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeChangeIconSpecJSI>(params);
}
#endif

@end
