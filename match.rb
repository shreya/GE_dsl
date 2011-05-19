require './pool'
require './question'
require './player'
require './inning'

# Match attibutes :name, :venue, :description, :scheduled_at, :keyword1, :keyword2, :keyword3, :keyword4,
#                 :pool_denomination, :start_pool_amount, :points_to_pool, :game_type, :state,
#                 :knockout, :shortcode, :number_of_rounds, :innings, :players, :pool


class Match
  
  MATCH_STATUS = {'Started' => 1, 'Ended' => 2, 'Abandoned' => 3}
  LEVEL_STATUS = {'Winner' => 1, 'Loser' => 2}
  STATUS = {'Winner' => 1, 'Loser' => 2}
  
  @@current_active_question = @@previous_active_question = @@current_active_inning = nil  
  attr_accessor :game_type, :players, :pool, :name, :start_pool_amount, :innings, :state
  
  
  def initialize(*args)
    args.each{ |arg| create_attr_accessor(arg)}
  end
  
    
  def self.build(game_type='', &block)
    m = Match.new
    m.game_type, m.players, m.innings, m.pool = game_type, [], [], Pool.new
    m.create_pool
    m.instance_eval(&block) if block_given?
    m
  end
  
  
  def inning(inning_number)
    innings[inning_number.to_i - 1]
  end
  
  
  def create_rounds
    number_of_rounds.to_i.times do
      innings << Inning.build(name)
    end    
    innings
  end
  
  
  def configure(hash="", &block)
    set_values(hash)
    create_rounds
    instance_eval(&block) if block_given?
  end
  
  
  def edit_pool
    set_values(hash)
  end
  
  
  def pool_configuration(hash)
    set_values(hash)
    pool.amount = start_pool_amount
  end
  
  
  def create_pool
    pool.amount = start_pool_amount.to_f if start_pool_amount
    pool.match_name = name
  end
    
    
  def activate(que)
    @@current_active_question = que
    que.activate
  end
  
  
  def register_player(registeration_string)
    msg = registeration_string.split
    if msg.count == 3 and msg[0] == shortcode.to_s and msg[1].downcase == "reg" and (msg[2] == keyword1 or msg[2] == keyword2 or msg[2] == keyword3 or msg[2] == keyword4)
      pl = Player.build
      players << pl
      pl.register(registeration_string) 
      pool.increment(self.points_to_pool)
      pl
    end
  end
  
  
  def create_question(&block)
    if @@current_active_inning
      q = Question.build(self.name, &block)
      @@previous_active_question = @@current_active_question
      @@current_active_question = q
      @@current_active_inning.questions << q
      q
    else
      p "No inning/round active currently"
    end
  end  
  
  
  def status
    state
  end
  
  
  def start(*args)
    if !(args.empty?) and self.innings.include?(args[0])
      inning = args.first
      inning.start
      @@current_active_inning = args.first
    end
    self.state = MATCH_STATUS['Started']
  end
  
    
  def finish(*args)
    if !(args.empty?) and self.innings.include?(args[0])
      inning = args[0]
      inning.finish
      @@current_active_inning = nil
    else
      self.state = MATCH_STATUS['Ended']
      process_results
    end
  end
  
  
  def process_results
    if question_winners.count != 0
      win_amount = self.pool.amount/question_winners.count 
      question_winners.each do |winner|
        winner.allot(win_amount)
      end
      (players - question_winners).each do |loser|
        loser.mark_as_loser
      end
    end
    p "Pool Size = " + denominated_value(self.pool.amount)
    p "No. of winners = " + question_winners.count.to_s
    p "Each winner gets = " + denominated_value(win_amount)
  end
  
  
  def submit_player_answer(player, answer_string)
    msg = answer_string.split
    if msg.size == 3 and (msg[1] == keyword1 or msg[1] == keyword2 or msg[1] == keyword3 or msg[1] == keyword4) and knockout_player_proccessing(player)
      player.question_answer.merge!({@@current_active_question => msg[2] })
      pool.increment(points_to_pool)
    end
  end
  
  
  def knockout_player_proccessing(player)
    (knockout == "true" and player.question_status[@@previous_active_question] == LEVEL_STATUS['Winner']) or
    @@current_active_inning.questions.count == 1 or knockout == "false"
  end
  
  
  def submit_question_answer(que, ans)
    que.answer = ans
    process_question_results(que, ans)
  end
  
  
  def process_question_results(que, ans)
    winners = []
    players.each do |player|
       if player.question_answer[@@current_active_question] == ans 
         player.question_status.merge!(@@current_active_question => LEVEL_STATUS['Winner']) 
         winners << player 
       else 
         player.question_status.merge!(@@current_active_question => LEVEL_STATUS['Loser'])
       end
    end
    winners
  end
  
  
  def question_winners
    winners = []
    players.each do |player|
      winners << player if player.question_status[@@current_active_question] == LEVEL_STATUS['Winner']
    end
    winners
  end
  
  def self.load(filename)
    build.instance_eval(File.read(filename), filename)
  end
  
  
  def match_type(type)
    self.game_type = type
  end
  
  def denominated_value(amount)
    "#{pool_denomination} - #{amount}"
  end
  
  
  private
  def create_attr_accessor(val)
    self.class.class_eval(<<-EOS, __FILE__, __LINE__ + 1)
      attr_accessor :#{val} 
    EOS
 
  end
  
  
  def set_values(hash)
    hash = hash.delete(' ').split.inject({}) {|hsh,i| sides=i.split("="); hsh[sides[0]]=sides[1]; hsh}
    hash.each_pair do |key, value|
      create_attr_accessor(key)      
      instance_variable_set :"@#{key}", (value.to_i.to_s == value ? value.to_i : value)
    end
  end
  
end



