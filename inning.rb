class Inning
  
  STATUS = {'Started' => 1, 'Ended' => 2, 'Abandoned' => 3}
  
  attr_accessor :match_name, :round_number, :state, :questions
  
  def self.build(match_name)
    i = Inning.new
    i.match_name = match_name
    i.questions = []
    i.state = nil
    i
  end
  
  
  def start
    self.state = STATUS['Started']
  end
  
  def finish
    self.state = STATUS['Ended']
  end
  
  def abandon
    self.state = STATUS['Abandoned']
  end
  
end