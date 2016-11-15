# Integrated Workshop

Workshop to show off [Integrated](https://github.com/elpete/integrated).

## What is Integrated?

Integrated is a testing library to enable more expressive and powerful integration tests.

+ It exposes a fluent, expressive API that reads as you would speak it.
+ It allows for testing of multiple requests in succession, such as loading a page and submitting a form.

## Installation

You install Integrated through [CommandBox](https://www.ortussolutions.com/products/commandbox).

```bash
box install integrated --saveDev
```

Additionally, you will need to add a `loadPath` to your `tests/Application.cfc`'s `this.javaSettings`.

```cfc
// tests/Application.cfc

this.javaSettings = { loadPaths = [ "integrated/lib" ], reloadOnChange = false };
```

This loads up Integrated's internal Java dependencies.

## Your First Test

To create an Integrated test, first create a test inside your `tests/specs` directory.  This test should extend one of Integrated's `BaseSpecs`.  For this workshop, we will use the `ColdBoxBaseSpec`.  Here's what a blank test file looks like:

```cfc
// tests/specs/integration/FirstIntegratedSpec.cfc

component extends="Integrated.BaseSpecs.ColdBoxBaseSpec" {

    function run() {

    }

}
```

You nest `describe`, `it`, and other TestBox methods inside the `run` method as usual.

```cfc
// tests/specs/integration/FirstIntegratedSpec.cfc

component extends="Integrated.BaseSpecs.ColdBoxBaseSpec" {

    function run() {
        describe( "a simple integrated base spec", function() {
            it( "can visit a page", function() {
                // your tests here
            } );
        } );
    }

}
```

Integrated has [an expansive API](https://elpete.github.io/integrated) to cover your testing needs.  Let's take a look at the most common methods step by step.

## `visit`

The most common interaction a user has with your site is to visit a page.  You can emulate this with Integrated using the `visit` method.

`visit` takes one parameter, the url to visit.  In this test, the user is trying to visit our home page:

```cfc
// tests/specs/integration/FirstIntegratedSpec.cfc

component extends="Integrated.BaseSpecs.ColdBoxBaseSpec" {

    function run() {
        describe( "a simple integrated base spec", function() {
            it( "can visit a page", function() {
                this.visit( "/" );
            } );
        } );
    }

}
```

If the user can visit the page, the test will pass.  If the request fails for any reason, the test will fail.  Your test may fail because the route isn't valid, a handler, action, or view doesn't exist, or because an exception was thrown while executing the event.  If the page sends back HTML, then `visit` will pass.

That in and of itself can be an effective test — make sure that this page loads.  But in most cases you will want to verify something about the page that loads.  This brings us to our next method.

## `see`

`see` takes two parameters — the text to search for in the response and whether to search case sensitively or not (defaults to true).  If the text would show somewhere on the page, you can `see` it.

```cfc
// tests/specs/integration/FirstIntegratedSpec.cfc

component extends="Integrated.BaseSpecs.ColdBoxBaseSpec" {

    function run() {
        describe( "a simple integrated base spec", function() {
            it( "can visit a page", function() {
                this.visit( "/" )
                    .see( "Welcome to ColdBox!" )
            } );
        } );
    }

}
```

With just these two methods you can cover a lot of ground.  Let's move on to interacting with a page.

## `click`

Clicking around a site using links is a common use case.  You can emulate this behavior using the `click` method.

First, let's add an `/about` page:

```cfc
// handlers/Main.cfc

function about(event, rc, prc ) {
    event.setView( "main/about" );
}
```

```cfm
<!--- views/main/about.cfm --->

<cfoutput>
    <h1>About Us</h1>
</cfoutput>
```

And we'll add a link to our about page in our `layouts/Main.cfm`

```cfm
<!--- layouts/Main.cfm --->

<div class="collapse navbar-collapse" id="navbar-collapse">
    <ul class="nav navbar-nav">
        <li><a href="#event.buildLink( "main.about" )#">About Us</a></li>
    </ul>
    <!--- .... --->
```

Finally, let's update the test.

```cfc
// tests/specs/integration/FirstIntegratedSpec.cfc

it( "can click a link", function() {
    this.visit( "/" )
        .see( "Welcome to ColdBox!" )
        .click( "About Us" )
        .see( "About Us" );
} );
```

You can pass the text of the link in to `click` or a selector.

> Every where you see `selector` mentioned is a jQuery style selector (like `#id` or `.class`).

## Forms

Forms are an essential part of almost every web application.  Let's start with a contrived example — a form that sets a new value for heading on the page it submits to.

```cfc
// handlers/Main.cfc

function simpleForm( event, rc, prc ) {
    event.setView( "main/simpleForm" );
}

function submitted( event, rc, prc ) {
    event.setView( "main/submitted" );
}
```

```cfm
<!--- views/main/simpleForm.cfm --->

<cfoutput>
    <form action="#event.buildLink( "main.submitted" )#">
        <input type="text" name="message" />
        <button type="submit">Submit</button>
    </form>
</cfoutput>
```

```cfm
<!--- views/main/submitted.cfm --->

<cfoutput>
    <h1>#rc.message#</h1>
</cfoutput>
```

Now on to the test.  Meet `type` and `press`:

```cfc
// tests/specs/integration/FirstIntegratedSpec.cfc

it( "can submit a form", function() {
    this.visit( "/main/simpleForm" )
        .type( "Welcome to Integrated", "message" )
        .press( "Submit" )
        .seePageIs( "/main/submitted" )
        .see( "Welcome to Integrated" );
} );
```

`type` (and methods like it) takes the pattern of `(value, selectorOrName)`.  It types a value in to a form field.  If the form field does not exist, the test will fail.

`press` takes a `selectorOrName` of a `button` to submit.  When ran, Integrated will take all form values embedded in the html, merge them with all form values inputed through the tests, and submit the request to the form's action.  The resulting html will be set as the new page.

Here we see an awesome superpower of Integrated — the ability to make multiple requests in a single test and keep chaining expectations.

Let's see that with a better concrete example: Registration

## Registering for our App

Let's start by writing our entire test first.  It will guide each step of our implementation.  Create a new test called `RegisterSpec.cfc`.

> For extra credit here, we'll use the nice `given`, `when`, `then` syntax extras in TestBox.


```
// tests/specs/integration/RegisterSpec.cfc

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
                                } )
                        } );
                    } );
                } );
            } );
        } );
    }

}
```

Look how readable that test is.  It describes the flow someone would take to register for our application.  Let's start implementing it!

Our first error is: `Failed to find a [Sign Up] link on the page.`.

Let's add it! In the `layouts/Main.cfm` file, change the `<!--- About --->` section to our `<!--- Log In --->` section below:

```cfm
<!--- layouts/Main.cfm --->

<!---Log In --->
<ul class="nav navbar-nav navbar-right">
    <li><a href="#event.buildLink( "users.new" )#">Sign Up</a></li>
</ul>
```

Next error: `The event: users.new is not valid registered event.`  Of course it doesn't exist, because we haven't created the handler yet.

Easy as pie with CommandBox:

```bash
coldbox create handler users actions=new
```

Next error: `Failed to find a [username] element on the page`.  Integrated is trying to type in our username value, but it helpfully first checks for the element on the page.  Since there are no inputs with the name `username`, the test is failing.  Let's make it pass!

```cfm
<!--- views/users/new.cfm --->

<cfoutput>
<form class="form">
    <div class="form-group">
        <label for="username" class="control-label">Username</label>
        <input type="text" name="username" id="username" class="form-control" />
    </div>
</form>
</cfoutput>
```

Our next errors will be about finding `email` and `password` on the page.  Let's fix those as well.

```cfm
<!--- views/users/new.cfm --->

<!--- .... --->
<div class="form-group">
    <label for="email" class="control-label">Email</label>
    <input type="email" name="email" id="email" class="form-control" />
</div>
<div class="form-group">
    <label for="password" class="control-label">Password</label>
    <input type="password" name="password" id="password" class="form-control" />
</div>
```

Now we need a button (`Failed to find a form with a button [Sign Up].`)

```cfm
<!--- views/users/new.cfm --->

<!--- .... --->
<div class="form-group">
    <button type="submit" class="btn btn-default">Sign Up</button>
</div>
```

We are now alerted that our form goes no where.  Let's add our method and action.

```cfm
<!--- views/users/new.cfm --->

<form class="form" method="POST" action="#event.buildLink( "users.create" )#">
<!--- .... --->
```

New error message: `The event: users.create is not valid registered event`. We are getting this cadence down!

```cfc
// handlers/Users.cfc

function create( event, rc, prc ) {
    setNextEvent( "main.index" );
}
```

Now we are expecting to see our custom message, but we aren't.  We'll use the built in `flash` scope to handle this.  In reality, we'd use a custom module to make this better, but this will work for now.

```cfc
// handlers/Users.cfc

function create( event, rc, prc) {
    flash.put( "message", "Welcome to the site, #rc.username#!" );    
    setNextEvent( "main/index" );
}
```

```cfm
<!--- views/main/index.cfm --->

<!--- Add this right at the top --->
<cfif flash.exists( "message" )>
    <div class="alert alert-info">
        #flash.get( "message" )#
    </div>
</cfif>
```

Last step.  We want to make sure the user was actually created in the database.  We use the `seeInTable` method to check for this.  It takes the name of the table and a struct of column and value pairs to match in a single row.

We'll use ORM for this application to make this quick, but any approach would work fine.

```bash
box install cborm
```

```cfc
// tests/Application.cfc

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
```

```cfc
// handlers/users.cfc

function create( event, rc, prc) {
    populateModel( entityNew( "User" ) ).save();
    flash.put( "message", "Welcome to the site, #rc.username#!" );    
    setNextEvent( "main/index" );
}
```

Bam! Success!  We now have a readable test that proves we can register a user.

One side note, though — try removing the code that creates the user and re-running the test.

What!?  It still passes?  This is because our database isn't cleaning out between tests.  The easiest way to do this with ORM is to change our `dbcreate` mode to `dropcreate` and add a call to `ormReload()` in a `beforeEach` block.

```cfc
// tests/specs/integration/RegisterSpec.cfc

component extends="Integrated.BaseSpecs.ColdBoxBaseSpec" {

    /**
    * @beforeEach
    */
    function refreshDatabase() {
        ormReload();
        ormClearSession();
    }

    // ....
}
```

Now our code fails as we would expect.  Add back in the code to save the user in the database and we're back in business.  Congratulations on your first Integrated test!

> We're going to ignore things like logging in users for this tutorial to keep things going.

## Handling failure paths

Let's continue with our register example.  What should happen if someone tries to register with the same email address as a current user?  Let's write out that spec:

```cfc
// tests/specs/integration/RegisterSpec.cfc

// ....
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
                    .see( "Uh, oh!")
                    .see( "The 'email' value 'john@example.com' is not unique in the database" );
            } );
        } );
    } );
} );
```

> Side Note: we are using a `beforeEach` in the `when` block because ColdBox has not had a chance to load until the `TestBox` lifecycle begins.  You could put code there, but you couldn't interact with ColdBox.

Let's make this test pass!  Since we are using ORM and cborm, let's use the built-in validation constraints.

```cfc
// models/User.cfc

component persistent="true" table="users" extends="cborm.models.ActiveEntity" {

    property name="id" fieldtype="id" column="id" generator="native" setter="false";
    property name="username";
    property name="email";
    property name="password";
    
    this.constraints = {
        "username" = { required = true },
        "email" = { required = true, type = "email", validator: "UniqueValidator@cborm" },
        "password" = { required = true }
    };
    
    function init() {
        super.init( useQueryCaching = false );
        return this;
    }

    function setPassword( password ) {
        variables.password = hash( arguments.password );
    }
}
```

Let's validate the model in our handler now:

```cfc
// handlers/users.cfc

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
```

And now to add the error message container:

```cfm
<!--- views/users/new.cfm --->

<!--- Add at the top --->
<cfif flash.exists( "errors" )>
    <div class="panel panel-danger">
        <div class="panel-heading">Uh, oh...</div>
        <div class="panel-body">
            <cfloop array="#flash.get( "errors" )#" index="error">
                <div class="alert alert-danger" role="alert">
                    #error#
                </div>
            </cfloop>
        </div>
    </div>
</cfif>
```

Look at that.  Now, for the life of our application we have tests that verify that a user has a good experience when signing up for our application.

## Where to go from here

While you might be still grinning from the power and simplicity of the integration tests you just wrote, here are a few things to consider:

+ Our tests don't guarantee a good UI.  Still check out how the page looks.
+ Find a good balance of what to test.  You don't want simple refactorings to break your integration tests.  If they do, you might be testing too many details.  Stick to the high level items and unit test smaller units below.
+ Consult the documentation often at [https://elpete.github.io/integrated](https://elpete.github.io/integrated).
+ Ask questions in the `#testing` channel or the `#box-products` channel in the [CFML Slack](http://cfml-slack.herokuapp.com/).