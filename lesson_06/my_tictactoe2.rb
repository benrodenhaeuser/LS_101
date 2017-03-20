require 'yaml'
MESSAGES = YAML.load_file('./my_tictactoe_config2.yml')

# it would be nicer if we just had players, moves, choices, and lines.
# then build the two hashes from these data.

PLAYERS = [:user, :computer]
LEGAL_MOVES = (1..9)

# USER_CHOICES = [ ... ]

WINNING_LINES = [
  [1, 2, 3], [4, 5, 6], [7, 8, 9], # winning rows
  [1, 4, 7], [2, 5, 8], [3, 6, 9], # winning columns
  [1, 5, 9], [3, 5, 7]             # winning diagonals
]

# moves_to_user_choices = ...
# user_choices_to_moves = moves_to_user_choices_invert

# the next two hashes are then redundant:
MOVES_TO_USER_CHOICES = {
  1 => 'TL', 2 => 'TM', 3 => 'TR',
  4 => 'ML', 5 => 'MM', 6 => 'MR',
  7 => 'BL', 8 => 'BM', 9 => 'BR'
}
USER_CHOICES_TO_MOVES = MOVES_TO_USER_CHOICES.invert

# USER INTERFACE

def prompt(message, subst = {})
  message = MESSAGES[message] % subst
  puts "=> #{message}"
end

def welcome_the_user
  prompt('welcome')
  prompt('explain_board')
  prompt('explain_moves')
end

def toss_a_coin
  prompt('explain_cointoss')
  prompt('please_press_enter')
  print '   '
  gets
  sleep 0.5
end

def announce_who_begins(player)
  case player
  when :computer then prompt('computer_begins')
  when :user then prompt('user_begins')
  end
  sleep 0.3
end

def display(board)
  pretty_board = convert_for_output(board)

  puts
  puts "    #{pretty_board[1]} | #{pretty_board[2]} | #{pretty_board[3]} "
  puts "   -----------"
  puts "    #{pretty_board[4]} | #{pretty_board[5]} | #{pretty_board[6]} "
  puts "   -----------"
  puts "    #{pretty_board[7]} | #{pretty_board[8]} | #{pretty_board[9]} "
  puts
end

def convert_for_output(board)
  pretty_board = {}
  board.each do |key, _|
    case board[key]
    when false     then pretty_board[key] = ' '
    when :computer then pretty_board[key] = 'C'
    when :user     then pretty_board[key] = 'Y'
    end
  end
  pretty_board
end

def request_user_choice(board)
  loop do
    prompt('request_choice', { choices: joinor(available_choices(board)) })
    print '   '
    user_choice = gets.chomp.upcase
    if available_choices(board).include?(user_choice)
      return user_choice
    end
    prompt('invalid_choice')
  end
end

def available_choices(board)
  available_moves(board).map { |move| MOVES_TO_USER_CHOICES[move] }
end

def joinor(array, delimiter = ',', joinword = 'or')
  string = array[0].clone
  index = 1
  while index < array.size - 1
    string << "#{delimiter} #{array[index]}"
    index += 1
  end
  if array.size > 1
    string << "#{delimiter} #{joinword} #{array[array.size - 1]}"
  end
  string
end

def parrot(player, move)
  move_as_choice = MOVES_TO_USER_CHOICES[move]
  case player
  when :computer then prompt('computer_chose', { move: move_as_choice })
  when :user then prompt('user_chose', { move: move_as_choice })
  end
end

def announce_winner(winner)
  case winner
  when :computer then prompt('computer_wins')
  when :user then prompt('user_wins')
  end
end

def user_wants_to_play_again?
  loop do
    prompt('another_game?')
    print '   '
    answer = gets.chomp
    if answer.upcase == 'Y'
      return true
    elsif answer.upcase == 'N'
      return false
    end
    prompt('invalid_choice')
  end
end

# INTERNAL GAME MECHANICS

def initialize_board
  board = {}
  LEGAL_MOVES.each { |move| board[move] = false }
  board
end

def available_moves(board)
  LEGAL_MOVES.select { |move| !board[move] }
end

def get_move(player, board)
  case player
  when :user then get_user_move(board)
  when :computer then get_computer_move(board)
  end
end

def get_computer_move(board)
  sleep 0.5
  available_moves(board).sample
end

def get_user_move(board)
  user_choice = request_user_choice(board)
  user_move = USER_CHOICES_TO_MOVES[user_choice]
end

def update(board, move, player)
  case player
  when :computer then board[move] = :computer
  when :user then board[move] = :user
  end
end

def winner?(board, player)
  WINNING_LINES.any? do |line|
    line.all? do |move|
      LEGAL_MOVES.select { |move| board[move] == player }.include?(move)
    end
  end
end

def full?(board)
  available_moves(board) == []
end

def switch(player)
  case player
  when :computer then :user
  when :user then :computer
  end
end

# game loop

loop do
  system "clear"
  board = initialize_board
  welcome_the_user
  display(board)
  toss_a_coin
  current_player = PLAYERS.sample
  announce_who_begins(current_player)

  loop do
    current_move = get_move(current_player, board)
    update(board, current_move, current_player)
    parrot(current_player, current_move)
    display(board)
    break announce_winner(current_player) if winner?(board, current_player)
    break prompt('its_a_tie') if full?(board)
    current_player = switch(current_player)
  end

  break unless user_wants_to_play_again?
end

prompt('bye')