require "./questions_db.rb"
require_relative "question"
require_relative "question_follow"
require_relative "reply"
require_relative "question_like"
require_relative "model_base"

class User < ModelBase
  attr_accessor :id, :fname, :lname

  def self.find_by_name(name)
    fname, lname = name.split(" ")
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT * FROM users WHERE fname = ? AND lname = ?
    SQL

    User.new(user.first)
  end

  def initialize(options)
    @id = options["id"]
    @fname = options["fname"]
    @lname = options["lname"]
  end

  def authored_questions
    Question.find_by_author(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(self.id)
  end

  def average_karma
    data = QuestionsDatabase.instance.execute(<<-SQL, self.id)
    SELECT
      COUNT (DISTINCT (questions.id)) AS q_count,
      CAST (COUNT (question_likes.question_id) AS FLOAT) AS like_count
    FROM
      questions
    LEFT OUTER JOIN
      question_likes
    ON
      questions.author_id = question_likes.user_id
    WHERE
      questions.author_id = ?
    SQL
    data.first["q_count"] / data.last["like_count"]
  end
end
