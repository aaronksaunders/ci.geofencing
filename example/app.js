// this sets the background color of the master UIView (when there are no windows/tab groups on it)
Titanium.UI.setBackgroundColor('#000');

// create tab group
var tabGroup = Titanium.UI.createTabGroup();


//
// create base UI tab and root window
//
var win1 = Titanium.UI.createWindow({  
    title:'Tab 1',
    backgroundColor:'#fff'
});
var tab1 = Titanium.UI.createTab({  
    icon:'KS_nav_views.png',
    title:'Tab 1',
    window:win1
});

    var mapview = Titanium.Map.createView({
        mapType : Titanium.Map.STANDARD_TYPE,
        animate : true,
        regionFit : true,
        userLocation : true,
    });

win1.add(mapview);


//
//  add tabs
//
tabGroup.addTab(tab1);   


// open tab group
tabGroup.open();


// TODO: write your module tests here
var ci_geofencing = require('ci.geofencing');
Ti.API.info("module is => " + ci_geofencing);

var regions = []
regions.push({
	"title" : "Willis Tower",
	"latitude" : 41.878844,
	"longitude" : -87.635942,
	"radius" : 100
});

regions.push({
	"title" : "Lincoln Park Zoo",
	"latitude" : 41.92007,
	"longitude" : -87.63251,
	"radius" : 500
});

regions.push({
	"title" : "Chicago Theater",
	"latitude" : 41.88535,
	"longitude" : -87.62745,
	"radius" : 200
});
//
// when firing an event you will get information like this
// {
//    "source": {
//      "id": "ci.geofencing"
//    },
//    "identifier": "Willis Tower",
//    "type": "exited_region" | "entered_region" | "monitoring_region"
//  }
//
ci_geofencing.startGeoFencing(regions, function(event) {
	Ti.API.info('info ' + JSON.stringify(event, null, 2));
	
	if ( event.type === "exited_region") {
		ci_geofencing.stopGeoFencing();
	}
});

// http://www.netmagazine.com/tutorials/get-started-geofencing-ios