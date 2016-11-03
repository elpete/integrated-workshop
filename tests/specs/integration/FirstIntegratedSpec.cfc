component extends="Integrated.BaseSpecs.ColdBoxBaseSpec" {

    function run() {
        describe( "a simple integrated base spec", function() {
            it( "can visit a page", function() {
                this.visit( "/" )
                    .see( "Welcome to ColdBox!" )
            } );

            it( "can click a link", function() {
                this.visit( "/" )
                    .see( "Welcome to ColdBox!" )
                    .click( "About Us" )
                    .see( "About Us" );
            } );

            it( "can submit a form", function() {
                this.visit( "/main/simpleForm" )
                    .type( "Welcome to Integrated", "message" )
                    .press( "Submit" )
                    .seePageIs( "/main/submitted" )
                    .see( "Welcome to Integrated" );
            } );
        } );
    }

}