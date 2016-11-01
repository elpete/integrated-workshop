/**
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
*/
component{

	// APPLICATION CFC PROPERTIES
	this.name 				= "ColdBoxTestingSuite" & hash(getCurrentTemplatePath());
	this.sessionManagement 	= true;
	this.sessionTimeout 	= createTimeSpan( 0, 0, 15, 0 );
	this.applicationTimeout = createTimeSpan( 0, 0, 15, 0 );
	this.setClientCookies 	= true;

	// Create testing mapping
	this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );
	// Map back to its root
	rootPath = REReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" );
	this.mappings["/root"]   = rootPath;

	this.javaSettings = { loadPaths = [ "integrated/lib" ], reloadOnChange = false };

	// Set up Testing Datasource
	this.datasources[ "integrated_workshop" ] = {
	    class: 'org.h2.Driver',
	    connectionString: 'jdbc:h2:mem:integrated_workshop;MODE=MySQL',
	    username = "sa"
	};

	this.datasource = "integrated_workshop";

	// Set up ORM
	this.mappings[ "/cborm" ] = rootPath & "modules/cborm";

	this.ormEnabled = true;
	this.ormSettings = {
	    cfclocation = [ "models" ],
	    dbcreate = "dropcreate",
	    logSQL = true,
	    flushAtRequestEnd = false,
	    autoManageSession = false,
	    eventHandling = true,
	    eventHandler = "cborm.models.EventHandler"
	};

	function onRequestStart(string targetPage) {
		applicationStop();
	}

}