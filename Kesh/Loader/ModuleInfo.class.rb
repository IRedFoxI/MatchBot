require File.expand_path( File.dirname( __FILE__ ) + '/../../Loader.library.rb' )

module Kesh
	module Loader	
		# A class that handles the (re)loading of modules, classes and files.  
		# Also stores module variables.
		class ModuleInfo
		
			# Returns a String containing the location of the file that called the method calling this method.
			def ModuleInfo.getCallingFile()
				callList = caller( 2 )
				callList[ 0 ][/^(.+):\d+(:in `)?/]
				return $1
			end
			
			
			# Makes sure that the module is defined in the current scope
			def ModuleInfo.defineModule( fullModuleName )
				ArgTest::type( "fullModuleName", fullModuleName, String )
				ArgTest::stringLength( "fullModuleName", fullModuleName, 1 )			
				return eval( "module ::#{fullModuleName} end" )
			end
			
			
			# Turns a String into a Module object
			def ModuleInfo.stringToModule( fullModuleName )
				ArgTest::type( "fullModuleName", fullModuleName, String )
				ArgTest::stringLength( "fullModuleName", fullModuleName, 1 )			
				return eval( "#{fullModuleName}" )
			end
			
		
			# Given the base directory for the module and the modules full name, relative to the base directory, and returns a ModuleInfo object describing the module.
			def ModuleInfo.parse( basePath, fullModuleName )
				ArgTest::type( "basePath", basePath, String )
				ArgTest::stringLength( "basePath", basePath, 1 )
				ArgTest::type( "fullModuleName", fullModuleName, String )
				ArgTest::stringLength( "fullModuleName", fullModuleName, 1 )			
				
				ModuleInfo.defineModule( fullModuleName )				
				mod = ModuleInfo.stringToModule( fullModuleName )		
				return ModuleInfo.new( mod, basePath )
			end
			
			
			# The module.
			attr_reader :mod
			
			# The base path of the module.
			attr_reader :basePath
			
			# Initializes our module.
			#
			# * mod: Module object.
			# * basePath: dir in which the modules furthest ancestor is located.
			def initialize( mod, basePath )
				ArgTest::type( "module", mod, Module )
				ArgTest::type( "basePath", basePath, String )
				@mod = mod
				@basePath = File.expand_path( basePath )
				@vars = Hash[]
			end
			
			
			# Returns a String Array of the modules Hierarchy, starting with the most distant ancestor, ending with the current module's name.
			def hierarchy()
				fullName().split( "::" )
			end
					
			
			# Returns the module name, with it's full namespace, as a String.
			def fullName()
				@mod.to_s
			end
			
			
			# Returns the path in which the module files reside, without the trailing slash, as a String.
			def path()
				@basePath + "/" + hierarchy().join( "/" )
			end
			
			
			# Requires (or load, if 'reload') all classes, files and all child modules if 'recursive'.
			def load( reload = false, recursive = false )
				puts ( "[Module] #{fullName()}" ) if ( ( defined? $LoaderModule ) && $LoaderModule.getVar( "Verbose" ) >= Kesh::Loader::VERBOSE_MODULE )
				loadFiles( reload )
				loadClasses( reload )
				loadChildModules( reload, recursive ) if recursive
			end
			
			
			# Returns a ModuleInfo object representing a child of this module.  Can go deeper than just 1 layer, if the appropriate namepace is given.
			# E.g. ModuleInfo( Blah ).childModule( Moo::Argh ) returns Blah::Moo::Arg
			def childModule( name )
				ArgTest::type( "name", name, String )
				ArgTest::stringLength( "name", name, 1 )						
				return ModuleInfo.parse( @basePath, "#{fullName()}::#{name}" )
			end
			
			
			# Returns an Array of ModuleInfos of this module's child modules.
			def childModules()
				list = []			
				dir = Dir.new( path() )
	
				dir.each do |file|
					next unless File.directory?( path() + "/" + file )
					next if ( file[/^([A-Z][a-z]*)+$/] == nil )
					list << childModule( $1 )
				end
				
				return list
			end
			
			
			# Require (or load, if 'reload') all child modules for this module.
			def loadChildModules( reload = false, recursive = false )
				Kesh::ArgTest::valueRange( "recursive", recursive, [ true, false ] )
				Kesh::ArgTest::valueRange( "reload", reload, [ true, false ] )
				
				childModules().each do |mi|
					mi.loadClasses( reload )
					mi.loadChildModules( reload, recursive ) if recursive
				end
			end
			
			
			# Return a ClassInfo representing a class in this ModuleInfo.
			def clazz( name )
				Kesh::ArgTest::type( "name", name, String )
				Kesh::ArgTest::stringLength( "name", name, 1 )			
				return Kesh::Loader::ClassInfo.new( self, name )
			end
			
	
			# Returns an Array of ClassInfos of this module's classes.
			# These are files that match the pattern *.class.rb
			def classes()
				list = []
				dir = Dir.new( path() )
				
				dir.each do |file|
					next if File.directory?( path() + "/" + file )
					next if ( file[/^([A-Z][A-Za-z]*)+\.class\.rb$/] == nil )
					list << clazz( $1 )
				end
				
				return list
			end
			
			
			
			# Require (or load, if 'reload') all classes in this module's dir.
			# Returns an array of Class Symbols of the classes loaded.
			def loadClasses( reload = false )
				loaded = []
				
				classes().each do |clazz|
					clazz.load( reload )
					loaded << clazz
				end
				
				return loaded
			end
			
			
			# Return a FileInfo representing a class in this ModuleInfo.
			def file( name )
				Kesh::ArgTest::type( "name", name, String )
				Kesh::ArgTest::stringLength( "name", name, 1 )			
				return Kesh::Loader::FileInfo.new( self, name )
			end
			
			
			# Returns a Array of FileInfos representing files in this ModuleInfos that are not dirs and do not match the pattern *.class.rb
			def files()
				list = []
				dir = Dir.new( path() )
				
				dir.each do |f|
					next if File.directory?( path() + "/" + f )
					next unless ( f[/^([A-Z][A-Za-z]*)+\.class\.rb$/] == nil )
					list << file( f )
				end
				
				return list
			end
			
	
			# Require (or load, if 'reload') all files in this module's dir.
			def loadFiles( reload = false )
				files().each do |file|
					file.load( reload )
				end
			end		
	
			
			# Get a variable associated with the module.
			def getVar( name )
				ArgTest::type( "name", name, String )
				name.strip!()
				ArgTest::stringLength( "name", name, 1 )
				return @vars[ name ]
			end
			
			
			# Set a variable associated with the module.
			def setVar( name, value )
				ArgTest::type( "name", name, String )
				name.strip!()
				ArgTest::stringLength( "name", name, 1 )
				ArgTest::type( "value", value, Object, true )
				@vars[ name ] = value
			end
			
			
			# Return true if the module has the variable, false otherwise.
			def hasVar?( name )
				ArgTest::type( "name", name, String )
				name.strip!()
				ArgTest::stringLength( "name", name, 1 )
				return @vars.has_key?( name )
			end
					
		end
		
	end
		
end
			