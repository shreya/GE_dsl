def diff(str1, str2)
  diff = 0
  str1.size.times{|index| diff += 1 if str1[index] != str2[index]} if str1.size == str2.size
  diff
end

# if player.question_answer[@current_active_question]
#   diff = 0
#   str1 = player.question_answer[@current_active_question]
#   str2 = ans
#   str1.size.times{|index| diff += 1 if str1[index] != str2[index]} if str1.size == str2.size
#   p @current_active_question.wrongs_allowed == diff #unless @current_active_question.blank?
# end