require 'request'

describe Request do

  describe '.create' do
    it 'should create a request with a listing_id and requester_id' do
      user = User.add('username', 'password')
      listing = Listing.create('Holiday_Home', user.id)
      expect(Request.available).to include (listing)
    end
  end

  describe '.approve' do
    it 'should mark a request as approved' do
      user = User.add('username', 'password')
      listing = Listing.create('Holiday_Home', user.id)
      request = Request.return_request(listing.id)
      approval = Request.approve(request.id)
      expect(approval.id).to eq request.id
    end
  end

  describe '.my_requests' do
    it 'should return a request made on the users space' do
      user = User.add('username', 'password')
      user2 = User.add('user2', 'password')
      listing = Listing.create('Holiday_Home', user.id)
      request = Request.make_request(listing.id, user2.id)
      my_requests = Request.my_requests(user.id)
      expect(my_requests.first.id).to eq request.id
    end

    it 'should return many requests made on the users space' do

    end
  end

  describe '.return_request' do
    it 'returns a specific listing' do
      user = User.add('username', 'password')
      listing = Listing.create('Holiday_Home', user.id)
      request = Request.return_request(listing.id)
      expect(request.listing_id).to eq listing.id
    end
  end

  # describe '.retrieve_available' do
  #   it 'retrieves all unrequested  '
  # end

end
