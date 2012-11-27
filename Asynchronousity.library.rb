require File.expand_path( File.dirname( __FILE__ ) + '/Loader.library.rb' )

unless ( defined? $AsynchronousityModule )
	puts ( "[Library] Asynchronousity" ) if ( $LoaderModule.getVar( "Verbose" ) >= Kesh::Loader::VERBOSE_LIBRARY )
	require 'thread'
	$AsynchronousityModule = Kesh::Loader::ModuleInfo.parse( File.dirname( __FILE__ ), "Kesh::Asynchronousity" )
	$AsynchronousityModule.load( false, true )
end
