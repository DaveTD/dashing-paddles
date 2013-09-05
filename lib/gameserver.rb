require 'rubame'

class Gameserver

	@@LISTENER = 8443

	def initialize
		puts ">> Opening game server on port #{@@LISTENER}"
		@waitQueue = Array.new
		@gameList = Array.new
		@idcounter = 0
		listen
	end

	def listen
		server = Rubame::Server.new("0.0.0.0", @@LISTENER)
		while true
			server.run do |client|
				client.onopen do
		        	end
				client.onmessage do |mess|
					handle(mess, client)
		        	end
				client.onclose do
					@waitQueue.each do |player|
						if player.client == client
							@waitQueue.delete(player)
							puts "Removed closed client from wait queue"
						end
					end
		        	end
			end
		end
	end

	def handle(mess, client)
		key = extractAcceptHeader(client.handshake)
		if mess.chars.first == 'g'
			client.send "p:#{key}"
			@waitQueue << Player.new(key, client)
			checkForNewGame
		elsif mess.chars.first == 'c'
			#there has to be a more efficient way of doing this
			# puts ">> #{key} says: #{mess}"
			@gameList.each do |game|
				if game.player1.key == key || game.player2.key == key
					#puts "player #{key}: #{mess}"
					begin
						cmd = mess[2]
						if game.player1.key == key
							game.active_game.event("1#{cmd}")
						else
							game.active_game.event("2#{cmd}")
						end
					rescue
						puts ">> Tried sending a user message to a dead actor"
					end
					break
				end
			end
		elsif mess.chars.first == 'q'
			@waitQueue.each do |player|
				if player.client == client
					@waitQueue.delete(player)
					puts "Removed coward from the wait queue"
				end
			end
		else
			client.send "Error: Unacceptable message sent."
		end

	end

	def extractAcceptHeader(handshake)
		#If I had more time, I'd secure this and use secure sockets, but I don't, so I won't
		#Please, please don't use this in production ever
		return handshake.headers["sec-websocket-key"]
	end

	def checkForNewGame
		if @waitQueue.size >= 2
			#There's going to be a limit to this id counter size
			@idcounter = @idcounter + 1
			@gameList << GameSet.new(@waitQueue.pop, @waitQueue.pop, self, @idcounter)
		end
		puts ">> Wait queue: #{@waitQueue.size}"
	end

	def finishGameSet(finishedGame)
		@gameList.delete_if { |game| game.id == finishedGame }
	end

end
