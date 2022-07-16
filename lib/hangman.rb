# frozen_string_literal: true

# Has method to show stick figure based on number of incorrect guesses
class StickFigure
  def initialize
    @stick_figure = [[' |--', 'o'],
                     [' | ', '/', '|', '\\'],
                     ['_|_', '/', ' \\']]
  end

  def show(incorrect_guesses)
    n = 0

    @stick_figure.each do |line|
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
  def initialize
    words = File.readlines('google-10000-english-no-swears.txt')
    words = words.select { |word| word.length.between?(5, 12) }
    @word = words.sample.chomp
    @guessed_letters = []
    @incorrect_letters = []
    @stick_figure = StickFigure.new
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

  def play
    while @incorrect_letters.length < 9
      @stick_figure.show(@incorrect_letters.length)
      puts "Incorrect letters: #{@incorrect_letters}"
      show_word
      guess_letter

      return win if win?
    end
    lose
  end

  private

  def guess_letter
    puts 'Please guess a letter.'
    letter = gets.chomp.downcase

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
    @stick_figure.show(@incorrect_letters.length)
    puts 'You lose!'
    puts "The word was \"#{@word}.\""
  end
end

game = Game.new
game.play
