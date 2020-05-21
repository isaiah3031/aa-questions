require "active_support/inflector"

class ModelBase
  def self.table
    self.to_s.tableize
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id: id)
    SELECT * FROM #{table} WHERE id = :id
    SQL

    self.new(data.first)
  end

  def self.all
    QuestionsDatabase.instance.execute(<<-SQL)
    SELECT * FROM #{table}
    SQL
  end

  def save
    if @id.nil?
      data = QuestionsDatabase.instance.execute(<<-SQL)
      INSERT INTO 
        #{table} (#{self.instance_variables})
      VALUES
        (?, ?, ?, ?);
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      update
    end
  end

  def update
    if !@id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, id: id)
        UPDATE
          #{table}
        SET 
          #{self.instance_variables}
        WHERE
          id = :id;
      SQL
    end
  end
end
