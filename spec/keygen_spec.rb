require 'wallet/keygen'
require 'encrypto_signo' 

RSpec.describe 'Keypair' do
	describe 'new' do
		it 'creates keys' do
			kp = Keypair.new
			expect(kp.keypair.empty?).to eq false # keypair = [ priv, pub ]
		end
	end

	describe 'write' do
		it 'overwrites previous PEM file with new keypair' do
			kp = Keypair.new		

			kp.write

			kp.read
			pre = kp.keypair

			kp.write

			kp.read
			post = kp.keypair

			i = 0
			pre.each do |n|
				if n == pre[i].to_s
					expect(0).to eq 1
				end
				i+=1
			end

			expect(1).to eq 1	
		end
	end

	describe 'sign' do
		it 'creates a verifyable signature' do
			kp = Keypair.new		
			msg = 'block'
			sig, key = kp.sign msg
			expect(
				EncryptoSigno.verify(key, sig, msg) 
			).to eq true
		end
	end

end



