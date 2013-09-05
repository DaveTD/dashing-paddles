require 'celluloid/autostart'

class GameSet
	include Celluloid

	attr_accessor :player1, :player2, :active_game, :id

	def initialize(p1, p2, server, id)
		@id = id
		@server = server
		@active_game = nil
		@player1 = p1
		@player2 = p2
		@player1.client.send("g:1")
		@player2.client.send("g:2")
		@towin = 3
		checkMatch
	end

	def checkMatch
		if @player1.wins < @towin and @player2.wins < @towin
			beginGame
		elsif @player1.wins >= @towin
			@player1.client.send("v")
			@player2.client.send("d")
			@server.finishGameSet(@id)
			self.terminate
		else
			@player2.client.send("v")
			@player1.client.send("d")
			@server.finishGameSet(@id)
			self.terminate
		end
	end

	def beginGame
		puts ">> Game commencing between players #{@player1.key} and #{@player2.key}" 
		@active_game = Game.new(self)
	end

	def playerwin(player)
		player == 1 ? @player1.win : @player2.win
		# puts ">> Score: #{@player1.wins} - #{@player2.wins}"
		@active_game.finish
	end

end
