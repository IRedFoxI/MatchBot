require File.expand_path( File.dirname( __FILE__ ) + '/Loader.library.rb' )

unless ( defined? $IOModule )
	puts ( "[Library] IO" ) if ( $LoaderModule.getVar( "Verbose" ) >= Kesh::Loader::VERBOSE_LIBRARY )
	$IOModule = Kesh::Loader::ModuleInfo.parse( File.dirname( __FILE__ ), "Kesh::IO" )
	$IOModule.load( false, true )
end
