require File.expand_path( File.dirname( __FILE__ ) + '/Kesh/ArgTest.class.rb' ) 
require File.expand_path( File.dirname( __FILE__ ) + '/Kesh/Loader/constants.rb' )
require File.expand_path( File.dirname( __FILE__ ) + '/Kesh/Loader/ModuleInfo.class.rb' )
require File.expand_path( File.dirname( __FILE__ ) + '/Kesh/Loader/functions.rb' )
require File.expand_path( File.dirname( __FILE__ ) + '/Kesh/Loader/FileInfo.class.rb' )
require File.expand_path( File.dirname( __FILE__ ) + '/Kesh/Loader/ClassInfo.class.rb' )

unless ( defined? $LoaderModule )
	puts "[Library] Loader"
	$LoaderModule = Kesh::Loader::ModuleInfo.parse( File.dirname( __FILE__ ), "Kesh::Loader" )
	$LoaderModule.setVar( "Verbose", Kesh::Loader::VERBOSE_LIBRARY )
	$LoaderModule.load( false, true )
end
