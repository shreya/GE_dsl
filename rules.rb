match_type "cricket"
configure "name = match_name
  venue = venue
  match_description = match_description
  match_scheduled_at = match_scheduled_at
  keyword1 = keyword1
  keyword2 = keyword2
  keyword3 = keyword3
  keyword4 = keyword4
  knockout = true 
  shortcode = nw
  number_of_rounds = 2"


pool_configuration "
  pool_denomination = Rs
  start_pool_amount = 1000
  points_to_pool = 10"
  
   
start
start inning(1)

p1 = register_player 'nw reg keyword1'
p2 = register_player 'nw reg keyword1'
p3 = register_player 'nw reg keyword1'
p4 = register_player 'nw reg keyword2'
p5 = register_player 'nw reg keyword2'

q1 = create_question do
  configure "
    option1 = option1
    option2 = option2
    option3 = option3
    answer = a "
end 

q1.activate

submit_player_answer(p1, "nw keyword1 a")
submit_player_answer(p2, "nw keyword1 a")
submit_player_answer(p3, "nw keyword1 a")

submit_question_answer(q1, 'a')

q2 = create_question do
  configure "
    option1 = option1
    option2 = option2
    option3 = option3
    answer = a "
end 

q2.activate

submit_player_answer(p1, "nw keyword1 a")
submit_player_answer(p2, "nw keyword1 b")
submit_player_answer(p3, "nw keyword1 b")

submit_question_answer(q2, 'b')

q3 = create_question do
  configure "
    option1 = option1
    option2 = option2
    option3 = option3
    answer = a "
end 

q3.activate

submit_player_answer(p1, "nw keyword1 a")
submit_player_answer(p2, "nw keyword1 a")
submit_player_answer(p3, "nw keyword1 b")

submit_question_answer(q3, 'a')


finish inning(1)

start inning(2)

q4 = create_question do
  configure "
    option1 = option1
    option2 = option2
    option3 = option3
    answer = a "
end 

q4.activate

submit_player_answer(p1, "nw keyword1 a")
submit_player_answer(p2, "nw keyword1 a")
submit_player_answer(p3, "nw keyword1 a")

submit_question_answer(q4, 'a')

finish inning(2)

finish