require 'open-uri'
require 'json'

def generate_grid(grid_size)
  # TODO: generate random grid of letters
  ret = []
  grid_size.times do
    ret << ('A'..'Z').to_a.sample
  end
  ret
end

def translate(word)
  url = "https://api-platform.systran.net/translation/text/translate"
  url += "?source=en&target=fr&key=932da125-597e-4e74-9880-a493b54567d7&input=#{word}"
  user_serialized = open(url).read
  translation = JSON.parse(user_serialized)
  translation['outputs'][0]['output']
end

def run_game(attempt, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result
  grid_copy = grid.clone
  in_grid = attempt.upcase.split('').all? do |l|
    !grid_copy.delete(l).nil?
  end
  t = end_time - start_time
  return { time: t, translation: nil, score: 0, message: 'not in the grid' } unless in_grid
  translation = translate(attempt)
  return { time: t, translation: nil, score: 0, message: 'not an english word' } if translation == attempt
  score = 100 * attempt.length.to_f / t
  return { time: end_time - start_time, translation: translation, score: score, message: 'well done' }
end


class WordsController < ApplicationController
  def game
    @grid = generate_grid(16)
    @start_time = Time.now.to_i

  end

  def score
    @attempt = params[:attempt]
    @grid = params[:grid].split(' ')
    @start_time = Time.at(params[:start_time].to_i)
    puts @start_time
    @result = run_game(@attempt, @grid, @start_time, Time.now)
  end
end
