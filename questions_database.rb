require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton
  def initialize
    super('questions.db')

    self.results_as_hash = true

    self.type_translation = true
  end
end

class User

  def self.find_by_id(user_id)
    # execute a SELECT; result in an `Array` of `Hash`es, each
    # represents a single row.
    results = QuestionsDatabase.instance.execute('SELECT * FROM users WHERE id = (?)', user_id)
    return nil if results.empty?
    User.new(results.first)
  end

  def self.find_by_name(first_name, last_name)
    results = QuestionsDatabase.instance.execute(<<-SQL, first_name, last_name)
    SELECT
      id--, fname, lname
    FROM
      users
    WHERE
      fname = (?)
      AND lname = (?)
    SQL

    return nil if results.empty?
    User.new(*results)
  end


  attr_accessor :id, :fname, :lname

  def initialize( options = {} )
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
end

class Question
  attr_accessor :id, :title, :body, :user_id

  def self.find_by_user_id(user_id)
    
  end

  def initialize( options = {} )
    @id, @title, @body, @user_id =
    options.values_at('id', 'title', 'body', 'user_id')
  end
end

class QuestionFollow
  attr_accessor :id, :user_id, :question_id

  def initialize( options = {} )
    @id, @user_id, @question_id =
    options.values_at('id', 'user_id', 'question_id')
  end

end

class Reply
  attr_accessor :id, :user_id, :question_id

  def initialize( options = {} )
    @id, @user_id, @question_id =
    options.values_at('id', 'user_id', 'question_id')
  end

end

class QuestionLike
  attr_accessor :id, :user_id, :question_id

  def initialize( options = {} )
    @id, @user_id, @question_id =
    options.values_at('id', 'user_id', 'question_id')
  end

end
