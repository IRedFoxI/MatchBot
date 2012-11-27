require File.expand_path( File.dirname( __FILE__ ) + '/Loader.library.rb' )

unless ( defined? $DataStructuresModule )
	puts ( "[Library] Data Structures" ) if ( $LoaderModule.getVar( "Verbose" ) >= Kesh::Loader::VERBOSE_LIBRARY )
	$DataStructuresModule = Kesh::Loader::ModuleInfo.parse( File.dirname( __FILE__ ), "Kesh::DataStructures" )
	$DataStructuresModule.load( false, true )
end
