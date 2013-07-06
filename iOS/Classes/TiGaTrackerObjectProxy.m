/**
 * Benjamin Bahrenburg
 * Copyright (c) 2009-2013 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiGaTrackerObjectProxy.h"
#import "TiUtils.h"

id<GAITracker>  _tracker;

@implementation TiGaTrackerObjectProxy

-(void)createDefaultTracker:(NSDictionary*)args
{
    if(![NSThread isMainThread]){
        TiThreadPerformOnMainThread(^{
            _tracker = [GAI sharedInstance].defaultTracker;
            [self applyTrackerValues:args];
        }, NO);
    }else{
        _tracker = [GAI sharedInstance].defaultTracker;
        [self applyTrackerValues:args];
    }
}

-(void)createTrackerWithId:(NSString*)value withParams:(NSDictionary*)params
{
    _trackingId = [TiUtils stringValue:value];
    if(![NSThread isMainThread]){
        TiThreadPerformOnMainThread(^{
            _tracker = [[GAI sharedInstance] trackerWithTrackingId:_trackingId];
            [self applyTrackerValues:params];
        }, NO);
    }else{
        _tracker = [[GAI sharedInstance] trackerWithTrackingId:_trackingId];
        [self applyTrackerValues:params];
    }
}
-(id)initWithDefaultTracker
{
    if(self =[super init]){
        [self createDefaultTracker:nil];
    }
    return self;
}


-(id)initWithParams:(NSDictionary*)args
{
    if(self =[super init]){
        
        if ([args objectForKey:@"trackingId"]){
            [self createTrackerWithId:[TiUtils stringValue:@"trackingId" properties:args] withParams:args];
        }else{
            [self createDefaultTracker:args];
        }
        
    }
    
    return self;
}

-(void)applyTrackerValues:(NSDictionary*)args
{
    [self setAppId:[[NSBundle mainBundle] bundleIdentifier]];
    [self setAppName:[[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleName"]];
    [self setAppVersion:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    if ([args objectForKey:@"appId"]){
        [self setAppId:[TiUtils stringValue:@"appId" properties:args]];
    }
    
    if ([args objectForKey:@"appName"]){
        [self setAppName:[TiUtils stringValue:@"appName" properties:args]];
    }
    if ([args objectForKey:@"appVersion"]){
        [self setAppVersion:[TiUtils stringValue:@"appVersion" properties:args]];
    }    
    if ([args objectForKey:@"useHttps"]){
        [self setUseHttps:[args objectForKey:@"useHttps"]];
    }
    if ([args objectForKey:@"anonymize"]){
        [self setAnonymize:[args objectForKey:@"anonymize"]];
    }
    if ([args objectForKey:@"sampleRate"]){
        [self setSampleRate:[args objectForKey:@"sampleRate"]];
    }
    if ([args objectForKey:@"sessionTimeout"]){
        [self setSessionTimeout:[args objectForKey:@"sessionTimeout"]];
    }
    if ([args objectForKey:@"sessionStart"]){
        [self setSessionStart:[args objectForKey:@"sessionStart"]];
    }
}

-(void)dealloc
{
    if(_tracker!=nil){
        RELEASE_TO_NIL(_tracker);
    }
    
    if(_trackingId!=nil){
        RELEASE_TO_NIL(_trackingId);
    }
    if(_appVersion!=nil){
        RELEASE_TO_NIL(_appVersion);
    }
    if(_appName!=nil){
        RELEASE_TO_NIL(_appName);
    }
    if(_appId!=nil){
        RELEASE_TO_NIL(_appId);
    }
    if(_sessionTimeout!=nil){
        RELEASE_TO_NIL(_sessionTimeout);
    }
    if(_sampleRate!=nil){
        RELEASE_TO_NIL(_sampleRate);
    }
	[super dealloc];
}

-(NSString*)appVersion
{
    return _appVersion;
}
-(void)setAppVersion:(id)value
{
    ENSURE_SINGLE_ARG(value, NSString);
    _appVersion = [TiUtils stringValue:value];
    [_tracker setAppVersion:_appVersion];
}

-(NSString*)appName
{
    return _appName;
}
-(void)setAppName:(id)value
{
    ENSURE_SINGLE_ARG(value, NSString);
    _appName = [TiUtils stringValue:value];
    [_tracker setAppName:_appName];
}

-(NSString*)appId
{
    return _appId;
}
-(void)setAppId:(id)value
{
    ENSURE_SINGLE_ARG(value, NSString);
    _appId = [TiUtils stringValue:value];
    [_tracker setAppId:_appId];
}

-(void) close:(id)unused
{
    [_tracker close];
}

-(NSString*)trackingId
{
    return _trackingId;
}

-(void)sendEvent:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args,NSDictionary);

    [_tracker sendEventWithCategory:[TiUtils stringValue:@"category"
                                              properties:args def:nil]
                         withAction:[TiUtils stringValue:@"action" properties:args def:nil]
                          withLabel:[TiUtils stringValue:@"label" properties:args def:nil]
                          withValue: [TiUtils intValue:@"value" properties:args def:nil]];
}

-(void) sendSocial:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args,NSDictionary);
    
    [_tracker sendSocial:[TiUtils stringValue:@"network"
                                   properties:args def:nil]
              withAction:[TiUtils stringValue:@"action" properties:args def:nil]
              withTarget:[TiUtils stringValue:@"target" properties:args def:nil]];
}

-(void)sendView:(id)value
{
    ENSURE_UI_THREAD_1_ARG(value);
    ENSURE_SINGLE_ARG(value, NSString);
    [_tracker sendView:value];
}

-(void)send:(id)args
{
    enum Args {
        kArgTrackType=0,
        kArgParam,
        kArgCount
    };
    
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_ARG_COUNT(args,kArgCount);
    
    id params = [args objectAtIndex:kArgParam];
    ENSURE_DICT(params)
    
    [_tracker send:[TiUtils stringValue:[args objectAtIndex:kArgTrackType]]
                  params:params];
}

-(void)sendTiming:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args,NSDictionary);
    
    [_tracker sendTimingWithCategory:[TiUtils stringValue:@"category"
                                                     properties:args def:nil]
                                  withValue:[TiUtils doubleValue:@"value" properties:args]
                                  withName:[TiUtils stringValue:@"name"
                                                     properties:args def:nil]
                                 withLabel:[TiUtils stringValue:@"label"
                                                     properties:args def:nil]];
}

-(id)anonymize
{
    return NUMBOOL(_anonymize);
}
-(void)setAnonymize:(id)value
{
    ENSURE_UI_THREAD_1_ARG(value);
    ENSURE_SINGLE_ARG(value, NSNumber);
    _anonymize = [TiUtils boolValue:value];
    [_tracker setAnonymize:_anonymize];
}

-(id)useHttps
{
    return NUMBOOL(_useHttps);
}

-(void)setUseHttps:(id)value
{
    ENSURE_UI_THREAD_1_ARG(value);
    ENSURE_SINGLE_ARG(value, NSNumber);
    _useHttps = [TiUtils boolValue:value];
    [_tracker setUseHttps:_useHttps];
}

-(id)sampleRate
{
    return _sampleRate;
}
-(void)setSampleRate:(id)value
{
    ENSURE_UI_THREAD_1_ARG(value);
    ENSURE_SINGLE_ARG(value, NSNumber);
    _sampleRate = value;
    [_tracker setSampleRate:[TiUtils doubleValue:_sampleRate]];
}
-(id)sessionTimeout
{
    return _sessionTimeout;
}
-(void)setSessionTimeout:(id)value
{
    ENSURE_UI_THREAD_1_ARG(value);
    ENSURE_SINGLE_ARG(value, NSNumber);
    _sessionTimeout = value;
    [_tracker setSessionTimeout:[TiUtils doubleValue:_sessionTimeout]];
}
-(id)sessionStart
{
    return NUMBOOL(_sessionStart);
}

-(void) setSessionStart:(id)value
{
    ENSURE_UI_THREAD_1_ARG(value);
    ENSURE_SINGLE_ARG(value, NSNumber);
    _sessionStart=[TiUtils boolValue:value];
    [_tracker setSessionStart:_sessionStart];
}

-(id)throttlingEnabled
{
    NSLog(@"[DEBUG] throttlingEnabled not supported on iOS");
    return NUMBOOL(NO);
}

-(void) setThrottlingEnabled:(id)value
{
    NSLog(@"[DEBUG] throttlingEnabled not supported on iOS");
}


@end
