class Question
  attr_accessor :body, :option1, :option2, :option3, :answer, :match_name, :state, :wrongs_allowed

  STATUS = {'Open' => 1, 'Closed' => 2}

  def self.build(match_name = '', &block)
    q = Question.new
    q.match_name = match_name
    q.instance_eval(&block)
    q
  end
  
  def configure(hash)
    hash = hash.delete(' ').split.inject({}) {|hsh,i| sides=i.split("="); hsh[sides[0]]=sides[1]; hsh}
    hash.each_pair do |key, value|
      instance_variable_set :"@#{key}", value
    end
    self
  end
  
  def activate
    self.state = STATUS['Open']
  end
  
  def submit_answer(ans)
    self.answer = ans
  end
  
  def close
    process_results
  end
  
  def process_results
  end
  
end
