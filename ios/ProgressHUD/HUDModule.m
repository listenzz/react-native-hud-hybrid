//
//  ProgressHUDModule.m
//  HUD
//
//  Created by Listen on 2018/6/2.
//  Copyright © 2018年 Listen. All rights reserved.
//

#import "HUDModule.h"
#import <React/RCTLog.h>
#import "HBDProgressHUD.h"
#import "MBProgressHUD.h"
#import <React/RCTBridge.h>

@interface HUDModule()

@property(nonatomic, assign) NSInteger hudKeyGenerator;
@property(nonatomic, copy) NSMutableDictionary *huds;

@end

@implementation HUDModule

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReload) name:RCTBridgeWillReloadNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCTBridgeWillReloadNotification object:nil];
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_MODULE(HUD);

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(text:(NSString *)text) {
    HBDProgressHUD *hud = [self createHud];
    [hud text:text];
    [hud hideDefaultDelay];
}

RCT_EXPORT_METHOD(info:(NSString *)text) {
    HBDProgressHUD *hud = [self createHud];
    [hud info:text];
    [hud hideDefaultDelay];
}

RCT_EXPORT_METHOD(done:(NSString *)text) {
    HBDProgressHUD *hud = [self createHud];
    [hud done:text];
    [hud hideDefaultDelay];
}

RCT_EXPORT_METHOD(error:(NSString *)text) {
    HBDProgressHUD *hud = [self createHud];
    [hud error:text];
    [hud hideDefaultDelay];
}

RCT_EXPORT_METHOD(showLoading:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if (!_huds) {
        _huds = [[NSMutableDictionary alloc] init];
    }
    UIView *hostView = [self currentHostView];
    if (hostView) {
        HBDProgressHUD *hud = [self createHud];
        [hud show:[HUDConfig sharedConfig].loadingText];
        NSNumber *hudKey = @(++self.hudKeyGenerator);
        [self.huds setObject:hud forKey:hudKey];
        resolve(hudKey);
    } else {
        reject(@"404", @"host view missing", [NSError errorWithDomain:@"HUDModuleDomain" code:404 userInfo:nil]);
    }
}

- (void) handleReload {
    if (self.huds) {
        for (NSNumber *key in self.huds) {
            HBDProgressHUD *hud = self.huds[key];
            [hud hide];
        }
        [self.huds removeAllObjects];
    }
}

RCT_EXPORT_METHOD(hideLoading:(NSNumber* __nonnull)hudKey) {
    HBDProgressHUD *hud = [self.huds objectForKey:hudKey];
    if (hud) {
        [self.huds removeObjectForKey:hudKey];
        [hud hide];
    }
}

RCT_EXPORT_METHOD(config:(NSDictionary *)options) {
    if (options[@"backgroundColor"]) {
        [HUDConfig sharedConfig].bezelColor = [HUDModule colorWithHexString:options[@"backgroundColor"]];
    } else {
        [HUDConfig sharedConfig].bezelColor = [HUDConfig defaultBezelColor];
    }
    
    if (options[@"tintColor"]) {
        [HUDConfig sharedConfig].contentColor = [HUDModule colorWithHexString:options[@"tintColor"]];
    } else {
        [HUDConfig sharedConfig].contentColor = [HUDConfig defaultContentColor];
    }
    
    if (options[@"cornerRadius"]) {
        [HUDConfig sharedConfig].cornerRadius = [options[@"cornerRadius"] floatValue];
    } else {
        [HUDConfig sharedConfig].cornerRadius = [HUDConfig defaultCornerRadius];
    }
    
    if (options[@"duration"]) {
        [HUDConfig sharedConfig].duration = [options[@"duration"] floatValue] / 1000.0f;
    } else {
        [HUDConfig sharedConfig].duration = [HUDConfig defaultDuration];
    }
    
    if (options[@"graceTime"]) {
        [HUDConfig sharedConfig].graceTime = [options[@"graceTime"] floatValue] / 1000.0f;
    } else {
        [HUDConfig sharedConfig].graceTime = [HUDConfig defaultGraceTime];
    }
    
    if (options[@"minShowTime"]) {
        [HUDConfig sharedConfig].minshowTime = [options[@"minShowTime"] floatValue] / 1000.0f;
    } else {
        [HUDConfig sharedConfig].minshowTime = [HUDConfig defaultMinShowTime];
    }
    
    if (options[@"dimAmount"]) {
        [HUDConfig sharedConfig].dimAmount = [options[@"dimAmount"] floatValue];
    } else {
        [HUDConfig sharedConfig].dimAmount = [HUDConfig defaultDimAmount];
    }
    
    if (options[@"loadingText"]) {
        [HUDConfig sharedConfig].loadingText = options[@"loadingText"];
    } else {
        [HUDConfig sharedConfig].loadingText = [HUDConfig defaultLoadingText];
    }
}

- (HBDProgressHUD *)createHud {
    return [[HBDProgressHUD alloc] initWithView:[self currentHostView]];
}

- (UIView *)currentHostView {
    UIView *hostView;
    if ([HUDConfig sharedConfig].hostViewProvider) {
        hostView = [[HUDConfig sharedConfig].hostViewProvider hostView];
    } else {
        UIApplication *application = [[UIApplication class] performSelector:@selector(sharedApplication)];
        UIViewController *controller = application.keyWindow.rootViewController;
        hostView = controller.view;
    }
    return hostView;
}

+ (UIColor *) colorWithHexString: (NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha, red, green, blue;
    switch ([colorString length]) {
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            alpha = 1.0f;
            red   = 0.0f;
            green = 0.0f;
            blue  = 0.0f;
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"0%@", substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

@end
