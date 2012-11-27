requireLibrary '../../../IO'
requireClass '../Serialisable'
requireClass 'IniSection'
requireClass 'IniValue'
requireClass '../FileStream'

module Kesh
	module IO
		module Storage
	
			class IniFile < Kesh::IO::Serialisable
			
				attr_reader :sections
				
				def initialize()
					@sections = []
				end
				
				
				private
				def getSectionIndex( name )
					@sections.each_index { |s|
						return s if ( @sections[ s ].name == name )
					}					
					return -1
				end


				public
				def addSection( name )
					return false if ( getSectionIndex( name ) != -1 )
					@sections.push( IniSection.new( name ) )
					return true
				end
				
				
				def getSection( name )
					i = getSectionIndex( name )
					return nil if ( i == -1 )
					return @sections[ i ]
				end
				

				def hasSection?( name )			
					return ( getSectionIndex( name ) >= 0 )
				end
				

				def removeSection( name )
					i = getSectionIndex( name )
					return false if ( i == -1 )
					@sections.delete_at( i )
					return true
				end
				
				
				def getValue( section, name )
					i = getSectionIndex( section )
					return nil if ( i == -1 )					
					return @sections[ i ].getValue( name )
				end
				

				def setValue( section, name, value )
					i = getSectionIndex( section )
					added = false
					
					if ( i == -1 )
						i = @sections.length
						@sections.push( IniSection.new( section ) )
						added = true
					end
					
					return ( @sections[ i ].setValue( name, value ) || added )
				end


				def hasValue?( section, name )
					i = getSectionIndex( section )					
					return false if ( i == -1 )					
					return @sections[ i ].hasValue?( name )
				end
				
				
				def removeValue( section, name )
					i = getSectionIndex( section )					
					return false if ( i == -1 )					
					return @sections[ i ].removeValue( name )
				end				
				
				
				def serialise( stream )
					ArgTest::type( "stream", stream, Kesh::IO::Stream )
					
					@sections.each { |section|
						section.serialise( stream )
					}
				end
				
				
				def IniFile.deserialise( stream )
					ArgTest::type( "stream", stream, Kesh::IO::Stream )
					
					ini = IniFile.new()
					
					begin
						section = IniSection.deserialise( stream )
						ini.sections.push( section ) if ( section != nil )
					end until ( section == nil )
					
					return ini
				end
				
				
				def writeToFile( filename )
					stream = FileStream.new( filename, "wb" )
					serialise( stream )
					stream.close()
				end
				
				
				def IniFile.loadFromFile( filename )
					stream = FileStream.new( filename, "rb" )
					ini = IniFile.deserialise( stream )
					stream.close()
					return ini
				end
				
			end
			
		end
	end
end
				