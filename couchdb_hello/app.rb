require 'rubygems'
require 'sinatra'
require 'couchrest'

def db
  CouchRest.database!('http://127.0.0.1:5984/play')
end

get '/' do
  @gists = db.view('all/all')['rows']
  erb :index
end

post '/' do
  id = params[:id]
  db.save_doc({
    '_id' => id,
    'gist_id' => id
  })
  redirect '/'
end