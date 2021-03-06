require 'sinatra/base'
require './lib/user'
require './lib/listing'
require './lib/request'
require './lib/listings_dates'

class MakersBNB < Sinatra::Base
  set :method_override, true
  enable :sessions

  get '/' do
    # Sign-in page
    erb :sign_in_page
  end

  get '/:id/all_listings' do
    # Assign user to User object
    @user = User.retrieve(session[:id]) # Method not written yet
    # Assign listings to array of available listings...
    # @listings = Listing.retrieve_other(session[:id])
    requests = Request.available
    # available_requests = []
    # requests.each {|request|
    #    if request.user_id != @user.id
    #      available_requests.push(request)
    #    end
    # }
    @listings= requests.map {|request| Listing.retrieve_listing(request.listing_id)}
    # :listings view should pull User and Listings info and show on page
    erb :listings
  end

  get '/:id/my_listings' do
    @user = User.retrieve(session[:id])
    @user_listings = Listing.user_listings(session[:id])
    requests = Request.my_requests(@user.id)
    @my_requests = requests.map {|request| Listing.retrieve_listing(request.listing_id)}
    @available_dates = @user_listings.map { |listing| ListingsDates.return_dates(listing)}
    erb :my_listings
  end

  get '/:id/confirm_request' do
    @user = User.retrieve(session[:id])
    erb :confirm_request
  end

  get '/:id/approve' do
    @user = User.retrieve(session[:id])
    erb :confirm_approve
  end

  get '/:id/reject' do
    @user = User.retrieve(session[:id])
    erb :confirm_reject
  end

  post '/new_session' do
    # Authenticate User...
    user = User.authenticate(params[:username], params[:password])

    if user
      # If authentication successful, assign sesssion 'id' to this user's id.
      session[:id] = user.id
      redirect "/#{user.id}/all_listings"
    else
      # Otherwise, return to sign in page.
      redirect '/'
    end

  end

  patch '/:id/reject' do
    Request.reject(params[:request_id])
    redirect("/'#{params[:request_id]}'/reject")
  end

  patch '/:id/approve' do
    id = params[:request_id]
    Request.approve(id)
    redirect("/'#{params[:request_id]}'/approve")
  end

  patch '/:id/request' do
    params[:listing_id]
    user = User.retrieve(session[:id])
    listing = Listing.retrieve_listing(params[:listing_id])
    request = Request.make_request(params[:listing_id], user.id)
    # p Request.make_request(listing.id, user.id)
    redirect "/'#{listing.id}'/confirm_request"
  end

  post '/add_listing' do
    params[:date]
    listing = Listing.create(params[:name], session[:id], params[:description], params[:price])
    date = Dates.create(params[:date])
    ListingsDates.add_date((date.id).to_i, listing.id)

    redirect ("/#{session[:id]}/my_listings")
  end

  post '/new_user' do
    user = User.add(params[:new_username], params[:new_password])
    session[:id] = user.id
    redirect "/#{user.id}/my_listings"
  end

  run! if app_file == $0

end
