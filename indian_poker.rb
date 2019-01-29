# https://www.rco.recruit.co.jp/career/engineer/entry/

class IndianPoker
  def initialize(player_hands, min:, max:)
    @players = player_hands.keys
    @player_hands = player_hands
    @min = min
    @max = max
    @possible_hands = generate_possible_hands
  end

  def start
    result = []
    cur_player = @players.first
    loop do
      opponents = @players - [cur_player]
      opponent_hands = opponents.map { |op| @player_hands[op] }

      assumed_cur_player_hand = assume_hand_from_possible_hands(cur_player, opponent_hands)
      result << "#{cur_player} => #{assumed_cur_player_hand}"
      if assumed_cur_player_hand == '?'
        update_possible_hands(opponents)
        cur_player = next_player(cur_player)
      else
        break
      end
    end
    result.join(" ")
  end

  private

  def next_player(cur_player)
    cur_index = @players.index(cur_player)
    next_index = cur_index == (@players.length - 1) ? 0 : cur_index + 1
    @players[next_index]
  end

  def update_possible_hands(opponents)
    opponents.each do |opponent|
      @possible_hands[opponent].each do |possible_hand|
        another_player = (opponents - [opponent])[0]
        possible_hands = [possible_hand, @player_hands[another_player]]
        unless assume_hand_from_others(possible_hands) == '?'
          @possible_hands[opponent].delete(possible_hand)
        end
      end
    end
  end

  def assume_hand_from_possible_hands(player, opponent_hands)
    return 'MIN' if @possible_hands[player].all? { |hand| opponent_hands.all? { |op_hand| hand < op_hand } }
    return 'MAX' if @possible_hands[player].all? { |hand| opponent_hands.all? { |op_hand| hand > op_hand } }
    return 'MID' if @possible_hands[player].all? { |hand| opponent_hands.all? { |op_hand| (hand > op_hand && hand < @max) || (hand < op_hand && hand > @min) } }
    '?'
  end

  def assume_hand_from_others(opponent_hands)
    return 'MIN' if ([@max -1, @max] - opponent_hands).empty?
    return 'MID' if  ([@min, @max] - opponent_hands).empty?
    return 'MAX' if ([@min, @min + 1] - opponent_hands).empty?
    '?'
  end

  def generate_possible_hands
    @players.inject({}) do |possible_hands, cur_player|
      opponent_hands = @player_hands.values - [@player_hands[cur_player]]
      possible_hands[cur_player] = (@min..@max).to_a - opponent_hands
      possible_hands
    end
  end
end


user_hands = {
  a: 6,
  b: 1,
  c: 5
}

indian_poker = IndianPoker.new(user_hands, min: 1, max: 10)
p indian_poker.start

