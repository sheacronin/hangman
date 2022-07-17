# frozen_string_literal: true

require 'json'

# Has method to show stick figure based on number of incorrect guesses
module StickFigure
  STICK_FIGURE = [[' |--', 'o'],
                  [' | ', '/', '|', '\\'],
                  ['_|_', '/', ' \\']].freeze

  def show_stick_figure(incorrect_guesses)
    n = 0

    STICK_FIGURE.each do |line|
      print "\n"
      line.each do |part|
        n += 1
        break if n > incorrect_guesses

        print part
      end
    end
    print "\n"
  end
end

# Handles the logic of the hangman game
class Game
  include StickFigure

  def initialize(word = generate_word, guessed_letters = [], incorrect_letters = [])
    @word = word
    @guessed_letters = guessed_letters
    @incorrect_letters = incorrect_letters
  end

  def play
    while @incorrect_letters.length < 9
      show_stick_figure(@incorrect_letters.length)
      puts "Incorrect letters: #{@incorrect_letters}"
      show_word
      guess_letter

      return win if win?
    end
    lose
  end

  def load
    puts 'Please enter your save file name, omitting the file extension.'
    filename = gets.chomp.downcase
    string = File.read("saved_games/#{filename}.json")
    data = JSON.parse string
    initialize(data['word'], data['guessed_letters'], data['incorrect_letters'])
    play
  end

  private

  def generate_word
    words = File.readlines('google-10000-english-no-swears.txt')
    words = words.select { |word| word.length.between?(5, 12) }
    words.sample.chomp
  end

  def show_word
    @word.split('').each do |letter|
      if @guessed_letters.include?(letter)
        print " #{letter} "
      else
        print ' _ '
      end
    end
    print "\n"
  end

  def guess_letter
    puts 'Please guess a letter or type "save" to save your game.'
    letter = gets.chomp.downcase

    save if letter == 'save'

    return guess_letter unless valid_letter?(letter)

    if @word.split('').include?(letter)
      add_letter(letter, @guessed_letters)
    else
      add_letter(letter, @incorrect_letters)
    end
  end

  def valid_letter?(letter)
    unless letter.length == 1
      puts 'Please enter a single letter.'
      return false
    end
    unless letter.match?(/[a-z]/)
      puts 'Please enter a valid letter.'
      return false
    end
    true
  end

  def add_letter(letter, letters_array)
    if letters_array.include?(letter)
      puts "You've already guessed the letter #{letter}!"
      return guess_letter
    end
    letters_array.push(letter)
  end

  def win?
    (@word.split('').uniq - @guessed_letters).length.zero?
  end

  def win
    show_word
    puts 'You win!'
  end

  def lose
    show_stick_figure(@incorrect_letters.length)
    puts 'You lose!'
    puts "The word was \"#{@word}.\""
  end

  def save
    Dir.mkdir('saved_games') unless Dir.exist?('saved_games')

    random_words = "#{generate_word}_#{generate_word}"
    puts "Please write down your save file name \"#{random_words}\" to remember it."

    File.open("saved_games/#{random_words}.json", 'w') do |file|
      file.puts JSON.dump({
                            word: @word,
                            guessed_letters: @guessed_letters,
                            incorrect_letters: @incorrect_letters
                          })
    end
  end
end

game = Game.new
puts 'Type LOAD if you would like to load a game. Otherwise, enter anything to begin a new game.'
load_or_new = gets.chomp.upcase
load_or_new == 'LOAD' ? game.load : game.play
