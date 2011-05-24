class Module
  def attr_accessor_with_default(sym, default = Proc.new)
    define_method(sym, block_given? ? default : Proc.new { default })
    module_eval(<<-EVAL, __FILE__, __LINE__ + 1)
      def #{sym}=(value)                          # def age=(value)
        class << self; attr_accessor :#{sym} end  #   class << self; attr_accessor :age end
        @#{sym} = value                           #   @age = value
      end                                         # end
    EVAL
  end
end
