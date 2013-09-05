require 'celluloid/autostart'

class Game
	include Celluloid
	
	attr_accessor :game_set, :finished, :p1paddle, :p2paddle, :gameball

	def initialize(game_set)
		@game_set = game_set
		@finished = nil
		@gameSizeX = 500
		@gameSizeY = 300
		@paddleSizeX = 15
		@paddleSizeY = 70
		@ballSize = 5
		@ballLocation = { :x => 250 , :y => 147.5 }
		@p1paddle = { :x => 15 , :y => 125 }
		@p2paddle = { :x => 470 , :y => 125 }
		@p1Speed = 0
		@p2Speed = 0
		@ballDirection = { :x => 1 , :y => 0 }
		@ballSpeed = 6 
		@maxBallSpeed = 14
		@maxBounceAngle = 5*Math::PI/12
		# puts ">> New game started"
		broadcast
		sleep(0.5)
		gameloop
	end

	def event(event)
	#	puts ">> Game received event: #{event} in the match between #{game_set.player1.key} and #{game_set.player2.key}"
		# Not secure at all. I know.
		if event[1] == 'u'
			changePlayerSpeed(event[0], -5)
		elsif event[1] == 'd'
			changePlayerSpeed(event[0], 5)
		elsif event[1] == 's'
			changePlayerSpeed(event[0], 0)
		end
	end

	def changePlayerSpeed(player, speed)
		player == "1" ? @p1Speed = speed : @p2Speed = speed
	end
	
	def finish
		@timer.terminate
		game_set.checkMatch
		self.terminate
	end

	def broadcast
		# There's a slight advantage to being player 1. I know.
		outputString = String.new
		outputString << "s"
		outputString << "#{@ballLocation[:x].round}"
		outputString << ","
		outputString << "#{@ballLocation[:y].round}"
		#outputString << ","
		#outputString << "#{@p1paddle[:x].round}"
		outputString << ","
		outputString << "#{@p1paddle[:y].round}"
		#outputString << ","
		#outputString << "#{@p2paddle[:x].round}"
		outputString << ","
		outputString << "#{@p2paddle[:y].round}"
		outputString << ","
		outputString << "#{@game_set.player1.wins}"
		outputString << ","
		outputString << "#{@game_set.player2.wins}"
		# puts outputString
		@game_set.player1.client.send("#{outputString}")
		@game_set.player2.client.send("#{outputString}")
	end

	def gameloop
		@timer = Timer.new(self)
		@timer.async.startTicking
	end

	def gameTick

		handlePlayerCollisions
		handleBallCollisions
		handleWinning
		moveBall
		movePlayers

		broadcast
	end

	def moveBall
		@ballLocation[:x] = @ballLocation[:x] + (@ballSpeed * @ballDirection[:x])
		@ballLocation[:y] = @ballLocation[:y] + (@ballSpeed * @ballDirection[:y])
	end

	def movePlayers
		@p1paddle[:y] = @p1paddle[:y] + @p1Speed
		@p2paddle[:y] = @p2paddle[:y] + @p2Speed
	end

	def handlePlayerCollisions
		if @p1paddle[:y] == 0 and @p1Speed < 0
			@p1Speed = 0
		end
		if @p1paddle[:y] == @gameSizeY - @paddleSizeY and @p1Speed > 0
			@p1Speed = 0
		end
		if @p2paddle[:y] == 0 and @p2Speed < 0
			@p2Speed = 0
		end
		if @p2paddle[:y] == @gameSizeY - @paddleSizeY and @p2Speed > 0
			@p2Speed = 0
		end	
	end

	def handleBallCollisions
		# Side collision, reflect angle
		if @ballLocation[:y] <= 0
			@ballDirection[:y] = @ballDirection[:y] * -1
		end

		if @ballLocation[:y] + @ballSize >= @gameSizeY
			@ballDirection[:y] = @ballDirection[:y] * -1
		end
	
		# find all important points...
		balltopright = { :x => @ballLocation[:x] + @ballSize, :y => @ballLocation[:y] }
		ballbottomleft = { :x => @ballLocation[:x] , :y => @ballLocation[:y] + @ballSize }
		ballbottomright = { :x => @ballLocation[:x] + @ballSize, :y => @ballLocation[:y] + @ballSize }

		p1topright = { :x => @p1paddle[:x] + @paddleSizeX, :y => @p1paddle[:y] }
		p1bottomleft = { :x => @p1paddle[:x] , :y => @p1paddle[:y] + @paddleSizeY }
		p1bottomright = { :x => @p1paddle[:x] + @paddleSizeX, :y => @p1paddle[:y] + @paddleSizeY }

		p2topright = { :x => @p2paddle[:x] + @paddleSizeX, :y => @p2paddle[:y] }
		p2bottomleft = { :x => @p2paddle[:x] , :y => @p2paddle[:y] + @paddleSizeY }
		p2bottomright = { :x => @p2paddle[:x] + @paddleSizeX, :y => @p2paddle[:y] + @paddleSizeY }

		# determine if any corner of the ball is inside or touching the paddle for p1
		if (@ballLocation[:x].between?(p1bottomleft[:x], p1bottomright[:x]) and @ballLocation[:y].between?(p1topright[:y], p1bottomright[:y])) or (balltopright[:x].between?(p1bottomleft[:x], p1bottomright[:x]) and balltopright[:y].between?(@p1paddle[:y], p1bottomleft[:y])) or (ballbottomleft[:x].between?(@p1paddle[:x], p1topright[:x]) and ballbottomleft[:y].between?(p1topright[:y], p1bottomright[:y])) or (ballbottomright[:x].between?(@p1paddle[:x], p1topright[:x]) and ballbottomright[:y].between?(@p1paddle[:y], p1bottomleft[:y]))

			@ballLocation[:x] = @p1paddle[:x] + @paddleSizeX + 5
			p1ymiddle = @p1paddle[:y] + (@paddleSizeY/2)
			ballymiddle = @ballLocation[:y] + (@ballSize/2)
			paddleballcollision(1, p1ymiddle, ballymiddle)
		
		end

		# determine if any corner of the ball is inside or touching the paddle for p2
		if (@ballLocation[:x].between?(p2bottomleft[:x], p2bottomright[:x]) and @ballLocation[:y].between?(p2topright[:y], p2bottomright[:y])) or (balltopright[:x].between?(p2bottomleft[:x], p2bottomright[:x]) and balltopright[:y].between?(@p2paddle[:y], p2bottomleft[:y])) or (ballbottomleft[:x].between?(@p2paddle[:x], p2topright[:x]) and ballbottomleft[:y].between?(p2topright[:y], p2bottomright[:y])) or (ballbottomright[:x].between?(@p2paddle[:x], p2topright[:x]) and ballbottomright[:y].between?(@p2paddle[:y], p2bottomleft[:y]))

			@ballLocation[:x] = @p2paddle[:x] - 5 - @ballSize
			p2ymiddle = @p2paddle[:y] + (@paddleSizeY/2)
			ballymiddle = @ballLocation[:y] + (@ballSize/2)
			paddleballcollision(2, p2ymiddle, ballymiddle)
			
		end	
	
	end

	def paddleballcollision(player, paddlemiddle, ballmiddle)
		# Where on the paddle did it hit, compared to the middle of the paddle?
		relativeIntersectPoint = paddlemiddle - ballmiddle

		# Make that a number between -1 and 1
		intersectpossible = @paddleSizeY + (2 * @ballSize)
		normalizedRelativeIntersectionY = (relativeIntersectPoint/(intersectpossible/2))

	        # Get an angle based on normalized value...
		bounceAngle = normalizedRelativeIntersectionY * @maxBounceAngle	
		
		# Switch direction based on player
		direction = player == 1 ? 1 : -1

		#calculate new direction...
		@ballDirection[:x] = Math.cos(bounceAngle) * direction
		@ballDirection[:y] = Math.sin(bounceAngle) * -1
		if @ballSpeed < @maxBallSpeed
			@ballSpeed = @ballSpeed + 1
		end
	end
	
	def handleWinning
		if @ballLocation[:x] < 0
			@game_set.playerwin(2)		
		end
		if @ballLocation[:x] + @ballSize > @gameSizeX
			@game_set.playerwin(1)
		end	
	
	end
end
