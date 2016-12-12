require 'sinatra'
require 'json'

require './lib/libconnect4'
require './dtos'
using LibConnect4Dtos

set :public_folder, "public"
enable :static

before do
    content_type "application/json"
end

get "/" do
    content_type "html"
    redirect "/index.html"
end


def run_ai_move(game, ai)
end

get '/api/game/new' do
    game = LibConnect4::Game.new   
    ai = LibConnect4::AI_Player.new(LibConnect4::Black)
    ai_move = ai.decide_next_move game.board
    game.move(ai.my_color, ai_move)
    {
        game: game.to_h,
        ai: ai.to_h
    }.to_json
end

post '/api/game/move' do 
    # Read JSON in from request
    request_body = request.body.read
    game_and_move = JSON.parse(request_body)
    game = LibConnect4::Game.from_json game_and_move["game"]
    move = game_and_move["move"]

    # Apply player move
    game.move(LibConnect4::Red, move)

    # If the player didn't already win, then get and apply the AI move
    if game.winner == nil then
        ai = LibConnect4::AI_Player.from_json game_and_move["ai"]
        ai_move = ai.decide_next_move game.board
        puts "Move #{if ai.my_color.is_a? Symbol then ":" else "" end}#{ai.my_color} to #{ai_move}"
        game.move(ai.my_color, ai_move)
    end

    # Return the result
    {
        game: game.to_h,
        ai: ai.to_h
    }.to_json
end
