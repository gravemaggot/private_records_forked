class ApplicationController < Sinatra::Base
  register Sinatra::Namespace

  configure do
    set :views, 'app/views'
    set :public_folder, '/public'
  end
end