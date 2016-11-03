component extends="Integrated.BaseSpecs.ColdBoxBaseSpec" {

    /**
    * @beforeEach
    */
    function refreshDatabase() {
        ORMReload();
        ORMClearSession();
    }

    function run() {
        feature( "registering for the site", function() {
            scenario( "successful registration", function() {
                given( "a user wants to sign up for an account", function() {
                    when( "they visit the registration page and fill out and submit the form", function() {
                        then( "they should be on the home page, logged in, and see a welcome message", function() {
                            this.visit( "/" )
                                .click( "Sign Up" )
                                .type( "John", "username" )
                                .type( "john@example.com", "email" )
                                .type( "pass1234", "password" )
                                .press( "Sign Up" )
                                .see( "Welcome to the site, John!")
                                .seeInTable( "users", {
                                    username = "John",
                                    email = "john@example.com"
                                } );
                        } );
                    } );
                } );
            } );
            scenario( "email already taken", function() {
                given( "a user wants to sign up for an account vut the email has already been used for an account", function() {
                    beforeEach( function() {
                        var user = entityNew( "User" );
                        user.setUsername( "John" );
                        user.setEmail( "john@example.com" );
                        user.setPassword( "pass1234" );
                        user.save();
                    } );

                    when( "they visit the registration page and fill out and submit the form", function() {                        
                        then( "they should be back on the registration page and see an error message that the email has been taken", function() {
                            this.visit( "/" )
                                .click( "Sign Up" )
                                .type( "John", "username" )
                                .type( "john@example.com", "email" )
                                .type( "pass1234", "password" )
                                .press( "Sign Up" )
                                .seePageIs( "/users/new" )
                                .see( "Uh, oh...")
                                .see( "The 'email' value 'john@example.com' is not unique in the database" );
                        } );
                    } );
                } );
            } );
        } );
    }

}