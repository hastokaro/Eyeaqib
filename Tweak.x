#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

static AVAudioPlayer *eyReqibPlayer = nil;
static BOOL hasStoppedAnthem = NO;

@interface EyReqibManager : NSObject
+ (void)startAnthem;
+ (void)stopAnthem;
@end

@implementation EyReqibManager

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        [self startAnthem];
    }];
}

+ (void)startAnthem {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"ey_reqib" ofType:@"mp3"];
    if (!soundPath) {
        soundPath = [[NSBundle mainBundle] pathForResource:@"ey_reqib" ofType:@"m4a"];
    }
    if (!soundPath) return;

    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    NSError *error = nil;

    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryAmbient error:nil];
    [session setActive:YES error:nil];

    eyReqibPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    if (eyReqibPlayer && !error) {
        eyReqibPlayer.numberOfLoops = -1;
        eyReqibPlayer.volume = 1.0;
        [eyReqibPlayer prepareToPlay];
        [eyReqibPlayer play];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIWindow *targetWindow = nil;
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                    if (scene.activationState == UISceneActivationStateForegroundActive) {
                        for (UIWindow *w in scene.windows) {
                            if (w.isKeyWindow) {
                                targetWindow = w;
                                break;
                            }
                        }
                    }
                }
            }
            if (!targetWindow) {
                targetWindow = [UIApplication sharedApplication].keyWindow;
            }
            if (!targetWindow && [UIApplication sharedApplication].windows.count > 0) {
                targetWindow = [UIApplication sharedApplication].windows.firstObject;
            }

            if (targetWindow) {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleScreenTap:)];
                tap.cancelsTouchesInView = NO;
                [targetWindow addGestureRecognizer:tap];
            }
        });
    }
}

+ (void)handleScreenTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UISceneActivationStateForegroundActive ? NO : (gesture.state == UIGestureRecognizerStateEnded)) {
        [self stopAnthem];
    }
}

+ (void)stopAnthem {
    if (hasStoppedAnthem) return;
    hasStoppedAnthem = YES;

    if (eyReqibPlayer && [eyReqibPlayer isPlaying]) {
        [eyReqibPlayer setVolume:0.0 fadeDuration:1.0];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [eyReqibPlayer stop];
            eyReqibPlayer = nil;
        });
    }
}

@end

