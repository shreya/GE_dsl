# Match attibutes :name, :venue, :description, :scheduled_at, :keyword1, :keyword2, :keyword3, :keyword4,
#                 :pool_denomination, :start_pool_amount, :points_to_pool, :game_type, :state,
#                 :knockout, :shortcode, :number_of_rounds, :innings, :players, :pool


['pool', 'question', 'player', 'inning'].each {|file| require ('./'+file)}
require './attr_accessor_with_default'


class Game
  
  MATCH_STATUS = {'Started' => 1, 'Ended' => 2, 'Abandoned' => 3}
  LEVEL_STATUS = {'Winner' => 1, 'Loser' => 2}
  STATUS = {'Winner' => 1, 'Loser' => 2}
  
  attr_accessor :game_type, :name, :start_pool_amount, :state  
  attr_accessor_with_default :players, []
  attr_accessor_with_default :innings, []
  attr_accessor_with_default :pool, Pool.new
    

  ##################  Initialize Game ################################
  
  def self.load(filename)
    build.instance_eval(File.read(filename), filename)
  end
  
  
  def self.build(game_type='', &block)
    m = Game.new
    m.game_type = game_type 
    m.create_pool
    m.instance_eval(&block) if block_given?
    m
  end
  
  
  def initialize(*args)
    self.class.class_eval { attr_accessor *args }
    @current_active_question =  @previous_active_question =  @current_active_inning = nil  
  end
  
  
  def create_pool
    pool.amount = start_pool_amount.to_f if start_pool_amount
    pool.match_name = name
  end
  
  ######################################################################
  
  
  
  
  
  
  ####################### Define match_type ###########################
  
  def match_type(type)
    game_type = type
  end
  
  ######################################################################
  
  
  
  
  
  
  ###################### Configure game ################################

  def configure(hash="", &block)
    set_values(hash)
    create_rounds
    instance_eval(&block) if block_given?
  end
  

  def create_rounds
    number_of_rounds.to_i.times { innings << Inning.build(name) }
    innings
  end
  
  ###################################################################
  
  
  
  
  
  

  ######################### Configure Pool #########################

  def pool_configuration(hash, &block)
    edit_pool(hash)
    pool.amount = start_pool_amount
  end

  ##################################################################
  
  
  
  
  
  
  
  ######################### Start Game/Inning ######################
  
  def start(*args)
    start_inning(args.first) if evaluate_inning?(args) 
    state = MATCH_STATUS['Started']
  end

  
  def start_inning(inning)
    inning.start
    @current_active_inning = inning
    register_users(inning)
  end
  
  
  #################################################################  
  
  
  
  ######################### Create question ######################
  
  
  def create_question(&block)
    if @current_active_inning
      q = Question.build(self.name, &block)
      mark_question_as_current(q)
      q
    else
      p "No inning/round active currently"
    end
  end  

  #################################################################  
  
  
  
  
  
  
  
  ######################### Activate Question ####################  
    
  def activate(que)
    @current_active_question = que if que.activate
    get_player_answers      
  end
  

  ##################################################################
  
  
  
  
  
  
  ############### submit answer and process results ###############
  
  def get_player_answers
    players.each_with_index do |player, index|
      if knockout_player_proccessing(player)
        p "Enter player answer for #{index + 1} player"
        submit_player_answer(player, gets)
      end
    end
  end
  
  def submit_question_answer(que, ans)
    que.answer = ans
    process_question_results(que, ans)
  end
  
  
  def process_question_results(que, ans)
    winners = []
    players.each do |player|
      if player.question_answer[@current_active_question] and !!((player.question_answer[@current_active_question]).match(ans))
        mark_player_winner(player)         
        winners << player 
      else 
        player.question_status.merge!(@current_active_question => LEVEL_STATUS['Loser'])
      end
    end    
    winners
  end
  
  #####################################################################
  
  
  
  
  
  ####################### Finish Game, process results ################
  def finish(*args)
    (evaluate_inning?(args) and innings.last != args[0]) ? end_inning(args[0]) : end_match
  end
  
  
  def process_results
    winners = question_winners
        
    if winners.count != 0
      win_amount = pool.amount/(winners.count) 
      winners.each{ |winner| winner.allot(win_amount) }
      (players - winners).each{ |player| player.mark_as_loser }
    end
    anounce_results(win_amount, winners.count)
  end
  
  
  def question_winners
    winners = []
    players.each{ |player|
      winners << player if player.question_status[@current_active_question] == LEVEL_STATUS['Winner'] }
    winners
  end
  
  ######################################################################
  
  
  
  
  
  ####################### Player actions ###############################

  def register_player(registeration_string)
    msg = registeration_string.split
    if can_register?(msg)
      pl = Player.build
      players << pl
      pl.register(registeration_string) 
      pool.increment(points_to_pool)
      pl
    end
  end
  
  
  def register_users(inning_num)
    number_of_players.times { p "Enter player entry msg - "; register_player(gets) } if (inning_num == innings.first)
  end  
    
  
  def submit_player_answer(player, answer_string)
    #### Increment pool in any case
    pool.increment(points_to_pool)
    
    #### Check if the player's answer is correct
    msg = answer_string.split
    player.question_answer.merge!({@current_active_question => msg[2] }) if msg.size == 3 and check_keyword(msg[1]) == true and 
    knockout_player_proccessing(player)
  end
  

  ## Valid keyword
  def check_keyword(msg)    
    instance_variables.each{|var|  
      return true if var.to_s =~ /@keyword/ and msg == instance_variable_get(var)}
  end
  
  ## If player is already knocked out
  def knockout_player_proccessing(player)
    (knockout == "true" and player.question_status[@previous_active_question] == LEVEL_STATUS['Winner']) or
     @current_active_inning.questions.count == 1 or knockout == "false"
  end
    
  ###############################################################################
      
  
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
      
  
  alias :edit_pool :set_values
    
  ################################  
  def evaluate_inning?(args)
    !(args.empty?) and innings.include?(args[0])
  end
  
  
  def end_inning(inning)
    inning.finish
    @current_active_inning = nil
    process_results
    pool.amount = 0
    p "Enter enteries for #{next_inning_number(inning)} inning"
  end
  
  def end_match
    state = MATCH_STATUS['Ended']
    process_results
  end
  
  ################################
  
  ##### Inning Helpers
  
  def next_inning_number(inning)
    innings.index(inning) + 2
  end
  
  def inning(inning_number)
    innings[inning_number.to_i - 1]
  end
  
  
  ###### Pool helpers
  def denominated_value(amount)
    "#{pool_denomination} - #{amount}"
  end
  
  
  ###############################
  
  def mark_player_winner(player)
    player.question_status.merge!(@current_active_question => LEVEL_STATUS['Winner'])
  end
  
  def anounce_results(win_amount, winner_count)
    p "Pool Size = " + denominated_value(pool.amount)
    p "No. of winners = " + winner_count.to_s
    p "Each winner gets = " + denominated_value(win_amount) if win_amount 
  end
  
  
  def mark_question_as_current(q)
    @previous_active_question =  @current_active_question
    @current_active_question = q
    @current_active_inning.questions << q
  end
  
  
  def can_register?(msg)
    msg.count == 3 and 
    msg[0] == shortcode.to_s and 
    msg[1].downcase == "reg" and 
    (msg[2] == keyword1 or msg[2] == keyword2 or msg[2] == keyword3 or msg[2] == keyword4)
  end
  
end



