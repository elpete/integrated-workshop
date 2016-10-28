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
```

You can pass the text of the link in to `click` or a jQuery style selector (like `#my-link`).

## Forms

Forms are an essential part of almost every web application.  Let's start with a contrived example — a form that sets a new value for heading on the page it submits to.

```cfc
// handlers/Main.cfc

function index( event, rc, prc ) {
    // change this to param in the rc scope
    param rc.welcomeMessage = "Welcome to ColdBox!";
    event.setView( "main/index" );
}

// add this new action
function simpleForm( event, rc, prc ) {
    event.setView( "main/simpleForm" );
}
```

```cfm
<!--- views/main/simpleForm.cfm --->

<cfoutput>
    <form action="#event.buildLink( "" )#">
        <input type="text" name="welcomeMessage" />
        <button type="submit">Submit</button>
    </form>
</cfoutput>
```

Don't forget to update the `main/index` view to pull the `welcomeMessage` from the `rc` scope now.

```cfm
<!--- views/main/index.cfm --->

<!--- .... --->
<h1>#rc.welcomeMessage#</h1>
<!--- .... --->
```

Now on to the test.  Meet `type` and `press`:
