require 'omniauth'
require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
require 'omniauth-facebook'


use OmniAuth::Builder do
  config = YAML.load_file 'config/config.yml'
  provider :google_oauth2, config['identifier'], config['secret']
  provider :facebook, config['widentifier'], config['wsecret']
end

get '/auth/:name/callback' do
  session[:auth] = @auth = request.env['omniauth.auth']
  session[:name] = @auth['info'].name
  session[:image] = @auth['info'].image
  session[:email] = @auth['info'].email
  
  PP.pp @auth.methods.sort
  
  flash[:notice] = 
        %Q{<div class="success">Access grant as #{@auth['info'].email}.</div>}
  #Cuando un usuario se autentifica se añade a la base de datos
  if !User.first(:username => session[:email])
    aux = User.create(:username => session[:email])
    aux.save
  end
        
  redirect '/'
end

get '/auth/failure' do
  flash[:notice] = params[:message] 
  redirect '/'
end
