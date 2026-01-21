import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  try {
    // In a real implementation, this would fetch from the backend exercise service
    // For now, we'll return mock data

    const exercises = [
      {
        id: '1',
        title: 'FizzBuzz Challenge',
        description: 'Write a program that prints numbers 1-100, but replace multiples of 3 with "Fizz", multiples of 5 with "Buzz", and multiples of both with "FizzBuzz"',
        difficulty: 'medium',
        topic: 'loops',
        solved_count: 1240,
        avg_time: '15 min',
        xp_reward: 50,
        status: 'available'
      },
      {
        id: '2',
        title: 'Palindrome Checker',
        description: 'Create a function that checks if a string is a palindrome (reads the same forwards and backwards)',
        difficulty: 'easy',
        topic: 'strings',
        solved_count: 890,
        avg_time: '10 min',
        xp_reward: 30,
        status: 'available'
      },
      {
        id: '3',
        title: 'Factorial Calculator',
        description: 'Implement a recursive function to calculate the factorial of a number',
        difficulty: 'medium',
        topic: 'recursion',
        solved_count: 650,
        avg_time: '20 min',
        xp_reward: 40,
        status: 'available'
      }
    ]

    return NextResponse.json(exercises)
  } catch (error) {
    console.error('Exercises API error:', error)
    return NextResponse.json(
      { error: 'Failed to fetch exercises' },
      { status: 500 }
    )
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json()
    const { exercise_id, solution } = body

    // In a real implementation, this would submit the solution to the exercise service
    // For now, we'll simulate grading

    const result = {
      exercise_id,
      student_id: body.student_id || 'unknown',
      submitted_at: new Date().toISOString(),
      grade: 'pass', // or 'fail'
      score: 95,
      feedback: 'Great job! Your solution is correct and efficient.',
      completed: true
    }

    return NextResponse.json(result)
  } catch (error) {
    console.error('Exercise submission API error:', error)
    return NextResponse.json(
      { error: 'Failed to submit exercise' },
      { status: 500 }
    )
  }
}