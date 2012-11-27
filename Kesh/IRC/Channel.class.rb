requireLibrary '../../IRC'

module Kesh
	module IRC
			
		class Channel
		
			attr_reader :server
			attr_accessor :name
			attr_reader :topic
			
			def initialize( server, name )
				Kesh::ArgTest::type( "server", server, Server )
				Kesh::ArgTest::type( "name", name, String )
				@server = server
				@name = name
				@topic = Topic.new
				@modes = []
				@clients = []
			end
			
			
			private 
			def getModeIndex( mode )
				Kesh::ArgTest::type( "mode", mode, Mode )
				return @modes.index { |cm| cm.mode == mode }
			end
			
			
			public				
			def hasChannelMode?( mode )
				Kesh::ArgTest::type( "mode", mode, Mode )
				return ( getModeIndex( mode ) != nil )
			end
			
			
			def setChannelMode( mode, status, parameter = nil )
				Kesh::ArgTest::type( "mode", mode, Mode )
				Kesh::ArgTest::type( "status", status, [ FalseClass, TrueClass ] )
				Kesh::ArgTest::type( "parameter", parameter, String, true )

				i = getModeIndex( mode )
				
				if ( i != nil )
					cmode = @modes[ i ]
				else
					cmode = ChannelMode.new( self, mode, status, parameter )
					@modes << cmode
				end

				cmode.status = status
				cmode.parameter = parameter
			end
			
			
			def getChannelModes()
				return ( @modes + [] )
			end
			
			
			def addMaskMode( mode, mask )
				Kesh::ArgTest::type( "mode", mode, Mode )
				Kesh::ArgTest::type( "mask", mask, String )
				Kesh::ArgTest::stringLength( "mask", mask, 1 )
				
				cml = getModeIndex( mode )				
				return false if ( cml == nil ) # Unsupported mode?! These are set when the client connets
				
				return cml.add( mask )
			end
			
			
			def removeMaskMode( mode, mask )
				Kesh::ArgTest::type( "mode", mode, Mode )
				Kesh::ArgTest::type( "mask", mask, String )
				Kesh::ArgTest::stringLength( "mask", mask, 1 )

				cml = getModeIndex( mode )				
				return false if ( cml == nil ) # Unsupported mode?! These are set when the client connets
				
				return cml.remove( mask )
			end			
			
			
			private
			def getModeLists()
				@modes.find_all { |m| m.is_a?( ChannelModeList ) }
			end
			
			
			def getClientIndex( mixed )
				Kesh::ArgTest::type( "mixed", mixed, [ String, Client ] )
				return @clients.index { |c| c.name == mixed } if mixed.is_a?( String )
				return @clients.index( mixed ) if mixed.is_a?( Client )
			end
			
			
			public								
			def hasClient?( client )
				Kesh::ArgTest::type( "client", client, Client )
				return getClientIndex( client ) != nil
			end
			
			
			def getClient( name )
				Kesh::ArgTest::type( "name", name, String )
				i = getClientIndex( name )
				return nil if ( i == nil )
				return @clients[ i ]
			end
			
			
			def addClient( client )
				Kesh::ArgTest::type( "client", client, Client )
				return false if hasClient?( client )
				@clients << client
				return true
			end
			
			
			def removeClient( client )
				Kesh::ArgTest::type( "client", client, Client )
				
				i = getClientIndex( client )
				return false if ( i == nil )
					
				@clients.delete_at( i )
					
				getModeLists().each do |ml|
					ml.remove( client )
				end						
					
				return true
			end
			
			
			def getChannelClients()
				return ( @clients + [] )
			end
			
			
			def modesClient( client )
				Kesh::ArgTest::type( "client", client, Client )

				cModes = []
				
				getModeLists().each do |ml|
					cModes << ml.mode if ml.include?(client)
				end
				
				return cModes
			end
			
			
			def hasClientMode?( mode, client )
				Kesh::ArgTest::type( "mode", mode, Mode )
				Kesh::ArgTest::type( "client", client, Client )
				return clientModes( client ).include?( mode )
			end
			
			
			def addClientMode( mode, client )
				Kesh::ArgTest::type( "mode", mode, Mode )
				Kesh::ArgTest::type( "client", client, Client )
				
				cml = getModeIndex( mode )				
				return false if ( cml == nil ) # Unsupported mode?! These are set when the client connets
				
				return cml.add( client )
			end
			
			
			def removeClientMode( mode, client )
				Kesh::ArgTest::type( "mode", mode, Mode )
				Kesh::ArgTest::type( "client", client, Client )

				cml = getModeIndex( mode )				
				return false if ( cml == nil ) # Unsupported mode?! These are set when the client connets
				
				return cml.remove( client )
			end
			
			
			def matchesClient( client )
				Kesh::ArgTest::type( "client", client, Client )
				
				cModes = []
				
				getModeLists().each do |ml|
					cModes << ml.mode if ml.matches?(client)
				end
				
				return cModes
			end
			
			
			def matchesClientMode( mode, client )
				Kesh::ArgTest::type( "mode", mode, Mode )
				Kesh::ArgTest::type( "client", client, Client )
				return clientMathces( client ).include?( mode )
			end
			
			
			def getClients()
				return ( @clients + [] )
			end

							
			def countClient()
				@clients.size
			end
			
		end
		
	end
end
