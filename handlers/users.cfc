component singleton {

    property name="flashmessage" inject="flashmessage@FlashMessage";

    function new( event, rc, prc ) {
        event.setView( "users/new" );
    }

    function create( event, rc, prc ) {
        populateModel( entityNew( "User" ) ).save();
        flashmessage.success( "Welcome to the site, #rc.username#!" );
        setNextEvent( "main.index" );
    }

}