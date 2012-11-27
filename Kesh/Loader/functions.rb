require File.expand_path( File.dirname( __FILE__ ) + '/ModuleInfo.class.rb' )

# Parse the paramters into a ModuleInfo object and then require all classes.
def requireModule( basePath, name )
	Kesh::ArgTest::type( "path", path, String )
	Kesh::ArgTest::stringLength( "path", path, 1 )
	Kesh::ArgTest::type( "name", name, String )
	Kesh::ArgTest::stringLength( "name", name, 1 )
	modInfo = Kesh::Loader::ModuleInfo.parse( basePath, name )
	modInfo.load( false, true )
end


# Parse the parameters into a ModuleInfo object and then load all classes.
def loadModule( basePath, name )
	Kesh::ArgTest::type( "path", path, String )
	Kesh::ArgTest::stringLength( "path", path, 1 )
	Kesh::ArgTest::type( "name", name, String )
	Kesh::ArgTest::stringLength( "name", name, 1 )
	modInfo = Kesh::Loader::ModuleInfo.parse( basePath, name )
	modInfo.load( true, true )
end


# Require the given class name for the given ModuleInfo.
def requireModClass( mod, name )
	Kesh::ArgTest::type( "mod", mod, Kesh::Loader::ModuleInfo )
	Kesh::ArgTest::type( "name", name, String )
	Kesh::ArgTest::stringLength( "name", name, 1 )
	mod.clazz( name ).load()
end


# Load the given class name for the given ModuleInfo.
def loadModClass( mod, name )
	Kesh::ArgTest::type( "mod", mod, Kesh::Loader::ModuleInfo )
	Kesh::ArgTest::type( "name", name, String )
	Kesh::ArgTest::stringLength( "name", name, 1 )
	mod.clazz( name ).load( true )
end


# Require the given file name for the given ModuleInfo.
def requireModFile( mod, name )
	Kesh::ArgTest::type( "mod", mod, Kesh::Loader::ModuleInfo )
	Kesh::ArgTest::type( "name", name, String )
	Kesh::ArgTest::stringLength( "name", name, 1 )
	mod.file( name ).load()
end


# Load the given file for hte given ModuleInfo.
def loadModFile( mod, name )
	Kesh::ArgTest::type( "mod", mod, Kesh::Loader::ModuleInfo )
	Kesh::ArgTest::type( "name", name, String )
	Kesh::ArgTest::stringLength( "name", name, 1 )
	mod.file( name ).load( true )
end


# Require a library file with the given name.  Library files prepare modules for use.  Path is relative to that of the calling file's.
def requireLibrary( name )
	Kesh::ArgTest::type( "name", name, String )
	Kesh::ArgTest::stringLength( "name", name, 1 )
	require File.expand_path( File.dirname( Kesh::Loader::ModuleInfo.getCallingFile() ) + "/" + name + ".library.rb" )
end


# Load a library file with the given name.  Library files prepare modules for use.  Path is relative to that of the calling file's.
def loadLibrary( name )
	Kesh::ArgTest::type( "name", name, String )
	Kesh::ArgTest::stringLength( "name", name, 1 )
	load File.expand_path( File.dirname( Kesh::Loader::ModuleInfo.getCallingFile() ) + "/" + name + ".library.rb"  )
end


# Require the given class name.  Path is relative to that of the calling file's.
def requireClass( name )
	Kesh::ArgTest::type( "name", name, String )
	Kesh::ArgTest::stringLength( "name", name, 1 )
	require File.expand_path( File.dirname( Kesh::Loader::ModuleInfo.getCallingFile() ) + "/" + name + ".class.rb" )
end


# Load the given class name.  Path is relative to that of the calling file's.
def loadClass( name )
	Kesh::ArgTest::type( "name", name, String )
	Kesh::ArgTest::stringLength( "name", name, 1 )
	require File.expand_path( File.dirname( Kesh::Loader::ModuleInfo.getCallingFile() ) + "/" + name + ".class.rb"  )
end


# Load the given file name.  Path is relative to that of the calling file's.
def requireFile( name )
	Kesh::ArgTest::stringLength( "name", name, 1 )
	require File.expand_path( File.dirname( Kesh::Loader::ModuleInfo.getCallingFile() ) + "/" + name )
end


# Require the given file name.  Path is relative to that of the calling file's.
def loadFile( name )
	Kesh::ArgTest::stringLength( "name", name, 1 )
	require File.expand_path( File.dirname( Kesh::Loader::ModuleInfo.getCallingFile() ) + "/" + name )
end