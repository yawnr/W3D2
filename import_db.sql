CREATE TABLE users (

  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE questions_follow (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  reply_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (reply_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Jimmy', 'Zeng'),
  ('John', 'Snyder');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('How', 'To SQL?', (SELECT id FROM users WHERE fname = 'Jimmy' AND lname = 'Zeng')),
  ('Why', 'SQL?', (SELECT id FROM users WHERE fname = 'John' AND lname = 'Snyder'));

INSERT INTO
  questions_follow (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Jimmy' AND lname = 'Zeng'), (SELECT id FROM questions WHERE title = 'How')),
  ((SELECT id FROM users WHERE fname = 'John' AND lname = 'Snyder'), (SELECT id FROM questions WHERE title = 'Why'));

INSERT INTO
  replies (question_id, reply_id, user_id, body)
VALUES
  (1, null, 1, 'Query!'),
  (2, null, 2, 'I said so'),
  (1, 1, 2, 'Why query?');

  INSERT INTO
    question_likes (user_id, question_id)
  VALUES
    (1, 1),
    (2, 1);
