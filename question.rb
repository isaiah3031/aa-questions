require_relative "questions_db"
require_relative "reply"
require_relative "user"
require_relative "question_follow"
require_relative "question_like"
require_relative "model_base"

class Question < ModelBase
  attr_accessor :id, :title, :body, :author_id

  def self.find_by_author(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT * FROM questions WHERE author_id = ?
    SQL

    Question.new(data.first)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT questions.*
      FROM questions
      JOIN question_likes 
      ON question_likes.question_id = questions.id
      GROUP BY question_likes.question_id
      ORDER BY COUNT(question_likes.question_id)
      LIMIT ?
    SQL
  end

  def initialize(options)
    @id = options["id"]
    @title = options["title"]
    @body = options["body"]
    @author_id = options["author_id"]
  end

  def author
    User.find_by_id(self.author_id)
  end

  def replies
    Reply.find_by_question_id(self.id)
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end

  def likers
    QuestionLike.likers_for_question_id(self.author_id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(self.id)
  end
end
