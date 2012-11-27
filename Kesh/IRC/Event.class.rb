requireLibrary '../../IRC'

module Kesh
	module IRC
		
		class Event
		
			EventClasses = []
		
			def Event.parse( server, string )
				Kesh::ArgTest::type( "server", server, Server )
				Kesh::ArgTest::type( "string", string, String )
				
				tokens = Event.tokenise( server, string )
				
				$IRCModule.getVar( "Events" ).each do |c|
					ec = c.clazz
					next if ( ec == Events::GenericEvent )
					next if ( ec.method( :parse ) == nil )
					next unless ( ec.to_s == ec.method(:parse).owner.to_s[ 8..-2 ] )
					event = ec.parse( server, tokens )
					return event unless ( event == nil )
				end
				
				return Events::GenericEvent.parse( server, tokens )
			end
			

			def Event.tokenise( server, string )
				Kesh::ArgTest::type( "server", server, Server )
				Kesh::ArgTest::type( "string", string, String )

				tokens = []
				token = ""
				endStr = false
				
				string.each_char do |char|
					if ( endStr )
						token += char
						
					elsif ( char == ":" )
						endStr = true if ( tokens.length > 0 )
						token.strip!()
						tokens << token if ( token != "" )						
						
					elsif ( char != " " )
						token += char
						
					elsif ( tokens.length == 0 && string[ 0 ] == ":" )
						token.strip!()
						tokens << server.getClientByMask( token ) if ( token != "" )
						token = ""
						
					elsif ( token.strip() != "" )
						token.strip!()
						tokens << token
						token = ""
			
					end
				end
				
				token.strip!()
				tokens << token if ( token != "" )
				return tokens
			end						
			
		
			attr_reader :server
			attr_reader :source
			
			def initialize( server, source )
				Kesh::ArgTest::type( "server", server, Server )
				Kesh::ArgTest::type( "source", source, Client )
				@server = server
				@source = source
			end
			
		end
		
	end
end
