require 'openssl' # generate keypair
require 'encrypto_signo' # sign w/ pub key

class Keypair 
	attr_accessor :keypair
	def initialize()
		rsa_key = OpenSSL::PKey::RSA.new(512) # create asymetric encryption private key
		@keypair = encrypt_keypair(rsa_key)
	end

	def read		
		path_to_key = find_keys

		pub_path = path_to_key + 'public_key.pem'
		priv_path = path_to_key + 'private_key.pem'
		
		readpem = ->(fname) { OpenSSL::PKey::RSA.new(File.read(fname)) } # lambda for reading file 

		return readpem.call(pub_path), readpem.call(priv_path) # return pub, priv
	end
	
	def write
		path_to_key = find_keys

		pub_path = path_to_key + 'public_key.pem'
		priv_path = path_to_key + 'private_key.pem'
		
		File.open(priv_path, "w") { |f| f.write @keypair[0].to_s }
		File.open(pub_path, "w") { |f| f.write @keypair[1].to_s }
	end

	def sign(str)
		pub, priv = read() # read public .PEM
		signature = EncryptoSigno.sign(priv, str) 
		return signature, pub
	end
	
	private

	def encrypt_keypair(rsa_key)
		priv = rsa_key
		pub = rsa_key.public_key # public key from private key

		# encryption

		return priv, pub
	end

	def find_keys
		back = ''

		loop do
			folder = File.expand_path(back, Dir.pwd).split('/')[-1] # current folder 
			back << '../'
			
			folder == 'doublooncoin' ? break : 0
		end
		
		return File.expand_path(back, Dir.pwd) + '/doublooncoin/lib/wallet/keys/'
	end
end

__END__

TODO: 
	
 * symetrically encrypt public keys so that they dont take up as much space.
 * read method
 * write method
 * change '/' to '/' && '\' for windows suppport in find_keys method
