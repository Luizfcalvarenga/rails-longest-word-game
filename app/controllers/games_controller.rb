require 'open-uri'
require 'json'
class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
    @start_time = Time.now
    session[:letters] = @letters
    session[:start_time] = @start_time
  end

  def score
    @guess = params[:guess]
    letters = session[:letters]
    start_time = Time.parse(session[:start_time])
    end_time = Time.now
    @result = run_game(@guess, letters, start_time, end_time)
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    if time_taken > 60.0
       0
    elsif time_taken < 60.0 && time_taken > 20.0
      attempt.size * (time_taken / 20)
    else
      attempt.size * (time_taken)
    end
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
    score_and_message(attempt, grid, (end_time - start_time))
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        @score = compute_score(attempt, time)
        "<strong>Congratulations!</strong> #{attempt} is a valid English word!".html_safe
      else
        @score = 0
        "Sorry but <strong>#{attempt}</strong> does not seen to be a valid english word...".html_safe
      end
    else
      @score = 0
      "Sorry but <strong>#{attempt}</strong> can't be built out of #{grid.join(',')}".html_safe
    end
  end

  def english_word?(word)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    grid = []
    alphabet = ('A'..'Z').to_a
    grid_size.times do
      grid << alphabet[rand(26)]
    end
    grid
  end
end
