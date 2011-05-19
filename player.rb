class Player
  
  LEVEL_STATUS = {'Winner' => 1, 'Loser' => 2}
  STATUS = {'Winner' => 1, 'Loser' => 2}
  
  attr_accessor :msisdn, :register_string, :entry_string, :question_answer, :question_status, :status, :win_amount
  
  def self.build(&block)
    p = Player.new
    p.question_answer, p.question_status, p.msisdn = {}, {}, Time.now.to_i
    p
  end
  
  def register(register_string)
    msg = register_string.split
    self.register_string = register_string  
  end
  
  def submit_answer(entry_string)
    self.entry_string = entry_string
  end
  
  def configure(hash) # or block
    hash.each_pair do |key, value|
      instance_variable_set :"@#{key}", value
    end
  end
  
  def allot(win_amount)
    self.win_amount = win_amount
    self.status = STATUS['Winner']
  end
  
  
  def mark_as_loser
    self.status = STATUS['Loser']
  end
end
