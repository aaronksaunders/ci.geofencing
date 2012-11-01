/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "CiGeofencingModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation CiGeofencingModule

CLLocationManager *_locationManager;
NSArray *_regionArray;
NSArray *geofences;
KrollCallback * _callback;

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"18329a2a-9b67-4e1c-9988-155258dc6f1d";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ci.geofencing";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}
#pragma geofencing stuff
- (void)initializeLocationManager {
    // Check to ensure location services are enabled
    if(![CLLocationManager locationServicesEnabled]) {
        NSLog(@"[INFO] %@",@"You need to enable location services to use this app.");
        return;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
}


- (void) initializeRegionMonitoring:(NSArray*)geofences {
    
    if (_locationManager == nil) {
        [NSException raise:@"Location Manager Not Initialized" format:@"You must initialize location manager first."];
    }
    
    if(![CLLocationManager regionMonitoringAvailable]) {
        NSLog(@"[INFO] %@",@"This app requires region monitoring features which are unavailable on this device.");
        return;
    }
    
    for(CLRegion *geofence in geofences) {
        [_locationManager startMonitoringForRegion:geofence];
    }
    
}

- (NSArray*) buildGeofenceData:(NSArray *)regionArray {
    //NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"regions" ofType:@"plist"];
    //_regionArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    NSMutableArray *geofences = [[NSMutableArray alloc] init];
    for(NSDictionary *regionDict in regionArray) {
        CLRegion *region = [self mapDictionaryToRegion:regionDict];
        [geofences addObject:region];
    }
    
    return [NSArray arrayWithArray:geofences];
}


- (CLRegion*)mapDictionaryToRegion:(NSDictionary*)dictionary {
    NSString *title = [dictionary valueForKey:@"title"];
    
    CLLocationDegrees latitude = [[dictionary valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[dictionary valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    CLLocationDistance regionRadius = [[dictionary valueForKey:@"radius"] doubleValue];
    
    return [[CLRegion alloc] initCircularRegionWithCenter:centerCoordinate
                                                   radius:regionRadius
                                               identifier:title];
}


#pragma mark - Location Manager - Region Task Methods

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Entered Region - %@", region.identifier);
    
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setObject:region.identifier forKey:@"identifier"];
    [self _fireEventToListener:@"entered_region" withObject:event listener:_callback thisObject:nil];
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Exited Region - %@", region.identifier);
    
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setObject:region.identifier forKey:@"identifier"];
    [self _fireEventToListener:@"exited_region" withObject:event listener:_callback thisObject:nil];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Started monitoring %@ region", region.identifier);
    
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    [event setObject:region.identifier forKey:@"identifier"];
    [self _fireEventToListener:@"monitoring_region" withObject:event listener:_callback thisObject:nil];
}

#pragma mark - Location Manager - Standard Task Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"[INFO] %@",[NSString stringWithFormat:@"%f,%f",newLocation.coordinate.latitude, newLocation.coordinate.longitude]);
}


- (void)initializeLocationUpdates {
    [_locationManager startMonitoringSignificantLocationChanges];
}



#pragma Public APIs

-(void)startGeoFencing:(id)args
{
    ENSURE_UI_THREAD(startGeoFencing,args);
    
    NSArray * _regions = [[args objectAtIndex:0]retain];
    _callback = [[args objectAtIndex:1] retain];
    
    
    [self initializeLocationManager];
    
    // create array from data passed in
    geofences = [self buildGeofenceData:_regions];
    [self initializeRegionMonitoring:geofences];
    
    // remember to clean up later
    [geofences retain];
    
    //[self initializeLocationUpdates];
}

-(void)stopGeoFencing:(id)args
{
    for(CLRegion *geofence in geofences) {
        [_locationManager stopMonitoringForRegion:geofence];
    }
    
    //[_locationManager stopMonitoringSignificantLocationChanges];
}


@end
