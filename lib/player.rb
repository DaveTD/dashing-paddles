
class Player

	attr_accessor :key, :client, :wins

	def initialize(key, client)
		@key = key
		@client = client
		@wins = 0
		puts ">> Player connected: #{key}"
	end

	def win
		@wins = @wins + 1
	end

end
