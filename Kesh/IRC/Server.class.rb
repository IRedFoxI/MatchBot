requireLibrary '../../IRC'
requireLibrary '../../IO'
requireLibrary '../../Network'
requireLibrary '../../Asynchronousity'

module Kesh
	module IRC

		class Server

			# :server_state_unconnected
			# :server_state_connected
			# :server_state_registered
			# :server_state_disconnected
			# :server_state_error

			attr_reader :host
			attr_reader :port
			attr_reader :bind
			attr_reader :password
			attr_reader :maxNickLength
			attr_reader :status
			attr_reader :network
			attr_reader :version
			attr_reader :motd
			attr_reader :myClient
			attr_reader :serverClient
			attr_reader :events

			def initialize( host, port, password, nick, ident, realName, bind = nil )
				Kesh::ArgTest::type( "host", host, String )
				Kesh::ArgTest::type( "port", port, Fixnum )
				Kesh::ArgTest::intRange( "port", port, 1, 65535 )
				Kesh::ArgTest::type( "password", password, String, true )
				Kesh::ArgTest::type( "nick", nick, String )
				Kesh::ArgTest::stringLength( "nick", nick, 1, 20 )
				Kesh::ArgTest::type( "ident", ident, String )
				Kesh::ArgTest::stringLength( "ident", ident, 1, 20 )
				Kesh::ArgTest::type( "realName", realName, String )
				Kesh::ArgTest::stringLength( "realName", realName, 1, 20 )
				@host = host
				@port = port
				@bind = bind
				@password = password
				@desiredNick = nick
				@maxNickLength = 20
				@clients = []
				@channels = []
				@serverClient = Client.new( self, nil, nil, host )
				@myClient = Client.new( self, nick, ident, 'localhost', realName )
				@myClientModes = []
				@socket = Kesh::Network::Socket.new( host, port, bind )
				@reader = Kesh::IO::AsynchronousStreamReader.new( @socket, self.method( "processLine" ) )
				@motd = []
				@version = nil
				@network = nil
				@clientModes = []
				@channelModes = []
				@channelTypes = "#"
				@userPrefixes = Hash[]
				@status = :server_state_unconnected
				@events = Kesh::Asynchronousity::EventSystem.new()
				@events.addEvent( :eventConnect, true )
				@events.addEvent( :eventError, true )
				@events.addEvent( :eventCommand, true )
				@events.addEvent( :eventRegister, true )
				@events.addEvent( :eventEvent, true )
				@events.addEvent( :eventNumeric, true )
				@events.addEvent( :eventPrivMsg, true )
				@events.addEvent( :eventActionMsg, true )
				@events.addEvent( :eventNoticeMsg, true )
				@events.addEvent( :eventCTCPMsg, true )
				@events.addEvent( :eventJoin, true )
				@events.addEvent( :eventPart, true )
				@events.addEvent( :eventKick, true )
				@events.addEvent( :eventQuit, true )
				@events.addEvent( :eventMode, true )
				@events.addEvent( :eventModeIndividual, true )
				@events.addEvent( :eventNick, true )
				@events.addEvent( :eventDisconnect, true )
			end


			def connect()
				return unless ( @status == :server_state_unconnected )
				return unless @events.call( :eventConnect, self, :event_type_before )
				@socket.connect()
				@status = :server_state_connected
				send( Commands::PasswordCommand.new( @password ) ) unless ( @password == nil || @password == "" )
				send( Commands::NickCommand.new( @myClient.name ) )
				send( Commands::UserCommand.new( @myClient.ident, 'localhost', @host, @myClient.realName ) )
				@reader.start()
				@events.call( :eventConnect, self, :event_type_after )
			end


			def disconnect( force = false )
				return unless ( @status == :server_state_connected || @status == :server_state_registered )
				return unless ( @events.call( :eventDisconnect, self, :event_type_before ) || force )
				@status = :server_state_disconnected
				@reader.stop()
				@socket.disconnect()
				@events.call( :eventDisconnect, self, :event_type_after )
			end


			private
			def writeLine( string )
				Kesh::ArgTest::type( "string", string, String )
				puts DateTime.now.strftime( '%m/%d %H:%M:%S' ) + " >> " + string
				@socket.writeLine( string )
			end


			public
			def send( command )
				Kesh::ArgTest::type( "command", command, Command )
				return unless @events.call( :eventCommand, self, :event_type_before, command )
				writeLine( command.format() )
				@events.call( :eventCommand, self, :event_type_after, command )
			end


			def alive?()
				return false unless ( @socket.error == :socket_error_none )
				return false unless ( @reader.exception == nil )
				return false if ( @status == :server_state_disconnected || @status == :server_state_error )
				return true
			end


			private
			def addClientMode( mode )
				Kesh::ArgTest::type( "mode", mode, Mode )
				return false unless ( getClientMode( mode.char ) == nil )
				@clientModes << mode
				return true
			end


			public
			def getClientMode( char )
				Kesh::ArgTest::type( "char", char, String )
				Kesh::ArgTest::stringLength( "char", char, 1, 1 )
				i = @clientModes.index { |m| m.char == char }
				return @clientModes[ i ] unless ( i == nil )
				return nil
			end


			def getModeForClientPrefix( name )
				Kesh::ArgTest::type( "name", name, String )
				Kesh::ArgTest::stringLength( "name", name, 1 )
				return nil if ( name.length == 1 )
				return nil if ( @userPrefixes[ name[ 0 ] ] == nil )
				return getChannelMode( @userPrefixes[ name[ 0 ] ] )
			end


			def isChannel?( string )
				Kesh::ArgTest::type( "string", string, String )
				Kesh::ArgTest::stringLength( "string", string, 1 )

				return false if ( string.length == 1 )

				@channelTypes.each_char do |char|
					return true if ( string[ 0 ] == char )
				end

				return false
			end


			private
			def addChannelMode( mode )
				Kesh::ArgTest::type( "mode", mode, Mode )
				return false unless ( getChannelMode( mode.char ) == nil )
				@channelModes << mode
				return true
			end


			public
			def getChannelMode( char )
				Kesh::ArgTest::type( "char", char, String )
				Kesh::ArgTest::stringLength( "char", char, 1, 1 )
				i = @channelModes.index { |m| m.char == char }
				return @channelModes[ i ] unless ( i == nil )
				return nil
			end


			def getChannelByName( name )
				Kesh::ArgTest::type( "name", name, String )
				i = @channels.index { |c| c.name == name }
				return @channels[ i ] unless ( i == nil )
				channel = Channel.new( self, name )
				@channels << channel
				return channel
			end


			def getClientByMask( fullMask )
				Kesh::ArgTest::type( "fullMask", fullMask, String )

				clientInfo = Client.parse( fullMask )

				if ( clientInfo[ 0 ] == nil )
					@serverClient.host = clientInfo[ 2 ]
					return @serverClient
				end

				return @myClient if ( clientInfo[ 0 ] == @myClient.name	)

				i = @clients.index { |c| c.name == clientInfo[ 0 ] }

				# Check to make sure there's a full mask match, or it's a different person.
				if ( i != nil )
					client = @clients[ i ]
					valid = false

					# We don't have any info except the name, so probably a match.
					if ( client.ident == nil && client.host == nil )
						client.ident = clientInfo[ 1 ]
						client.host = clientInfo[ 2 ]
						valid = true

					# We don't have ident info, so compare hosts.
					elsif ( client.ident == nil )
						if ( client.host == clientInfo[ 2 ] )
							client.ident = clientInfo[ 1 ]
							valid = true
						end

					# We don't have host info, so compare idents.
					elsif ( client.host == nil )
						if ( client.ident == clientInfo[ 1 ] )
							client.host = clientInfo[ 2 ]
							valid = true
						end

					# We have full info, do a full comparison.
					elsif ( client.ident == clientInfo[ 1 ] && client.host == clientInfo[ 2 ] )
						valid = true
					end

					return client if valid

					client.name += ":defunct"
					return getClientByName( fullMask )
				end

				newClient = Client.new( self, clientInfo[ 0 ], clientInfo[ 1 ], clientInfo[ 2 ] )
				@clients << newClient
				return newClient
			end


			def getClientByName( name )
				Kesh::ArgTest::type( "name", name, String )

				return @serverClient if ( name == nil )
				return @myClient if ( name == @myClient.name )

				i = @clients.index { |c| c.name == name }
				return @clients[ i ] unless ( i == nil )

				newClient = Client.new( self, name )
				@clients << newClient
				return newClient
			end


			def processLine( stream, string )
				begin
					Kesh::ArgTest::type( "stream", stream, Kesh::IO::Stream )
					Kesh::ArgTest::type( "string", string, String )

					puts DateTime.now.strftime( '%m/%d %H:%M:%S' ) + " << " + string
					event = Event.parse( self, string )

					@events.call( :eventEvent, self, :event_type_before, event )
					@events.call( :eventNumeric, self, :event_type_before, event ) if event.is_a?( Events::NumericEvent )

					if ( event.is_a?( Events::Numerics::UModeIsNumeric ) )

					end

					if ( event.is_a?( Events::PingEvent ) )
						send( Commands::PongCommand.new( event.token ) )

					elsif ( event.is_a?( Events::Numerics::WelcomeNumeric ) )
						@events.call( :eventRegister, self, :event_type_before )
						@status = :server_state_registered
						@events.call( :eventRegister, self, :event_type_after )

					elsif ( event.is_a?( Events::Numerics::ServerInfoNumeric ) )
						@serverClient.host = event.host
						@version = event.version

					elsif ( event.is_a?( Events::Numerics::ServerDetailsNumeric ) )
						processServerDetails( event )

					elsif ( event.is_a?( Events::Numerics::ServerSupportsNumeric ) )
						processServerSupports( event )

					elsif ( event.is_a?( Events::Numerics::MOTDLineNumeric ) )
						@motd << event.line

					elsif ( event.is_a?( Events::Numerics::MOTDStartNumeric ) )
						@motd = []

					elsif( event.is_a?( Events::PrivMsgEvent ) )
						if ( @events.call( :eventPrivMsg, self, :event_type_before, event ) )
							@events.call( :eventPrivMsg, self, :event_type_after, event )
						end

					elsif( event.is_a?( Events::ActionMsgEvent ) )
						if ( @events.call( :eventActionMsg, self, :event_type_before, event ) )
							@events.call( :eventActionMsg, self, :event_type_after, event )
						end

					elsif( event.is_a?( Events::NoticeMsgEvent ) )
						if ( @events.call( :eventNoticeMsg, self, :event_type_before, event ) )
							@events.call( :eventNoticeMsg, self, :event_type_after, event )
						end

					elsif( event.is_a?( Events::CTCPMsgEvent ) )
						if ( @events.call( :eventCTCPMsg, self, :event_type_before, event ) )
							@events.call( :eventCTCPMsg, self, :event_type_after, event )
						end

					elsif ( event.is_a?( Events::JoinEvent ) )
						@events.call( :eventJoin, self, :event_type_before, event )
						event.channel.addClient( event.source )
						event.source.addChannel( event.channel )
						send( Commands::ModeCommand.new( event.channel, "+b" ) ) if ( event.source == myClient )
						@events.call( :eventJoin, self, :event_type_after, event )

					elsif ( event.is_a?( Events::NickEvent ) )
						@events.call( :eventNick, self, :event_type_before, event )
						oldClient = getClientByName( event.newName )
						oldClient.name = oldClient.name + ":defunct" unless ( oldClient == nil )
						event.source.name = event.newName
						@events.call( :eventNick, self, :event_type_after, event )

					elsif ( event.is_a?( Events::PartEvent ) )
						@events.call( :eventPart, self, :event_type_before, event )
						event.source.removeChannel( event.channel )
						event.channel.removeClient( event.source )
						@events.call( :eventPart, self, :event_type_after, event )

					elsif ( event.is_a?( Events::KickEvent ) )
						@events.call( :eventKick, self, :event_type_before, event )
						event.target.removeChannel( event.channel )
						event.channel.removeClient( event.target )
						@events.call( :eventKick, self, :event_type_after, event )

					elsif ( event.is_a?( Events::QuitEvent ) )
						@events.call( :eventQuit, self, :event_type_before, event )
						event.source.removeAllChannels()
						@channels.each do |chan|
							chan.removeClient( event.source )
						end
						@events.call( :eventQuit, self, :event_type_after, event )

					elsif ( event.is_a?( Events::ClientModeEvent ) )
						@events.call( :eventMode, self, :event_type_before, event )
						processClientMode( event )
						@events.call( :eventMode, self, :event_type_after, event )

					elsif ( event.is_a?( Events::ChannelModeEvent ) )
						@events.call( :eventMode, self, :event_type_before, event )
						processChannelMode( event )
						@events.call( :eventMode, self, :event_type_after, event )

					elsif ( event.is_a?( Events::ErrorEvent ) )
						@events.call( :eventError, self, :event_type_before, event )
						disconnect()
						@status = :server_state_error
						@events.call( :eventError, self, :event_type_after, event )

					elsif( event.is_a?( Events::Numerics::NamReplyNumeric ) )
                        event.clientList.each { |c|
                            event.channel.addClient( c[ 0 ] )
                            c[ 0 ].addChannel( event.channel )
                        }

					#elsif( event.is_a?( Events::Numerics::GenericNumeric ) )
						#puts "Generic Numeric: #{event.source.to_s} #{event.id} #{event.tokens.join( ' ' )}"

					#elsif ( event.is_a?( Events::GenericEvent ) )
						#puts "Generic Event: #{event.source.to_s} #{event.type.to_s} #{event.tokens.join( ' ' )}"

					elsif ( event == nil )
						puts "Unknown Line: #{string}"
					end

					@events.call( :eventNumeric, self, :event_type_after, event ) if event.is_a?( Events::NumericEvent )
					@events.call( :eventEvent, self, :event_type_after, event )

				rescue Exception => ex
					puts ex.to_s
					puts ex.backtrace
					exit!
				end
			end


			private
			def processServerDetails( event )
				Kesh::ArgTest::type( "event", event, Events::Numerics::ServerDetailsNumeric )

				@serverClient.host = event.host
				@version = event.version

				event.clientModes.each_char do |char|
					addClientMode( Mode.new( char, :mode_type_flag ) )
				end

				event.channelModesWithParameter.each_char do |char|
					mode = nil

					if ( char == "o" )
						mode = Mode.new( char, :mode_type_clientlist )

					elsif ( char == "h" )
						mode = Mode.new( char, :mode_type_clientlist )

					elsif ( char == "v" )
						mode = Mode.new( char, :mode_type_clientlist )

					elsif ( char == "b" )
						mode = Mode.new( char, :mode_type_masklist )

					else
						mode = Mode.new( char, :mode_type_parameter )
					end

					addChannelMode( mode )
				end

				event.channelModes.each_char do |char|
					addChannelMode( Mode.new( char, :mode_type_flag ) )
				end
			end


			def processServerSupports( event )
				Kesh::ArgTest::type( "event", event, Events::Numerics::ServerSupportsNumeric )
				@network = event.supports[ "NETWORK" ] unless ( event.supports[ "NETWORK" ] == nil )
				@maxNickLength = Integer( event.supports[ "NICKLEN" ] ) unless ( event.supports[ "NICKLEN" ] == nil )
				@maxNickLength = Integer( event.supports[ "MAXNICKLEN" ] ) unless ( event.supports[ "MAXNICKLEN" ] == nil )
				@channelTypes = event.supports[ "CHANTYPES" ] unless ( event.supports[ "CHANTYPES" ] == nil )

				unless ( event.supports[ "PREFIX" ] == nil )
					event.supports[ "PREFIX" ][/^\(([^)]*)\)(.*)$/]
					return nil if ( $1 == nil )

					(0...$1.length).each do |i|
						@userPrefixes[ $2[ i ] ] = $1[ i ]
					end
				end
			end


			def processClientMode( event )
				Kesh::ArgTest::type( "event", event, Events::ClientModeEvent )

				event.modes.each do |cm|
					i = @myClientModes.index { |mcm| mcm.mode == cm.mode }
					mycm = nil
					@events.call( :eventModeIndividual, self, :event_type_before, cm )

					if ( i == nil )
						if ( cm.status )
							mycm = ClientMode.new( cm.client, cm.mode, cm.status )
							@myClientModes << mycm
						end

					else
						mycm = @myClientModes[ i ]
						mycm.status = cm.status
					end

					@events.call( :eventModeIndividual, self, :event_type_after, cm )
				end
			end


			def processChannelMode( event )
				Kesh::ArgTest::type( "event", event, Events::ChannelModeEvent )

				event.modes.each do |cm|
					# Flag type
					if ( cm.is_a?( ChannelMode ) )
						@events.call( :eventModeIndividual, self, :event_type_before, cm )
						cm.channel.setChannelMode( cm.mode, cm.status, cm.parameter )
						@events.call( :eventModeIndividual, self, :event_type_after, cm )

					# Parameter type
					elsif ( cm.is_a?( ChannelModeListDelta ) )
						cm.list.each do |value|
							cmForEvent = ChannelMode.new( cm.channel, cm.mode, cm.status, value )
							@events.call( :eventModeIndividual, self, :event_type_before, cmForEvent  )

							if ( cm.status )
								cm.channel.addMaskMode( cm.mode, value ) if ( cm.mode.type == :mode_type_masklist )
								cm.channel.addClientMode( cm.mode, value ) if ( cm.mode.type == :mode_type_clientlist )
							else
								cm.channel.removeMaskMode( cm.mode, value ) if ( cm.mode.type == :mode_type_masklist )
								cm.channel.removeClientMode( cm.mode, value ) if ( cm.mode.type == :mode_type_clientlist )
							end

							@events.call( :eventModeIndividual, self, :event_type_after, cmForEvent  )
						end
					end
				end
			end


			public
			def hasModeMyClient?( mode )
				Kesh::ArgTest::type( "mode", mode, Mode )
				i = @myClientModes.index { |mcm| mcm.mode == mode }
				return false if ( i == nil )
				return @myClientModes[ i ].status
			end


			def modesMyClient()
				return ( @myClientModes + [] )
			end

		end

	end
end
