JRuby-Rack is a lightweight adapter for the Java servlet environment
that allows any Rack-based application to run unmodified in a Java
servlet container. JRuby-Rack supports Rails, Merb, as well as any
Rack-compatible Ruby web framework.

For more information on Rack, visit http://rack.rubyforge.org.

= Features

== Servlet Filter

JRuby-Rack's main mode of operation is as a servlet filter. This
allows requests for static content to pass through and be served by
the application server. Dynamic requests only happen for URLs that
don't have a corresponding file, much like many Ruby applications
expect.

== Goldspike-compatible Servlet

JRuby-Rack includes a stub RailsServlet and recognizes many of
Goldspike's context parameters (e.g., pool size configuration), making
it interchangeable with Goldspike, for convenience of migration. One
caveat is that static content is served by Rack, which requires
acquisition of a JRuby runtime. Your throughput with static files will
be much lower than when JRuby-Rack is configured as a servlet filter.
You have been warned!

== Servlet environment integration

- Servlet context is accessible to any application both through the
  global variable $servlet_context and the Rack environment variable
  java.servlet_context.
- Servlet request object is available in the Rack environment via the
  key java.servlet_request.
- Servlet request attributes are passed through to the Rack
  environment.
- Rack environment variables and headers can be overridden by servlet
  request attributes.
- Java servlet sessions are used as the default session store for both
  Rails and Merb. Session attributes with String keys and String,
  numeric, boolean, or java object values are automatically copied to
  the servlet session for you.

== Rails

Several aspects of Rails are automatically set up for you.

- The Rails controller setting ActionController::Base.relative_url_root
  is set for you automatically according to the context root where
  your webapp is deployed.
- Rails logging output is redirected to the application server log.
- Page caching and asset directories are configured appropriately.

== Merb

== JRuby Runtime Management

JRuby runtime management and pooling is done automatically by the
framework. In the case of Rails, runtimes are pooled. For Merb and
other Rack applications, a single runtime is created and shared for
every request.

= Building

Ensure you have JRuby with the buildr and rack gems installed.

  jruby -S gem install buildr rack

Checkout the JRuby Rack code and cd to that directory

  svn co http://svn.codehaus.org/jruby-contrib/trunk/rack
  cd rack
  
Resolve dependencies, compile the code, and build the jar file.

  jruby -S buildr package

The generated jar should be located here: target/jruby-rack-*.jar.

== Rails Step-by-step

This example shows how to create and deploy a simple Rails app using
the embedded Java database H2 to a WAR using Warble and JRuby Rack.
JRuby Rack is now included in the latest release of Warbler (0.9.9),
but you can build your own jar from source and substitute it if you
like.

Install Rails and the driver and ActiveRecord adapters for the H2
database:

  jruby -S gem install rails activerecord-jdbch2-adapter

Install Warbler:

  jruby -S gem install warbler

Make the "Blog" application

  jruby -S rails blog
  cd blog

Copy this configuration into config/database.yml:

  development:
    adapter: jdbch2 
    database: db/development_h2_database

  test:
    adapter: jdbch2 
    database: db/test_h2_database

  production:
    adapter: jdbch2 
    database: db/production_h2_database

Generate a scaffold for a simple model of blog comments.

  jruby script/generate scaffold comment name:string body:text

Run the database migration that was just created as part of the scaffold.

  jruby -S rake db:migrate

Start your application on the Rails default port 3000 using Mongrel/
and make sure it works:

  jruby script/server

Generate a custom Warbler WAR configuration for the blog application

  jruby -S warble config

Generate a production version of the H2 database for the blog
application:

  RAILS_ENV=production jruby -S rake db:migrate

Edit this file: config/warble.rb and add the following line after
these comments:

  # Additional files/directories to include, above those in config.dirs
  # config.includes = FileList["db"] 
  config.includes = FileList["db/production_h2*"]

This will tell Warble to include the just initialized production H2
database in the WAR.

Continue editing config/warble.rb and add the following line after
these comments:

  # Gems to be packaged in the webapp.  Note that Rails gems are added to this
  # list if vendor/rails is not present, so be sure to include rails if you
  # overwrite the value
  # config.gems = ["activerecord-jdbc-adapter", "jruby-openssl"]
  # config.gems << "tzinfo"
  # config.gems["rails"] = "1.2.3"
  config.gems << "activerecord-jdbch2-adapter"

This will tell Warble to add the JDBC driver for H2 as well as the
ActiveRecord JDBC and JDBC-H2 adapter Gems.

Now generate the WAR file:

  jruby -S warble war

This task generates the file: blog.war at the top level of the
application as well as an exploded version of the war located here:
tmp/war.

The war should be ready to deploy to your Java application server.

= Thanks

- Dudley Flanders, for the Merb support
- Robert Egglestone, for the original JRuby servlet integration
  project, Goldspike
- Chris Neukirchen, for Rack
- Sun Microsystems, Nick's employer, for project support
- Last, but not least, Flannery, Nick's wife, for patience and
  understanding
