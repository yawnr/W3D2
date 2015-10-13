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



#####################################################################



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


  attr_accessor :id, :fname, :lname

  def initialize( options = {} )
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_user_id(self.id)
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


end



#####################################################################



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

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
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

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end

  def likers
    QuestionLike.likers_for_question_id(self.id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(self.id)
  end
end



#####################################################################



class QuestionFollow
  attr_accessor :id, :user_id, :question_id

  def self.followers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.id, users.fname, users.lname
    FROM
      questions_follow
    JOIN
      users
    ON
      users.id = questions_follow.user_id
    WHERE
      questions_follow.question_id = (?)
    SQL

    return nil if results.empty?
    results.map { |result| User.new(result) }

  end

  def self.followed_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      questions.id, questions.title, questions.body, questions.user_id
    FROM
      questions_follow
    JOIN
      questions
    ON
      questions.id = questions_follow.question_id
    WHERE
      questions_follow.user_id = (?)
    SQL

    return nil if results.empty?
    results.map { |result| Question.new(result) }
  end

  def self.most_followed_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      questions.id, questions.title, COUNT(questions_follow.user_id) AS count
    FROM
      questions_follow
    JOIN
      questions
    ON
      questions.id = questions_follow.question_id
    GROUP BY
      questions.id
    ORDER BY
      count DESC
    LIMIT
      (?)
    SQL

    return nil if results.empty?
    results.map { |result| Question.new(result) }
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)

  end

  def initialize( options = {} )
    @id, @user_id, @question_id =
    options.values_at('id', 'user_id', 'question_id')
  end


end



#####################################################################



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
    results.map { |result| Reply.new(result) }
  end


end



#####################################################################



class QuestionLike
  attr_accessor :id, :user_id, :question_id

  def self.likers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.id, users.fname, users.lname
    FROM
      users
    JOIN
      question_likes
    ON
      question_likes.user_id = users.id
    WHERE
      question_likes.question_id = (?)
    SQL

    return nil if results.empty?
    results.map { |result| User.new(result) }

  end

  def self.num_likes_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      COUNT(users.id)
    FROM
      users
    JOIN
      question_likes
    ON
      question_likes.user_id = users.id
    WHERE
      question_likes.question_id = (?)
    SQL

    results.first.values.last
  end

  def self.liked_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      question_likes.question_id
    FROM
      users
    JOIN
      question_likes
    ON
      question_likes.user_id = users.id
    WHERE
      question_likes.user_id = (?)
    SQL

    return nil if results.empty?
    results.map { |result| Question.new(result) }
  end

  def self.most_liked_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      questions.id, questions.title, COUNT(questions_likes.user_id) AS count
    FROM
      questions_likes
    JOIN
      questions
    ON
      questions.id = questions_likes.question_id
    GROUP BY
      questions.id
    ORDER BY
      count DESC
    LIMIT
      (?)
    SQL

    return nil if results.empty?
    results.map { |result| Question.new(result) }

  end


  def initialize( options = {} )
    @id, @user_id, @question_id =
    options.values_at('id', 'user_id', 'question_id')
  end

end
