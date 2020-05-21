require_relative "questions_db"
require_relative "user"
require_relative "question"
require_relative "model_base"

class QuestionFollow < ModelBase
  attr_accessor :user_id, :question_id

  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.*
      FROM users
      JOIN question_follows ON users.id = question_follows.user_id
      WHERE ? = question_follows.question_id
    SQL

    users.map { |user| User.new(user) }
  end

  def self.most_followed_questions(n)
    qs = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT questions.*
      FROM questions
      JOIN question_follows ON questions.id = question_follows.user_id
      GROUP BY question_follows.question_id
      ORDER BY COUNT(question_follows.question_id)
      LIMIT ?
    SQL
    qs.map { |q| Question.new(q) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT questions.*
      FROM question_follows
      JOIN questions ON questions.id = question_follows.user_id
      WHERE ? = question_follows.user_id 
    SQL

    questions.map { |q| Question.new(q) }
  end

  def initialize(options)
    @user_id = options["user_id"]
    @question_id = options["question_id"]
  end
end
