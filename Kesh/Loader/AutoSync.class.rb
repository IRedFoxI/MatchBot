requireLibrary '../../Loader'
requireLibrary '../../Asynchronousity'

module Kesh
	module Loader
	
		# A class that is used to automatically reload files when they are updated.
		class AutoSync < Kesh::Asynchronousity::ThreadControl
		
			# Initialize our AutoSync
			# * timeBetween: seconds before file checks
			def initialize( timeBetween )
				Kesh::ArgTest::type( "timeBetween", timeBetween, Fixnum )
				@timeBetween = timeBetween
				@modules = []
				@classes = []
				@files = []
			end

			
			protected
			def afterStopping()
				@modules.each do |m|
					m.load( true, true )
				end
				
				@classes.each do |c|
					c.load( true )
				end
				
				@files.each do |f|
					f.load( true )
				end

				sleep( @timeBetween )
			end
			
			
			public
			def addModule( modInfo )
				Kesh::ArgTest::type( "modInfo", modInfo, ModuleInfo )
				return false if @modules.include?( modInfo )
				@modules << modInfo
				return true
			end
			
			
			def removeModule( modInfo )
				Kesh::ArgTest::type( "modInfo", modInfo, ModuleInfo )
				return false unless @modules.include?( modInfo )
				@modules.delete( modInfo )
				return true
			end
			
			
			def hasModule?( modInfo )
				Kesh::ArgTest::type( "modInfo", modInfo, ModuleInfo )
				return @modules.include?( modInfo )
			end			


			def addClass( classInfo )
				Kesh::ArgTest::type( "classInfo", classInfo, ClassInfo )
				return false if @classes.include?( classInfo )
				@classes << classInfo
				return true
			end
			
			
			def removeClass( classInfo )
				Kesh::ArgTest::type( "classInfo", classInfo, ClassInfo )
				return false unless @classes.include?( classInfo )
				@classes.delete( classInfo )
				return true
			end			
			
			
			def hasClass?( classInfo )
				Kesh::ArgTest::type( "classInfo", classInfo, ClassInfo )
				return @classes.include?( classInfo )
			end			


			def addFile( fileInfo )
				Kesh::ArgTest::type( "fileInfo", fileInfo, FileInfo )
				return false if @files.include?( fileInfo )
				@files << fileInfo
				return true
			end
			
			
			def removeFile( fileInfo )
				Kesh::ArgTest::type( "fileInfo", fileInfo, FileInfo )
				return false unless @files.include?( fileInfo )
				@files.delete( fileInfo )
				return true
			end			
												

			def hasFile?( fileInfo )
				Kesh::ArgTest::type( "fileInfo", fileInfo, FileInfo )
				return @files.include?( fileInfo )
			end			

		end
		
	end
end
				