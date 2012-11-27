require File.expand_path( File.dirname( __FILE__ ) + '/../../Loader.library.rb' )

module Kesh
	module Loader
	
		# Stores information about a file
		class FileInfo
		
			# Name of the file
			attr_reader :name
			
			# Module that the file's in.
			attr_reader :modInfo
			
			# Load time
			attr_reader :time
			
			# Initialize our FileInfo !
			def initialize( modInfo, name )
				Kesh::ArgTest::type( "modInfo", modInfo, ModuleInfo )
				Kesh::ArgTest::type( "name", name, String )
				@modInfo = modInfo
				@name = name
				@time = Time.at( 0 )
			end
			
			
			def path()
				"#{@modInfo.path()}/#{@name}"
			end
			
			def load( reload = false, type = "File" )
				puts ( "[#{type}] #{@modInfo.fullName()}::#{@name}" ) if ( ( defined? $LoaderModule ) && ( $LoaderModule.getVar( "Verbose" ) >= Kesh::Loader::VERBOSE_FILE ) )
				
				filePath = path()
				fileTime = File.mtime( filePath )		
				
				return false unless ( fileTime > @time )
				
				begin
					load filePath if reload
					require filePath if !reload
					@time = fileTime
					return true
					
				rescue Exception
					puts "Error loading class #{path()}:"
					puts $!
					exit!
				end			
			end
			
		end
		
	end
end			
			