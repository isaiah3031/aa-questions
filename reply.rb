require "./questions_db.rb"
require_relative "./model_base.rb"
require_relative "./user.rb"
# require_relative "./question.rb"

class Reply < ModelBase
  attr_accessor :id, :subject_id, :parent_id, :author_id, :body

  def self.find_by_user_id(user_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT * FROM replies WHERE author_id = ?
    SQL
    Reply.new(replies.first)
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT * FROM replies WHERE subject_id = ?
    SQL
    replies.each { |reply| Reply.new(reply) }
  end

  def initialize(options)
    @id = options["id"]
    @subject_id = options["subject_id"]
    @parent_id = options["parent_id"]
    @author_id = options["author_id"]
    @body = options["body"]
  end

  def author
    User.find_by_id(self.author_id)
  end

  def question
    Question.find_by_id(self.subject_id)
  end

  def parent_reply
    Reply.find_by_id(self.parent_id)
  end

  def child_replies
    replies = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT * FROM replies WHERE parent_id = ?
    SQL
    replies.each { |reply| Reply.new(reply) }
  end
end
