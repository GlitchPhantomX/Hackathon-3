-- Initial database schema for LearnFlow application

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) DEFAULT 'student',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create student_progress table
CREATE TABLE IF NOT EXISTS student_progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    module VARCHAR(255) NOT NULL,
    mastery_score DECIMAL(5,2) DEFAULT 0.00,
    streak INTEGER DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create exercises table
CREATE TABLE IF NOT EXISTS exercises (
    id SERIAL PRIMARY KEY,
    topic VARCHAR(255) NOT NULL,
    difficulty VARCHAR(20) DEFAULT 'medium',
    solution TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create code_submissions table
CREATE TABLE IF NOT EXISTS code_submissions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    exercise_id INTEGER REFERENCES exercises(id) ON DELETE CASCADE,
    code TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    feedback TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_student_progress_user_module ON student_progress(user_id, module);
CREATE INDEX IF NOT EXISTS idx_exercises_topic ON exercises(topic);
CREATE INDEX IF NOT EXISTS idx_code_submissions_user_exercise ON code_submissions(user_id, exercise_id);

-- Insert sample data for initial setup
INSERT INTO users (email, role) VALUES
    ('admin@learnflow.test', 'admin'),
    ('student1@learnflow.test', 'student')
ON CONFLICT (email) DO NOTHING;

INSERT INTO exercises (topic, difficulty, solution) VALUES
    ('Python Basics', 'easy', 'print("Hello, World!")'),
    ('Data Structures', 'medium', '# Solution for data structures exercise'),
    ('Algorithms', 'hard', '# Solution for algorithms exercise')
ON CONFLICT DO NOTHING;

-- Grant necessary permissions
GRANT ALL PRIVILEGES ON TABLE users TO postgres;
GRANT ALL PRIVILEGES ON TABLE student_progress TO postgres;
GRANT ALL PRIVILEGES ON TABLE exercises TO postgres;
GRANT ALL PRIVILEGES ON TABLE code_submissions TO postgres;

GRANT USAGE ON SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;