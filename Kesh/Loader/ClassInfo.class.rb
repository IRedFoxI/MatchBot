require File.expand_path( File.dirname( __FILE__ ) + '/../../Loader.library.rb' )
requireClass 'FileInfo'

module Kesh
	module Loader
	
		# Stores information about a file
		class ClassInfo < Kesh::Loader::FileInfo

			# Makes sure that the module is defined in the current namespace
			def ClassInfo.defineClass( fullClassName )
				ArgTest::type( "fullClassName", fullClassName, String )
				ArgTest::stringLength( "fullClassName", fullClassName, 1 )			
				return eval( "class ::#{fullClassName}\n\nend" )
			end

			# The class Symbol
			attr_reader :clazz
			
			# Initialize our ClassInfo !
			def initialize( modInfo, name )
				super( modInfo, name )
				#ClassInfo.defineClass( "#{@modInfo.fullName()}::#{@name}" )
				#@class = eval( "#{@modInfo.fullName()}::#{@name}" )
				@clazz = nil
			end
			
			
			def path()
				super() + ".class.rb"
			end
			
			def load( reload )
				super( reload, "Class" )
				@clazz = eval( "#{@modInfo.fullName()}::#{@name}" )
			end
			
		end
		
	end
end

			
			