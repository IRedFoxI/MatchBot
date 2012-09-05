require 'date'
require 'fileutils'
require File.expand_path( File.dirname( __FILE__ ) + '/../Loader.library.rb' )
requireLibrary '../IRC'
requireLibrary '../IO'
requireClass 'DateComparer'

Match = Struct.new( :id, :date, :team, :gametype, :comment, :yes, :maybe, :no, :results, :deleted )
Result = Struct.new( :map, :team, :ourscore, :theirscore, :comment )

module MatchBot
	
	class MatchBot
	
		def initialize( host, port, password, nick, ident, realName, privchannel, key, pubchannel, bind = nil )
			@irc = Kesh::IRC::Server.new( host, port, password, nick, ident, realName, bind )
			@irc.events.addCallback( :eventRegister, self.method( "startup" ) )
			@irc.events.addCallback( :eventPrivMsg, self.method( "parseMessage" ) )
			@irc.events.addCallback( :eventJoin, self.method( "joinChan" ) )
			@sorter = Kesh::DataStructures::Sort::MergeSort.new( DateComparer.new )
			@privchannel = privchannel;
			@key = key;
			@pubchannel = pubchannel;
			loadData()
		end
		
		
		def connect()
			@irc.connect()
		end
		
		
		def wait()
			while ( @irc.alive? )
				sleep( 0.1 )
			end
		end
		
		
		def startup( id, sender, type, parameter )
			return if ( type == :event_type_before )	
			@irc.send( Kesh::IRC::Commands::JoinCommand.new( @irc.getChannelByName( @privchannel ), @key  ) )
			@irc.send( Kesh::IRC::Commands::JoinCommand.new( @irc.getChannelByName( @pubchannel ) ) )
		end
		
		
		# id = :eventPrivMsg
		# sender = Server (@irc)
		# type = :event_type_before / :event_type_after
		# parameter = PrivMsgEvent
		def parseMessage( id, sender, type, parameter )
			return if ( type == :event_type_before )
			
			if ( parameter.message[ /^!help( .*)?$/ ] )
				if ( parameter.message[ /^!help !?([^ ]+)$/ ] )
					helpCommand( parameter, $1 )
				else
					help( parameter )
				end
				
			elsif ( parameter.message[ /^!add( .*)?$/ ] )
				if ( parameter.message[ /^!add (\d\d?\/\d\d?\/\d\d \d\d?:\d\d) ([^ ]+) ([^ ]+)( (.*))?/ ] )
					addCommand( parameter, $1, $2, $3, $5 )
				else
					addHelp( parameter )
				end		
				
			elsif ( parameter.message[ /^!(yes|maybe|no|unsign)( .*)?$/ ] )				
				if ( parameter.message[ /^!(yes|maybe|no|unsign) (\d+)( ([^ ]+))?$/ ] )
					signupCommand( parameter, $1, $2, $4 )
				else
					signupHelp( parameter )
				end
					
			elsif ( parameter.message[ /^([!@])list( .*)?$/ ] )
				if ( parameter.message[ /^([!@])list( ([^ ]+))?( ([^ ]+))?/ ] )
					listCommand( parameter, ( $1 == "@" ), $3, $5 )
				else
					listHelp( parameter )
				end

			elsif ( parameter.message[ /^([!@])info( .*)?$/ ] )
				if ( parameter.message[ /^([!@])info (\d+)( ([^ ]+))?/ ] )
					infoCommand( parameter, ( $1 == "@" ), $2, $4 )
				else
					infoHelp( parameter )
				end

			elsif ( parameter.message[ /^!update( .*)?$/ ] )
				if ( parameter.message[ /^!update (\d+) ([^ ]+)( (([^ ]+).*))?$/ ] )
					updateCommand( parameter, $1, $2, $5, $4 )
				else
					updateHelp( parameter )
				end

			elsif ( parameter.message[ /^!result( .*)?$/ ] )
				if ( parameter.message[ /^!result (\d+) ([^ ]+) ([^ ]+) (\d+) (\d+)( (.*))?$/ ] )
					resultCommand( parameter, $1, $2, $3, $4, $5, $7 )
				else
					resultHelp( parameter )
				end
				
			elsif ( parameter.message[ /^!updateresult( .*)?$/ ] )
				if ( parameter.message[ /^!updateresult (\d+) (\d+) ([^ ]+)( (([^ ]+).*))?$/ ] )
					updateResultCommand( parameter, $1, $2, $3, $6, $5 )
				else
					updateResultHelp( parameter )
				end
				
			elsif ( parameter.message[ /^!delresult( .*)?$/ ] )
				if ( parameter.message[ /^!delresult (\d+) (\d+)$/ ] )
					delResultCommand( parameter, $1, $2 )
				else
					delResultHelp( parameter )
				end
				
			elsif ( parameter.message[ /^!del( .*)?$/ ] )
				if ( parameter.message[ /^!del (\d+)$/ ] )
					delCommand( parameter, $1 )
				else
					delHelp( parameter )
				end

			elsif ( parameter.message[ /^!undel( .*)?$/ ] )
				if ( parameter.message[ /^!undel (\d+)$/ ] )
					undelCommand( parameter, $1 )
				else
					undelHelp( parameter )
				end
				
			elsif ( parameter.message[ /^!rename( .*)?$/ ] )				
				if ( parameter.message[ /^!rename (\d+) ([^ ]+) ([^ ]+)$/ ] )
					renameCommand( parameter, $1, $2, $3 )
				else
					renameHelp( parameter )
				end
				
			elsif ( parameter.message[ /^!alias( .*)?$/ ] )				
				if ( parameter.message[ /^!alias ([^ ]+) ([^ ]+)$/ ] )
					aliasCommand( parameter, $1, $2 )
				else
					aliasHelp( parameter )
				end
				
			elsif ( parameter.message[ /^!delalias( .*)?$/ ] )
				if ( parameter.message[ /^!delalias ([^ ]+)$/ ] )
					delAliasCommand( parameter, $1 )
				else
					delAliasHelp( parameter )
				end
					
			end					
		end
		
		
		# id = :eventPrivMsg
		# sender = Server (@irc)
		# type = :event_type_before / :event_type_after
		# parameter = JoinEvent
		def joinChan( id, sender, type, parameter )
			return if ( type == :event_type_before )
			return if ( parameter.source == sender.myClient )
			
			sleep( 0.5 )

			listed = 0
			name = getAliasedName( parameter.source.name )
			
			@matches.each { |match|					
				next if ( match.deleted )
				
				date = getDateString( match.date )
				
				comment = ""
				comment = " :: #{match.comment}" if ( match.comment != nil && match.comment.length > 0 )
				
				yes = "3#{match.yes.length}"
				maybe = "7#{match.maybe.length}"
				no = "4#{match.no.length}"
				
				if ( match.yes.include? name )
					signed = "3available"						
				elsif ( match.maybe.include? name )
					signed = "7maybe"						
				elsif ( match.no.include? name )
					signed = "4unavailable"					
				else
					signed = "unsigned"						
				end					
				
				sendNotice( parameter.server, parameter.source, "[Info] #{match.id}: #{date} AMS :: #{match.gametype} vs #{match.team}#{comment} :: #{yes}/#{maybe}/#{no} :: Signed as #{signed}." )
				listed = listed + 1
			}

			if ( listed == 0 )
				sendNotice( parameter.server, parameter.source, "[Info] No matches." )
			end
		end
		
		
		private
		def sendNotice( server, to, message )
			server.send( Kesh::IRC::Commands::NoticeMsgCommand.new( to, message ) )
		end
		
		
		def sendMessage( server, to, message )
			server.send( Kesh::IRC::Commands::PrivMsgCommand.new( to, message ) )
		end
		
		
		def help( privMsgEvent )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Help] Available commands: !add !yes !maybe !no !unsign !list !info !update !result !updateresult !delresult !del !undel !rename !alias !delalias - Use !help <command> for more information." )
		end
		
		
		def helpCommand( privMsgEvent, command )
			if ( command == "add" )
				addHelp( privMsgEvent )
				
			elsif ( command == "yes" || command == "maybe" || command == "no" || command == "unsign" )
				signupHelp( privMsgEvent )
				
			elsif ( command == "rename" )
				renameHelp( privMsgEvent )
				
			elsif ( command == "alias" )
				aliasHelp( privMsgEvent )
				
			elsif ( command == "delalias" )
				delAliasHelp( privMsgEvent )
				
			elsif ( command == "list" )
				listHelp( privMsgEvent )
				
			elsif ( command == "info" )
				listHelp( privMsgEvent )
				
			elsif ( command == "update" )
				listHelp( privMsgEvent )
				
			elsif ( command == "result" )
				resultHelp( privMsgEvent )
				
			elsif ( command == "updateresult" )
				updateResultHelp( privMsgEvent )
				
			elsif ( command == "delresult" )
				delResultHelp( privMsgEvent )
				
			elsif ( command == "del" )
				delHelp( privMsgEvent )
				
			elsif ( command == "undel" )
				undelHelp( privMsgEvent )
				
			else
				sendNotice( privMsgEvent.server, privMsgEvent.source, "[Help] Unknown command.  Use !help for a list of commands." )
				
			end				
		end				
		
		
		def addHelp( privMsgEvent )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Help] !add <dd/mm/yy> <hh:mm> <gametype> <team> [comment] - Add a new match.  AMS times!" )
		end
		
		
		def signupHelp( privMsgEvent )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Help] !(yes|maybe|no|unsign) <id> [name] - Set yourself as available, maybe, unavailable or unsign for a match.  If you include a name, that name will be used instead of your IRC nick. For a list of ids, use !list or rejoin the channel." )
		end
		
		
		def listHelp( privMsgEvent )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Help] !list [unsigned] [name] - List the upcoming matches.  If you include 'unsigned', it will only show the matches you aren't signed up for.  If you include a name, that name will be used instead of your IRC nick to check for availability." )
		end
		
		
		def infoHelp( privMsgEvent )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Help] !info <id> [name] - Get information about a match.  Includes lists of players that are signed up.  If you include a name, that name will be used instead of your IRC nick to check for availability." )
		end
		
		
		def updateHelp( privMsgEvent )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Help] !update <id> <property> [value] - Update the information in a match.  You can update: date, team, gametype and comment." )
		end
		
		
		def resultHelp( privMsgEvent )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Help] !result <id> <map> <ourteam> <ourscore> <theirscore> [comment] - Add a map result for a match.  Repeat once for each map." )
		end
		
		
		def updateResultHelp( privMsgEvent )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Help] !updateresult <matchid> <resultid> <property> [value]- Update the information in a result.  You can update: map, team, ourscore, theirscore and comment." )
		end
		
		
		def delResultHelp( privMsgEvent )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Help] !delresult <matchid> <resultid> - Permanently delete this result from a match." )
		end
		
		
		def delHelp( privMsgEvent )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Help] !del <id> - Remove a match from the list.  Add results before removing.  Matches removed without results will not be saved!" )
		end
		
		
		def undelHelp( privMsgEvent )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Help] !undel <id> - Restores a deleted match to the active list." )
		end
		
		
		def renameHelp( privMsgEvent )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Help] !rename <id> <from> <to> - Changes the name of a somebody already signed up to a match.  Use if you signed up with the wrong name by mistake." )
		end
		
		
		def aliasHelp( privMsgEvent )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Help] !alias <master> <slave> - Adds an alias to the bot.  Aliases will automatically change your name from your current irc nick to another name." )
		end
		
		
		def delAliasHelp( privMsgEvent )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Help] !delalias <slave> - Removes an alias to the bot.  Aliases will automatically change your name from your current irc nick to another name." )
		end
		
		
		def parseDate( privMsgEvent, string )
			if ( string[ /^(\d+)\/(\d+)\/(\d+) (\d+):(\d+)$/ ] == nil )
				sendNotice( privMsgEvent.server, privMsgEvent.source, "[Error] Unable to parse date.  Please use the following format: <dd/mm/yy> <hh:mm>." ) if ( privMsgEvent != nil )
				return nil
			end
			
			begin
				return DateTime.civil( 2000 + $3.to_i, $2.to_i, $1.to_i, $4.to_i, $5.to_i )
				
			rescue => ex
				sendNotice( privMsgEvent.server, privMsgEvent.source, "[Error] Unable to instantiate date." ) if ( privMsgEvent != nil )
				return nil
			end
		end
		
		
		def getMatchIndex( privMsgEvent, token )
			matchId = token.to_i
			
			# Find matchId
			@matches.each_index { |i|
				return i if ( @matches[ i ].id == matchId )
			}
			
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Error] Match id doesn't exist." ) if ( privMsgEvent != nil )
			return -1
		end
		
		
		def getResultIndex( privMsgEvent, matchIndex, token )		
			if ( token[ /^\d+$/ ] == nil )
				sendNotice( privMsgEvent.server, privMsgEvent.source, "[Error] Invalid result id." ) if ( privMsgEvent != nil )
				return -1
			end
			
			resultIndex = token.to_i - 1			
			return resultIndex if ( @matches[ matchIndex ].results[ resultIndex ] != nil )
			
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Error] Result id doesn't exist." ) if ( privMsgEvent != nil )
			return -1
		end
		
		
		def getDateString( date )
			if ( date.strftime( '%d/%m/%y' ) == Date.today.strftime( '%d/%m/%y' ) )
				return date.strftime( 'Today %H:%M' )
				
			elsif ( ( date - 1 ).strftime( '%d/%m/%y' ) == Date.today.strftime( '%d/%m/%y' ) )
				return date.strftime( 'Tomorrow %H:%M' )
			
			else
				return date.strftime( '%a %d/%m/%y %H:%M' )
			end
		end			
		
		
		def getAliasedName( name )
			@aliases.each_pair { |key, value|
				return value if ( key == name )
			}
			
			return name
		end
		
		
		def addCommand( privMsgEvent, dateString, gametype, team, comment )		
			date = parseDate( privMsgEvent, dateString )
			return if ( date == nil )
			
			match = Match.new( @nextId, date, team, gametype, comment, [], [], [], [], false )
			@matches.push( match )
			@nextId = @nextId + 1
			
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] New match id #{match.id} added!" )
			sendMessage( privMsgEvent.server, privMsgEvent.target, "[Match] New match id #{match.id} added!" )
			@sorter.sort( @matches )
			storeData()
		end
		
		
		def signupCommand( privMsgEvent, type, id, param )
			name = getAliasedName( ( param == nil ) ? privMsgEvent.source.name : param )
			index = getMatchIndex( privMsgEvent, id )
			
			if ( index == -1 )
				signupHelp( privMsgEvent )
				return nil
			end
				
			if ( type == "yes" )
				yesCommand( privMsgEvent, index, name, ( name != privMsgEvent.source.name ) )
			elsif ( type == "maybe" )
				maybeCommand( privMsgEvent, index, name, ( name != privMsgEvent.source.name ) )
			elsif ( type == "no" )
				noCommand( privMsgEvent, index, name, ( name != privMsgEvent.source.name ) )
			elsif ( type == "unsign" )
				unsignCommand( privMsgEvent, index, name, ( name != privMsgEvent.source.name ) )
			end
		end				
		
		
		def yesCommand( privMsgEvent, index, name, otherName )		
			if ( @matches[ index ].yes.include? name )
				sendNotice( privMsgEvent.server, privMsgEvent.source, "[Error] You are already set as available for that match." )
				return
			end
			
			@matches[ index ].yes.push( name )			
			@matches[ index ].maybe.delete( name )
			@matches[ index ].no.delete( name )
			
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Signed up as available." ) if ( !otherName )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Signed up as available, as #{name}." ) if ( otherName )
			storeData()
		end
		
		
		def maybeCommand( privMsgEvent, index, name, otherName )
			if ( @matches[ index ].maybe.include? name )
				sendNotice( privMsgEvent.server, privMsgEvent.source, "[Error] You are already set as maybe for that match." )
				return
			end
			
			@matches[ index ].maybe.push( name )			
			@matches[ index ].yes.delete( name )
			@matches[ index ].no.delete( name )
			
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Signed up as maybe." ) if ( !otherName )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Signed up as maybe, as #{name}." ) if ( otherName )
			storeData()
		end
		
		
		def noCommand( privMsgEvent, index, name, otherName )		
			if ( @matches[ index ].no.include? name )
				sendNotice( privMsgEvent.server, privMsgEvent.source, "[Error] You are already set as unavailable for that match." )
				return
			end
			
			@matches[ index ].no.push( name )			
			@matches[ index ].yes.delete( name )
			@matches[ index ].maybe.delete( name )
			
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Signed up as unavailable." ) if ( !otherName )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Signed up as unavailable, as #{name}." ) if ( otherName )
			storeData()
		end
		
		
		def unsignCommand( privMsgEvent, index, name, otherName )		
			signed = ( ( @matches[ index ].yes.include? name ) || ( @matches[ index ].maybe.include? name ) || ( @matches[ index ].no.include? name ) )
			
			# Find if they are signed up already
			if ( !signed )
				sendNotice( privMsgEvent.server, privMsgEvent.source, "[Error] You are not signed up for that match." )
				return
			end
			
			@matches[ index ].yes.delete( name )
			@matches[ index ].maybe.delete( name )
			@matches[ index ].no.delete( name )			
			
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Unsigned from the match." ) if ( !otherName )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Unsigned from the match as #{name}." ) if ( otherName )
			storeData()
		end
		
		
		def renameCommand( privMsgEvent, indexStr, from, to )
			index = getMatchIndex( privMsgEvent, indexStr )
			return if ( index == -1 )

			found = false			
			match = @matches[ index ]
			
			match.yes.each_index { |i|
				if ( match.yes[ i ] == from )
					match.yes[ i ] = to
					found = true
					break
				end
			}
			
			if ( !found )
				match.maybe.each_index { |i|
					if ( match.maybe[ i ] == from )
						match.maybe[ i ] = to
						found = true
						break
					end
				}
			end		
			
			if ( !found )
				match.no.each_index { |i|
					if ( match.no[ i ] == from )
						match.no[ i ] = to
						found = true
						break
					end
				}
			end
			
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Error] That person is not signed up for that match." ) if ( !found )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Sign-up changed." ) if ( found )
			storeData() if ( found )
		end
		
		
		def aliasCommand( privMsgEvent, master, slave )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Updated alias." ) if ( @aliases.has_key?( slave ) )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Alias added." ) if ( !@aliases.has_key?( slave ) )

			@aliases[ slave ] = master
			storeData()
			loadData()
			storeData()
		end
		
		
		def delAliasCommand( privMsgEvent, slave )
			if ( !@aliases.has_key?( slave ) )
				sendNotice( privMsgEvent.server, privMsgEvent.source, "[Error] Alias does not exist." )
				return
			end
			
			@aliases.delete( slave )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Updated removed." )
			
			storeData()
		end
			
		
		def listCommand( privMsgEvent, publicResponse, param1, param2 )				
			if ( publicResponse )
				publicResponse = publicResponse && ( privMsgEvent.target.name.start_with? "#" )
			end
			
			unsigned = false
			name = privMsgEvent.source.name
			
			unsigned = true if ( param1 == 'unsigned' || param2 == 'unsigned' )
			name = param1 if ( param1 != nil && param1 != 'unsigned' )
			name = param2 if ( param2 != nil && param2 != 'unsigned' )
			
			listed = 0
			
			@matches.each { |match|
				next if ( match.deleted )
				
				if ( match.yes.include? name )
					signed = "3available"						
				elsif ( match.maybe.include? name )
					signed = "7maybe"						
				elsif ( match.no.include? name )
					signed = "4unavailable"					
				else
					signed = "unsigned"						
				end
				
				next if ( unsigned && signed != "unsigned" )

				date = getDateString( match.date )
				
				comment = ""
				comment = " :: #{match.comment}" if ( match.comment != nil && match.comment.length > 0 )
				
				yes = "3#{match.yes.length}"
				maybe = "7#{match.maybe.length}"
				no = "4#{match.no.length}"
				
				played = ""
				played = " :: #{match.results.length} map(s) played" if ( match.results.length > 0 )
				
				if ( publicResponse )
					sendMessage( privMsgEvent.server, privMsgEvent.target, "[Info] #{match.id}: #{date} AMS :: #{match.gametype} vs #{match.team}#{comment}#{played} :: #{yes}/#{maybe}/#{no}" )
				else
					sendNotice( privMsgEvent.server, privMsgEvent.source, "[Info] #{match.id}: #{date} AMS :: #{match.gametype} vs #{match.team}#{comment}#{played} :: #{yes}/#{maybe}/#{no} :: Signed as #{signed}." )
				end
				
				listed = listed + 1
			}

			if ( listed == 0 )
				if ( publicResponse )
					sendMessage( privMsgEvent.server, privMsgEvent.target, "[Info] No matches." )
				else
					sendNotice( privMsgEvent.server, privMsgEvent.source, "[Info] No matches." )
				end
			end
		end
		
		
		def infoCommand( privMsgEvent, publicResponse, indexStr, nameParam )		
			if ( publicResponse )
				publicResponse = publicResponse && ( privMsgEvent.target.name.start_with? "#" )
			end

			name = privMsgEvent.source.name
			name = nameParam if ( nameParam != nil )

			index = getMatchIndex( privMsgEvent, indexStr )
			return if ( index == -1 )

			match = @matches[ index ]
			
			date = getDateString( match.date )
			
			comment = ""
			comment = " :: #{match.comment}" if ( match.comment != nil && match.comment.length > 0 )
			
			if ( match.yes.include? name )
				signed = "3available"						
			elsif ( match.maybe.include? name )
				signed = "7maybe"						
			elsif ( match.no.include? name )
				signed = "4unavailable"					
			else
				signed = "unsigned"						
			end
			
			signups = "3Yes (#{match.yes.length}): "
			signups << match.yes.join( ", " )
			
			signups << " 7Maybe (#{match.maybe.length}): "
			signups << match.maybe.join( ", " )
			
			signups << " 4No (#{match.no.length}): "
			signups << match.no.join( ", " )
			
			signups = "Nobody" if ( signups == "" )
			
			results = ""
			
			match.results.each_index { |ri|
				result = match.results[ ri ]
					
				results << " :: " if ( results != "" )
				
				comment = ""
				comment = " [#{result.comment}]" if ( result.comment != nil && result.comment.length > 0 )
				
				results << "#{ri+1}: #{result.map} (#{result.team}) #{result.ourscore}-#{result.theirscore}#{comment}"
			}
			
			if ( publicResponse )
				sendMessage( privMsgEvent.server, privMsgEvent.target, "[Info] #{match.id}: #{date} AMS :: #{match.gametype} vs #{match.team}#{comment}" )
				sendMessage( privMsgEvent.server, privMsgEvent.target, "[Info] #{match.id}: Signed up: #{signups}" )
			else
				sendNotice( privMsgEvent.server, privMsgEvent.source, "[Info] #{match.id}: #{date} AMS :: #{match.gametype} vs #{match.team}#{comment} :: Signed as #{signed}" )
				sendNotice( privMsgEvent.server, privMsgEvent.source, "[Info] #{match.id}: Signed up: #{signups}" )
			end
			
			if ( results != "" )
				if ( publicResponse )
					sendMessage( privMsgEvent.server, privMsgEvent.target, "[Info] #{match.id}: Results: #{results}" )
				else
					sendNotice( privMsgEvent.server, privMsgEvent.source, "[Info] #{match.id}: Results: #{results}" )
				end
			end
		end
		
		
		def updateCommand( privMsgEvent, indexStr, field, wordValue, stringValue )		
			index = getMatchIndex( privMsgEvent, indexStr )
			return if ( index == -1 )
			
			if ( field != "comment" && stringValue == nil )
				updateHelp( privMsgEvent )
				return
			end
			
			if ( field == "date" )
				date = parseDate( privMsgEvent, stringValue )
				return if ( date == nil )
				@matches[ index ].date = date
				@sorter.sort( @matches )
			
			elsif ( field == "team" )
				@matches[ index ].team = wordValue
				
			elsif ( field == "gametype" )
				@matches[ index ].gametype = wordValue
				
			elsif ( field == "comment" )
				@matches[ index ].comment = stringValue
				
			else
				sendNotice( privMsgEvent.server, privMsgEvent.source, "[Error] Unknown match property." )
				return
			end
			
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Updated." )
			storeData()
		end


		def resultCommand( privMsgEvent, indexStr, map, team, ourscore, theirscore, comment )		
			index = getMatchIndex( privMsgEvent, indexStr )
			return if ( index == -1 )
			
			@matches[ index ].results.push( Result.new( map, team, ourscore.to_i, theirscore.to_i, comment ) )

			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Result added." )
			storeData()
		end
		
		
		def updateResultCommand( privMsgEvent, matchIndexStr, resultIndexStr, field, wordValue, stringValue )		
			matchIndex = getMatchIndex( privMsgEvent, matchIndexStr )				
			return if ( matchIndex == -1 )
			
			resultIndex = getResultIndex( privMsgEvent, matchIndex, resultIndexStr )
			return if ( resultIndex == -1 )
			
			if ( field != "comment" && stringValue == nil )
				updateResultHelp( privMsgEvent )
				return
			end
			
			if ( field == "map" )
				@matches[ matchIndex ].results[ resultIndex ].map = wordValue
			
			elsif ( field == "team" )
				@matches[ matchIndex ].results[ resultIndex ].team = wordValue
				
			elsif ( field == "ourscore" )
				if ( wordValue[ /^(\d+)$/ ] == nil )
					sendNotice( privMsgEvent.server, privMsgEvent.source, "[Error] Our score must be numeric." )
					return
				end
				
				@matches[ matchIndex ].results[ resultIndex ].ourscore = wordValue.to_i
				
			elsif ( field == "theirscore" )
				if ( wordValue[ /^(\d+)$/ ] == nil )
					sendNotice( privMsgEvent.server, privMsgEvent.source, "[Error] Their score must be numeric." )
					return
				end
				
				@matches[ matchIndex ].results[ resultIndex ].theirscore = wordValue.to_i
				
			elsif ( field == "comment" )
				@matches[ matchIndex ].results[ resultIndex ].comment = stringValue

			else
				sendNotice( privMsgEvent.server, privMsgEvent.source, "[Error] Unknown result property." )
				return
			end
			
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Updated." )
			storeData()
		end
		
		
		def delResultCommand( privMsgEvent, matchIndexStr, resultIndexStr )		
			matchIndex = getMatchIndex( privMsgEvent, matchIndexStr )
			return if ( matchIndex == -1 )
			
			resultIndex = getResultIndex( privMsgEvent, matchIndex, resultIndexStr )
			return if ( resultIndex == -1 )
			
			@matches[ matchIndex ].results.delete_at( resultIndex )
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Result deleted." )
			storeData()
		end


		def delCommand( privMsgEvent, matchIndexStr )
			index = getMatchIndex( privMsgEvent, matchIndexStr )
			return if ( index == -1 )
			
			@matches[ index ].deleted = true
			
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Match marked as deleted." )
			storeData()
		end
		
		
		def undelCommand( privMsgEvent, matchIndexStr )
			index = getMatchIndex( privMsgEvent, matchIndexStr )				
			return if ( index == -1 )
			
			@matches[ index ].deleted = false
			
			sendNotice( privMsgEvent.server, privMsgEvent.source, "[Success] Match restored." )
			storeData()
		end
		
		
		def storeData()
			ini = Kesh::IO::Storage::IniFile.loadFromFile( 'matchbotdata.ini' )
			
			ini.removeSection( "Aliases" )
			ini.addSection( "Aliases" )
			
			@aliases.each_pair { |key, value|
				ini.setValue( "Aliases", key, value )
			}
			
			@matches.each { |match|
				idStr = match.id.to_s
				ini.removeSection( idStr )
				next if ( match.deleted && match.results.length == 0 )
				
				ini.setValue( idStr, 'Date', match.date.strftime( '%d/%m/%y %H:%M' ) )
				ini.setValue( idStr, 'Team', match.team )
				ini.setValue( idStr, 'GameType', match.gametype )
				ini.setValue( idStr, 'Comment', match.comment )
				ini.setValue( idStr, 'Yes', match.yes.join( " " ) )
				ini.setValue( idStr, 'Maybe', match.maybe.join( " " ) )
				ini.setValue( idStr, 'No', match.no.join( " " ) )
				ini.setValue( idStr, 'Deleted', match.deleted ? "Yes" : "No" )
				ini.setValue( idStr, 'ResultCount', match.results.length.to_s )
				
				match.results.each_index { |r|
					result = match.results[ r ]
					ini.setValue( idStr, 'Result' + r.to_s, "#{result.map} #{result.team} #{result.ourscore} #{result.theirscore} #{result.comment}" )
				}
			}
			
			FileUtils.cp( 'matchbotdata.ini', 'matchbotdata-old.ini' )
			ini.writeToFile( 'matchbotdata.ini' )
		end
		
		
		def loadData()
			@matches = []
			@aliases = Hash.new
			@nextId = 1
			
			ini = Kesh::IO::Storage::IniFile.loadFromFile( 'matchbotdata.ini' )
			
			aliasSection = ini.getSection( "Aliases" )
			
			aliasSection.values.each { |value|
				@aliases[ value.name ] = value.value
			}
			
			ini.sections.each { |section|
				next if ( section.name == "Aliases" )
				
				id = section.name
				
				if ( id[ /^\d+$/ ] == nil )
					puts "Invalid ID: " + id.to_s
					raise SyntaxError
				end
				
				idInt = id.to_i
				@nextId = ( idInt + 1 ) if ( idInt >= @nextId )
				
				deleted = section.getValue( 'Deleted' )
				next if ( deleted == "Yes" )

				date = parseDate( nil, section.getValue( 'Date' ) )
				
				if ( date == nil )
					puts "Invalid Date: " + section.getValue( 'Date' ).to_s
					raise SyntaxError
				end
				
				team = section.getValue( 'Team' )
				gametype = section.getValue( 'GameType' )
				comment = section.getValue( 'Comment' )
				yes = section.getValue( 'Yes' )
				maybe = section.getValue( 'Maybe' )
				no = section.getValue( 'No' )
				
				yes = yes.split( " " ) if ( yes != nil )
				yes = [] if ( yes == nil )
				
				yes.each_index { |i|
					yes[ i ] = getAliasedName( yes[ i ] )
				}
				
				maybe = maybe.split( " " ) if ( maybe != nil )
				maybe = [] if ( maybe == nil )

				maybe.each_index { |i|
					maybe[ i ] = getAliasedName( maybe[ i ] )
				}
				
				no = no.split( " " ) if ( no != nil )
				no = [] if ( no == nil )

				no.each_index { |i|
					no[ i ] = getAliasedName( no[ i ] )
				}
				
				results = []					
				resultCount = section.getValue( 'ResultCount' )
				
				if ( resultCount[ /^\d+$/ ] == nil )
					puts "Invalid Result Count: " + resultCount.to_s
					raise SyntaxError
				end
				
				rCount = resultCount.to_i
				rIndex = 0
				
				while ( rIndex < rCount )
					
					if ( section.getValue( 'Result' + rIndex.to_s )[ /^(\w+) (\w+) (\d+) (\d+)( (.*))?$/ ] == nil )
						puts "Invalid Result Line: " + section.getValue( 'Result' + rIndex.to_s ).to_s
						raise SyntaxError
					end
					
					rMap = $1
					rTeam = $2
					rOurScore = $3
					rTheirScore = $4
					rComment = $6

					if ( rOurScore[ /^\d+$/ ] == nil )
						puts "Invalid Ourscore: " + rOurScore.to_s
						raise SyntaxError
					end

					if ( rTheirScore [ /^\d+$/ ] == nil )
						puts "Invalid Theirscore: " + rTheirScore.to_s
						raise SyntaxError
					end
					
					results.push( Result.new( rMap, rTeam, rOurScore.to_i, rTheirScore.to_i, rComment ) )
					
					rIndex = rIndex + 1
				end
				
				@matches.push( Match.new( idInt, date, team, gametype, comment, yes, maybe, no, results, false ) )												
			}
			
			@sorter.sort( @matches )
		end
		
	end
		
end
