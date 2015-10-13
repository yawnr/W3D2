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
      id, fname, lname
    FROM
      users
    WHERE
      fname = (?)
      AND lname = (?)
    SQL

    return nil if results.empty?
    User.new(*results)
  end

  def authored_questions
    Question.find_by_user_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
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

    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      id, title, body, user_id
    FROM
      questions
    WHERE
      user_id = (?)
    SQL

    return nil if results.empty?
    results.map { |result| Question.new(result) }

  end

  def initialize( options = {} )
    @id, @title, @body, @user_id =
    options.values_at('id', 'title', 'body', 'user_id')
  end

  def author
    User.find_by_id(user_id)
  end

  def replies
    Reply.find_by_question_id(self.id)
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
  attr_accessor :id, :question_id, :reply_id, :user_id, :body

  def self.find_by_user_id(user_id)

    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      id, question_id, reply_id, user_id, body
    FROM
      replies
    WHERE
      user_id = (?)
    SQL

    return nil if results.empty?
    results.map { |result| Reply.new(result) }
  end

  def self.find_by_question_id(question_id)

    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      id, question_id, reply_id, user_id, body
    FROM
      replies
    WHERE
      question_id = (?)
    SQL

    return nil if results.empty?
    results.map { |result| Reply.new(result) }

  end


  def initialize( options = {} )
    @id, @question_id, @reply_id, @user_id, @body =
    options.values_at('id', 'question_id', 'reply_id', 'user_id', 'body')
  end

  def author
    User.find_by_id(user_id)
  end

  def question
    Question.find_by_question_id(question_id)
  end

  def parent_reply
    results = QuestionsDatabase.instance.execute(<<-SQL, self.reply_id)
    SELECT
      id, question_id, reply_id, user_id, body
    FROM
      replies
    WHERE
      id = (?)
    SQL

    return nil if results.empty?
    Reply.new(*results)
  end

  def child_replies
    results = QuestionsDatabase.instance.execute(<<-SQL, self.id)
    SELECT
      id, question_id, reply_id, user_id, body
    FROM
      replies
    WHERE
      reply_id = (?)
    SQL

    return nil if results.empty?
    Reply.new(*results)
  end

end

class QuestionLike
  attr_accessor :id, :user_id, :question_id

  def initialize( options = {} )
    @id, @user_id, @question_id =
    options.values_at('id', 'user_id', 'question_id')
  end

end
