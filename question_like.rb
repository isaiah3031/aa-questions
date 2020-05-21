require_relative "questions_db"
require_relative "user"
require_relative "model_base"

class QuestionLike < ModelBase
  attr_accessor :id, :user_id, :question_id

  def self.likers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.* FROM question_likes
      JOIN users ON question_likes.user_id = users.id
      WHERE question_id = ?
    SQL

    users.map { |user| User.new(user) }
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT questions.* 
      FROM question_likes 
      JOIN questions 
      ON question_likes.question_id = questions.id 
      WHERE questions.author_id = ?
    SQL

    questions.map { |q| Question.new(q) }
  end

  def self.num_likes_for_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT COUNT(user_id) FROM question_likes WHERE question_id = ?
    SQL
    result.first.values.first
  end

  def self.most_liked_questions(n)
    result = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT 
        questions.*
      FROM 
        question_likes
      JOIN
        questions ON questions.id = question_likes.question_id
      GROUP BY 
        question_likes.question_id
      ORDER BY
        COUNT(question_likes.question_id) DESC
      LIMIT ?
    SQL
  end

  def initialize(options)
    @id = options["id"]
    @user_id = options["user_id"]
    @question_id = options["question_id"]
  end
end
