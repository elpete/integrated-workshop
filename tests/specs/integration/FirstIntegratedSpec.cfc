component extends="Integrated.BaseSpecs.ColdBoxBaseSpec" {

    function run() {
        describe( "a simple integrated base spec", function() {
            it( "can visit a page", function() {
                this.visit( "/" )
                    .see( "Welcome to ColdBox!" )
                    .click( "About Us" )
                    .see( "About Us" );
            } );
        } );
    }

}