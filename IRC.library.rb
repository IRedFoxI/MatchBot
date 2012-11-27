require 'date'
require File.expand_path( File.dirname( __FILE__ ) + '/Loader.library.rb' )

unless ( defined? $IRCModule )
	puts ( "[Library] IRC" ) if ( $LoaderModule.getVar( "Verbose" ) >= Kesh::Loader::VERBOSE_LIBRARY )
	$IRCModule = Kesh::Loader::ModuleInfo.parse( File.dirname( __FILE__ ), "Kesh::IRC" )
	$IRCModule.load()
	$IRCModule.childModule( 'Commands' ).load()
	$IRCModule.setVar( "Events", $IRCModule.childModule( 'Events' ).loadClasses() )
	$IRCModule.setVar( "Numerics", $IRCModule.childModule( 'Events' ).childModule( 'Numerics' ).loadClasses() )
end
