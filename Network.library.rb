require File.expand_path( File.dirname( __FILE__ ) + '/Loader.library.rb' )

unless ( defined? $NetworkModule )
	puts ( "[Library] Network" ) if ( $LoaderModule.getVar( "Verbose" ) >= Kesh::Loader::VERBOSE_LIBRARY )
	require 'socket'
	$NetworkModule = Kesh::Loader::ModuleInfo.parse( File.dirname( __FILE__ ), "Kesh::Network" )
	$NetworkModule.load( false, true )
end
