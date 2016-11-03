component {
	
    function new( event, rc, prc ) {
		event.setView( "users/new" );
	}	

	function create( event, rc, prc ) {
        var user = populateModel( entityNew( "User" ) );
        if ( ! user.isValid() ) {
            flash.put( "errors", user.getValidationResults().getAllErrors() );
            setNextEvent( "users.new" );
            return;
        }
        user.save();
        flash.put( "message", "Welcome to the site, #rc.username#!" );
	    setNextEvent( "main.index" );
	}

}
