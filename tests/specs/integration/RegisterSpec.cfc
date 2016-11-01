component extends="Integrated.BaseSpecs.ColdBoxBaseSpec" {

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
        } );
    }

}