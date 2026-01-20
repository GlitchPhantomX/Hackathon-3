-- Insert sample topics (24 topics)
INSERT INTO topics (title, description, category, difficulty_level, estimated_duration_minutes, prerequisites, learning_objectives) VALUES
('Introduction to Programming', 'Basic concepts of programming', 'Programming', 1, 60, '[]', '["Understand basic programming concepts"]'),
('Variables and Data Types', 'Working with variables and data types', 'Programming', 1, 90, '["Introduction to Programming"]', '["Declare and use variables", "Understand data types"]'),
('Control Structures', 'Conditional statements and loops', 'Programming', 2, 120, '["Variables and Data Types"]', '["Use if-else statements", "Implement loops"]'),
('Functions', 'Creating and using functions', 'Programming', 2, 120, '["Control Structures"]', '["Define functions", "Use parameters and return values"]'),
('Arrays and Collections', 'Working with arrays and collections', 'Programming', 2, 150, '["Functions"]', '["Use arrays", "Work with collections"]'),
('Object-Oriented Programming', 'Classes, objects, inheritance', 'Programming', 3, 180, '["Functions"]', '["Create classes", "Implement inheritance"]'),
('Error Handling', 'Managing exceptions and errors', 'Programming', 3, 120, '["Object-Oriented Programming"]', '["Handle exceptions", "Use try-catch blocks"]'),
('File Operations', 'Reading and writing files', 'Programming', 3, 120, '["Object-Oriented Programming"]', '["Read files", "Write files"]'),
('Database Basics', 'Introduction to databases', 'Database', 2, 150, '["Functions"]', '["Understand database concepts", "Use basic SQL"]'),
('SQL Fundamentals', 'Structured Query Language basics', 'Database', 2, 180, '["Database Basics"]', '["Write SELECT statements", "Use WHERE clauses"]'),
('Advanced SQL', 'Joins, subqueries, and advanced concepts', 'Database', 3, 240, '["SQL Fundamentals"]', '["Use joins", "Write subqueries"]'),
('Web Development Basics', 'HTML, CSS, and JavaScript introduction', 'Web Development', 1, 180, '["Introduction to Programming"]', '["Create HTML pages", "Style with CSS", "Add JavaScript"]'),
('Frontend Frameworks', 'React, Vue, or Angular basics', 'Web Development', 3, 240, '["Web Development Basics"]', '["Use a frontend framework", "Build components"]'),
('Backend Development', 'Server-side programming', 'Web Development', 3, 240, '["Object-Oriented Programming"]', '["Create APIs", "Handle HTTP requests"]'),
('API Design', 'Designing RESTful APIs', 'Web Development', 3, 180, '["Backend Development"]', '["Design REST APIs", "Use HTTP methods"]'),
('Testing Fundamentals', 'Unit testing and integration testing', 'Software Engineering', 2, 150, '["Functions"]', '["Write unit tests", "Test functions"]'),
('Version Control', 'Git and version control systems', 'Software Engineering', 1, 120, '[]', '["Use Git", "Manage branches"]'),
('Agile Methodology', 'Agile development practices', 'Software Engineering', 2, 120, '[]', '["Understand Agile principles", "Use Scrum practices"]'),
('DevOps Basics', 'Continuous integration and deployment', 'DevOps', 3, 180, '["Version Control"]', '["Use CI/CD pipelines", "Deploy applications"]'),
('Cloud Computing', 'Cloud platforms and services', 'Cloud', 3, 240, '["DevOps Basics"]', '["Deploy to cloud", "Use cloud services"]'),
('Security Fundamentals', 'Application security basics', 'Security', 3, 240, '["Backend Development"]', '["Secure applications", "Handle authentication"]'),
('Performance Optimization', 'Improving application performance', 'Performance', 3, 240, '["Backend Development"]', '["Optimize code", "Use caching"]'),
('Mobile Development', 'Creating mobile applications', 'Mobile', 3, 300, '["Object-Oriented Programming"]', '["Build mobile apps", "Use mobile frameworks"]'),
('Machine Learning Basics', 'Introduction to ML concepts', 'AI/ML', 4, 300, '["Advanced SQL"]', '["Understand ML concepts", "Use ML libraries"]');

-- Insert sample users (3 users)
INSERT INTO users (username, email, password_hash, role, profile) VALUES
('john_doe', 'john@example.com', '$2a$10$8K1p/a0dum/U8.HhpYlx/eYyMs8mP3h6tG7NpdOEwwAWY3qYqOKb.', 'student', '{"first_name": "John", "last_name": "Doe", "age": 25}'),
('jane_smith', 'jane@example.com', '$2a$10$8K1p/a0dum/U8.HhpYlx/eYyMs8mP3h6tG7NpdOEwwAWY3qYqOKb.', 'student', '{"first_name": "Jane", "last_name": "Smith", "age": 28}'),
('bob_wilson', 'bob@example.com', '$2a$10$8K1p/a0dum/U8.HhpYlx/eYyMs8mP3h6tG7NpdOEwwAWY3qYqOKb.', 'instructor', '{"first_name": "Bob", "last_name": "Wilson", "age": 35}');

-- Insert sample exercises
INSERT INTO exercises (topic_id, title, description, problem_statement, test_cases, hints, difficulty_level, max_attempts) VALUES
(1, 'Hello World', 'Print Hello World', 'Write a program that prints "Hello, World!" to the console', '[{"input": "", "expected_output": "Hello, World!"}]', '["Use print statement", "Remember to include exclamation mark"]', 1, 5);
