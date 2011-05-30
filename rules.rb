match_type "cricket"
configure "name = match_name
  venue = venue
  match_description = match_description
  match_scheduled_at = match_scheduled_at
  keyword1 = k1
  keyword2 = k2
  keyword3 = k3
  keyword4 = k4
  knockout = true 
  shortcode = nw
  number_of_rounds = 2
  number_of_questions = 10
  number_of_players = 2"


pool_configuration "
  pool_denomination = Rs
  start_pool_amount = 1000
  points_to_pool = 10", do
  
end
  
   
start
start inning(1)

q1 = create_question do
  configure "
    option1 = option1
    option2 = option2
    option3 = option3
    answer = a 
    wrongs_allowed = 1"
end 
activate q1
submit_question_answer(q1, 'ab')


q2 = create_question do
  configure "
    option1 = option1
    option2 = option2
    option3 = option3
    answer = a 
    wrongs_allowed = 1"
end 

activate q2
submit_question_answer(q2, 'b')


q3 = create_question do
  configure "
    option1 = option1
    option2 = option2
    option3 = option3
    answer = a
    wrongs_allowed = 1 "
end 
activate q3
submit_question_answer(q3, 'a')

finish inning(1)


start inning(2)

q4 = create_question do
  configure "
    option1 = option1
    option2 = option2
    option3 = option3
    answer = a 
    wrongs_allowed = 1"
end 
activate q4
submit_question_answer(q4, 'a')

finish