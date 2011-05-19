class Pool
  attr_accessor :match_name, :amount
  
  def initialize
    self.amount = 0.0
  end
  
  def configuration(hash) # or block
    hash.each_pair do |key, value|
      instance_variable_set :"@#{key}", value
    end
  end
  
  def increment(with_amount)
    self.amount += with_amount
  end
end