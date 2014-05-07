$:.unshift "."
require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/flash'
require 'pl0_program'
require 'auth'
require 'pp'

enable :sessions
set :session_secret, '*&(^#234)'
set :reserved_words, %w{grammar test login auth logout favicon.jpg}
set :max_files, 3        # no more than max_files+1 will be saved per user

helpers do
  def current?(path='/')
    (request.path==path || request.path==path+'/') ? 'class = "current"' : ''
  end
end

get '/grammar' do
  erb :grammar
end

get '/test' do
  erb :test
end

# Raiz, sin usuario seleccionado
get '/' do
  # Si no existe el usuario se añade a lña base de datos
  # Truco: Hacer que los programas sean la lista actual de usuarios (o 10 aleatorios)
  # Escoger 10 usuarios aleatorios
  usuarios = User.all
  programs = []

  eux = 0
  length = usuarios.length
  if usuarios.length != 0
    while eux < length && eux < settings.max_files
      # Coger un usuario aleatorio y añadirlo a programas
      aux = usuarios.sample
      programs.concat([aux.username])
      usuarios.delete(aux)
      eux += 1
    end
  end
  
  source = "a = 3-2-1."
  erb :index, 
      :locals => { :programs => programs, :source => source, :user => "" }
end

get '/:user?/:file?' do |user, file|
  # Buscar y mostrar la lista de programas de un usuario
  aux = User.first(:username => user)

  if !aux
    flash[:notice] = 
      %Q{<div class="error">User "#{user}" not found. </div>}
    redirect to '/'
  end
  
  # Cargar programa del usuario deseado
  programs = aux.pl0programs
  c = programs.first(:name => file)
  
  if !c# Necesario, bug de Rubygems

    flash[:notice] = 
      %Q{<div class="error">File "#{file}" not found. </div>}
    redirect to '/'
  end

  # Cargar los datos para la página
  source = c.source

  erb :index, :locals => { :programs => programs, :source => source, :user => '/' + aux.username + '/' }
end

get '/:user?' do |user|    
  # Buscar programas de un usuario y mostrarlos en el menu
  aux = User.first(:username => user)

  if !aux
    flash[:notice] = 
      %Q{<div class="error">User "#{user}" not found.</div>}
    redirect to '/'
  end

  # Cargar los programas del usuario actual
  programs = aux.pl0programs
  source = ""

  erb :index, :locals => { :programs => programs, :source => source, :user => aux.username + '/' }
end

get '/:selected?' do |selected|
  # Buscar programas de un usuario y mostrarlos en el menu
  aux = User.first(:username => selected)
  puts aux
  if !aux
    flash[:notice] = 
      %Q{<div class="error">User "#{selected}" not found. </div>}
    redirect to '/'
  end

  # Cargar los programas del usuario actual
  programs = u.pl0programs

  c = programs[0]
  source = if c then c.source else "a = 3-2-1." end
  erb :index,  :locals => { :programs => programs, :source => source, :user => u.username }
end

post '/save' do
  pp params
  name = params[:fname]
  if session[:auth] # authenticated
    if settings.reserved_words.include? name  # check it on the client side
      flash[:notice] = 
        %Q{<div class="error">The file can't be save as '#{name}'.</div>}
      redirect back
    else
      # Comprobar si el usuario existe.
      puts "-> " + session[:email] + " <-"
      aux = User.first(:username => session[:email])
      if !aux
        # Si no existe, error fatal
        # u = User.create(:username => session[:email])
        # puts "-> Creando nuevo usuario ->  " + u.to_str
        flash[:notice] = 
          %Q{<div class="error">User '#{session[:email]}' not exist in the data base.</div>}
        redirect to '/'
      end
      pp aux

      # Crear un programa y asociar al usuario
      c  = aux.pl0programs.first(:name => name)
      if c
        c.source = params["input"]
        c.save
      else
        if Pl0program.all.size > settings.max_files
          c = Pl0program.all.sample
          c.destroy
        end
        c = Pl0program.create(:name => params["fname"], :source => params["input"])
        
        aux.pl0programs << c
      end
      
      # Guardar el usuario
      aux.save
      
      flash[:notice] = 
        %Q{<div class="success">File save as "#{c.name}" by "#{session[:name]}".</div>}
      # redirect to '/'+name
      redirect to '/' + aux.username + '/' + name 
    end
  else
    flash[:notice] = 
      %Q{<div class="success">You are not atenticated.<br />
         Log in with Google or Facebook.
         </div>}
    redirect back
  end
end

class String
  def name
    to_str
  end
end
