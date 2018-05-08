#import <objc/runtime.h>
#import <dlfcn.h>
#import <substrate.h>

extern const char *__progname;

static BOOL autoplayEnabled()
{
	@autoreleasepool {
		if(access("/var/mobile/Media/YTNoAutoPlay_flag_off", F_OK) == 0) {
			return YES;
		}
		return NO;
	}
}

%hook YTPlaybackConfig
- (void)setStartPlayback:(BOOL)arg1
{
	arg1 = autoplayEnabled();
	%orig(arg1);
}
%end

%hook YTLocalPlaybackController
- (void)loadWithLoadBlock:(id)arg1 playerTransition:(id)arg2 startPlayback:(BOOL)arg3 initialMediaTime:(double)arg4
{
	arg3 = autoplayEnabled();
	%orig(arg1, arg2, arg3, arg4);
}
- (void)restoreToState:(id)arg1 startPlayback:(BOOL)arg2
{
	arg2 = autoplayEnabled();
	%orig(arg1, arg2);
}
- (void)reloadPlayerAndStartPlayback:(BOOL)arg1
{
	arg1 = autoplayEnabled();
	%orig(arg1);
}
- (void)refreshStreamingDataAndStartPlayback:(BOOL)arg1
{
	arg1 = autoplayEnabled();
	%orig(arg1);
}
%end



#import <libactivator/libactivator.h>
#import <Flipswitch/Flipswitch.h>

@interface YTNoAutoPlayActivatorSwitch : NSObject <FSSwitchDataSource>
+ (id)sharedInstance;
+ (BOOL)sharedInstanceExist;
- (void)RegisterActions;
@end

@implementation YTNoAutoPlayActivatorSwitch
__strong static id _sharedObject;
+ (id)sharedInstance
{
	if (!_sharedObject) {
		_sharedObject = [[self alloc] init];
	}
	return _sharedObject;
}
+ (BOOL)sharedInstanceExist
{
	if (_sharedObject) {
		return YES;
	}
	return NO;
}
- (void)RegisterActions
{
    if (access("/usr/lib/libactivator.dylib", F_OK) == 0) {
		dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	    if (Class la = objc_getClass("LAActivator")) {
			[[la sharedInstance] registerListener:(id<LAListener>)self forName:@"com.julioverne.ytnoautoplay"];
		}
	}
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName
{
	return @"YTNoAutoPlay";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName
{
	return @"Disable/Enable YouTube Autoplay Videos.";
}
- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale
{
    static __strong UIImage* listenerIcon;
    if (!listenerIcon) {
		listenerIcon = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/Switches/YTNoAutoPlay.bundle"] pathForResource:scale==2.0f?@"icon@2x":@"icon" ofType:@"png"]];
	}
    return listenerIcon;
}
- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale
{
    static __strong UIImage* listenerIcon;
    if (!listenerIcon) {
		listenerIcon = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/Switches/YTNoAutoPlay.bundle"] pathForResource:scale==2.0f?@"icon@2x":@"icon" ofType:@"png"]];
	}
    return listenerIcon;
}
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	if(autoplayEnabled()) {
		unlink("/var/mobile/Media/YTNoAutoPlay_flag_off");
	} else {
		close(open("/var/mobile/Media/YTNoAutoPlay_flag_off", O_CREAT));
	}
	[[objc_getClass("FSSwitchPanel") sharedPanel] stateDidChangeForSwitchIdentifier:@"com.julioverne.ytnoautoplay"];
}
- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	return autoplayEnabled()?FSSwitchStateOn:FSSwitchStateOff;
}
- (void)applyActionForSwitchIdentifier:(NSString *)switchIdentifier
{
	[self activator:nil receiveEvent:nil];
}
@end



__attribute__((constructor)) static void initialize_YTNoAutoPlay()
{
	@autoreleasepool {
		if(!(strcmp(__progname, "YouTube") == 0)) {
			[[YTNoAutoPlayActivatorSwitch sharedInstance] RegisterActions];
		}
	}
}
