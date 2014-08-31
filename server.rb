require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')
    yield(connection)
  ensure
    connection.close
  end
end

def get_data(query)
  db_connection do |conn|
    conn.exec(query)
  end
end

def get_data_with_id(query, id)
  db_connection do |conn|
    conn.exec(query, [id])
  end
end

get '/' do
  redirect '/recipes'
end

get '/recipes' do
  query = 'SELECT id, name FROM recipes
          ORDER BY name ASC'
  @recipe_names = get_data(query)
  erb :recipes
end

get '/recipes/:id' do
  id = params[:id]

  query = 'SELECT recipes.id, recipes.name AS name,
          recipes.description, recipes.instructions,
          ingredients.name AS ingredients
          FROM recipes LEFT OUTER JOIN ingredients
          ON recipes.id = ingredients.recipe_id
          WHERE recipes.id = $1'
  @recipe = get_data_with_id(query, id)
  erb :single_recipe
end
