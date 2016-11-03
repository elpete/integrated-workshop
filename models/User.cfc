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

