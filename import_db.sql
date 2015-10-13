CREATE TABLE users (

  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL

  FOREIGN KEY user_id REFERENCES users(id)

);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL
  user_id INTEGER NOT NULL

  FOREIGN KEY question_id REFERENCES questions(id)
);

CREATE TABLE questions_follow (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL

  FOREIGN KEY question_id REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  reply_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL

  FOREIGN KEY reply_id REFERENCES replies(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  -- FOREIGN KEY question_like_id REFERENCES question_likes(id)
);
