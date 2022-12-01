require_relative './miner.rb'

require 'net/ping' # checking internet connection 
require 'open-uri' # web scrapping API
require 'encrypto_signo' # verifying transactions 

# the Listener function will create a server on port 5000
# when a node connects, the node will transfer the block data to the listener.
# the data will be verified and if it is a transaction, it will be verified and mined
# in a block.

# upon a block reward, data will be passed to the peer class, which will then
# send the mined block to other nodes. 

class Listener
	def initialize

		wr = Waiting_Room.new
		
		ex_ip, status = interner_check
		if status != true 
			return 0
		end

		server = TCPServer.new ex_ip, 5000

		loop do
			Thread.start(server.accept) do |client|
				handle(client)
			end
		end

	end
	
	private

	def handle(client) # handles client + verifies transactions
		data = client.gets
		
		decomp = data.split('--') # see data structure at __END__

		if decomp[0] != 'TRANSACTION'
			return 0
		end

		decomp.each {|p| p.gsub(/[^[:lower:]]+/, "").delete('_')}	# delete capitals + underscore
		
		msg = String.new
		decomp[1..4].each do |str|
			msg << str
		end

		# verify
		ver = EncryptoSigno.verify(decomp[1], decomp[5], msg) 
 		
		if ver != false
			return 0
		end
		
		# add sig to transaction
		msg << decomp[5]
		
		#enter waiting room
		wr.enter(msg)
	end

	def peer # peer function for sending mined blocks to other nodes. 
	end

	def interner_check # check internet and respond with IP or nil
		
		dm = ->(name) { Net::Ping::TCP.new("https://www.#{name}.com/", 22, 5) }

		amazon = dm.call("amazon")
		google = dm.call("google")

		if google || amazon 
			ip = String.new
			URI.open("http://whatismyip.akamai.com") {|f|
				f.each_line {|line| ip << line}
			}
			return ip, true
		else 
			return nil, false # if neither google, nor amazon is online, internet is down.
		end

	end
end

class Waiting_Room
	attr_accessor :status, :room

	# problem: the server will always be listening for transactions, even when mining. This 
	# problematic as The miner won't be able to do anything with the transactions, because it
	# is mining. because there are many concurrent threads, it is difficult to coordinate when
	# to listen and when not to.

  # solution: create a waiting room. The waiting room will have a capacity of 10. when it is
	# full, the @status variable will be set to :full. when the waiting room is full, the 
	# handler() function will automatically return 0.
		
	def initialize
		@status = :empty
		@room = Array.new
		Thread.new { watchdog }		
	end

	def enter( data )
		if :status != :full
			@room << data
		end
	end

	private	

	def watchdog # this will keep track of when the 'room' is full.
		loop do
			if @room.length >= 10 
				@status = :full
				pass( @room ) # wait until pass function returns until @status becoms empty	
				@room.clear # empties waiting room
				@status = :empty
			end
			sleep 0.01
		end
	end

	def pass( room ) # pass block data to mining functions
		miner = Miner.new
		
		# 'squash' array into one element
		block = String.new
		room.each {|element| block << element }

		miner.hash( block ) 

		return 1 # return intager to watchdog function
	end
end 

__END__

data structure for transaction:

TRANSACTION--
FROM_michaelmorbius--
TO_batman--
AMMOUNT_69--
ID_1000
SIG_morb--


data structure for block 

BLOCK--
ID_10--
DISCOVERED_hugey--
TRANSACTION--
FROM_michaelmorbius--
TO_batman--
SIG_morb--
AMMOUNT_69--
ID_1000k
