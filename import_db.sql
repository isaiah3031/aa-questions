PRAGMA foreign_keys = ON;

DROP TABLE if EXISTS users;
CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE if EXISTS questions;
CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE if EXISTS question_follows;
CREATE TABLE question_follows(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE if EXISTS replies;
CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  subject_id INTEGER NOT NULL,
  parent_id INTEGER,
  author_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (subject_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS question_likes;
CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO 
  users (fname, lname)
VALUES 
  ("Ned", "Thomas"),
  ("other", "guy"),
  ('otherother', 'person');

INSERT INTO 
  questions (title, body, author_id)
VALUES 
  ("title1", "body1", (SELECT id FROM users WHERE fname = 'Ned' AND lname = 'Thomas')),
  ("title2", "body2", (SELECT id FROM users WHERE fname = 'Ned' AND lname = 'Thomas')),
  ("title3", "body3", (SELECT id FROM users WHERE fname = 'other' AND lname = 'guy'));

INSERT INTO 
  replies (subject_id, parent_id, author_id, body)
VALUES
  (1, NULL, 2, 'title1?'),
  (1, 1, 2, 'reply to title1?'),
  (2, NULL, 2, 'title2?');

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  (1, 1),
  (2, 3);

