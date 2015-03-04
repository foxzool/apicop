require 'spec_helper'

describe APICop::API::Token do
  include Rack::Test::Methods

  def app
    APICop::API::Root
  end


  it 'POST /oauth/token' do
    post '/oauth/token'

    ap last_response.body
    expect(last_response.status).to eq(201)
  end
end
