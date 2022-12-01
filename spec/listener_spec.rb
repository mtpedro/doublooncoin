require 'mine/listen'

RSpec.describe 'Waiting_Room' do
	describe 'new' do
		it 'creates empty room' do
			waiting_room = Waiting_Room.new
			expect(waiting_room.status).to eq :empty
		end
		it 'creates a mutable room obj' do
			waiting_room = Waiting_Room.new
			waiting_room.enter( 'data' )
			expect(waiting_room.room).to eq [ 'data' ]
		end
		it 'room can clear' do
			waiting_room = Waiting_Room.new
			10.times { waiting_room.enter( 'data' ) }
			sleep(0.1)
			expect( waiting_room.room ).to eq []
		end
	end
end
