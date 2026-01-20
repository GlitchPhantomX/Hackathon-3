-- Create topics table
CREATE TABLE IF NOT EXISTS topics (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(100),
  difficulty_level INTEGER DEFAULT 1,
  estimated_duration_minutes INTEGER DEFAULT 10,
  prerequisites JSONB,
  learning_objectives JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'student',
  profile JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create exercises table
CREATE TABLE IF NOT EXISTS exercises (
  id SERIAL PRIMARY KEY,
  topic_id INTEGER REFERENCES topics(id),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  problem_statement TEXT NOT NULL,
  test_cases JSONB,
  hints JSONB,
  difficulty_level INTEGER DEFAULT 1,
  max_attempts INTEGER DEFAULT 5,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create user_progress table
CREATE TABLE IF NOT EXISTS user_progress (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  topic_id INTEGER REFERENCES topics(id),
  exercise_id INTEGER REFERENCES exercises(id),
  status VARCHAR(50) DEFAULT 'not_started', -- not_started, in_progress, completed
  score DECIMAL(5,2),
  attempts_count INTEGER DEFAULT 0,
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create user_answers table
CREATE TABLE IF NOT EXISTS user_answers (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  exercise_id INTEGER REFERENCES exercises(id),
  answer_text TEXT,
  is_correct BOOLEAN DEFAULT FALSE,
  attempt_number INTEGER,
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create course_structure table
CREATE TABLE IF NOT EXISTS course_structure (
  id SERIAL PRIMARY KEY,
  course_name VARCHAR(255) NOT NULL,
  course_description TEXT,
  prerequisites JSONB,
  learning_outcomes JSONB,
  modules JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create learning_analytics table
CREATE TABLE IF NOT EXISTS learning_analytics (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  topic_id INTEGER REFERENCES topics(id),
  exercise_id INTEGER REFERENCES exercises(id),
  event_type VARCHAR(100) NOT NULL, -- start_exercise, submit_answer, complete_topic, etc.
  event_data JSONB,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create ai_feedback table
CREATE TABLE IF NOT EXISTS ai_feedback (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  exercise_id INTEGER REFERENCES exercises(id),
  original_code TEXT,
  suggested_improvements TEXT,
  feedback_type VARCHAR(100), -- correctness, style, performance
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  notification_type VARCHAR(50), -- info, warning, achievement
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
