<cfoutput>
    <form class="form" method="POST" action="#event.buildLink( "users.create" )#">
        <div class="form-group">
            <label for="username" class="control-label">Username</label>
            <input type="text" name="username" id="username" class="form-control" />
        </div>
        <div class="form-group">
            <label for="email" class="control-label">Email</label>
            <input type="text" name="email" id="email" class="form-control" />
        </div>
        <div class="form-group">
            <label for="password" class="control-label">Password</label>
            <input type="password" name="password" id="password" class="form-control" />
        </div>
        <div class="form-group">
            <button type="submit" class="btn btn-default">Sign Up</button>
        </div>
    </form>
</cfoutput>