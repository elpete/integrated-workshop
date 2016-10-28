component extends="Integrated.BaseSpecs.ColdBoxBaseSpec" {

    function run() {
        describe( "a simple integrated base spec", function() {
            it( "can visit a page", function() {
                this.visit( "/main/simpleForm" )
                    .type( "Welcome to Integrated", "welcomeMessage" )
                    .press( "Submit" )
                    .seePageIs( "/" )
            } );
        } );
    }

}