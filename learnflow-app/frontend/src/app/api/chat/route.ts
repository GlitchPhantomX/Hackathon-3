import { NextResponse } from 'next/server'

export async function POST(request: Request) {
  try {
    const body = await request.json()
    const { student_id, session_id, query } = body

    // Call the triage service backend
    const triageResponse = await fetch('http://triage-service.default.svc.cluster.local:8000/api/triage', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        student_id,
        session_id,
        query
      })
    })

    if (!triageResponse.ok) {
      throw new Error(`Triage service responded with status ${triageResponse.status}`)
    }

    const triageData = await triageResponse.json()

    return NextResponse.json(triageData)
  } catch (error) {
    console.error('Chat API error:', error)

    // Return a simulated response in case the backend is not available
    const { student_id, query } = body || {}

    // Determine the appropriate service based on the query content
    let routedTo = 'concepts'
    if (query?.toLowerCase().includes('debug') || query?.toLowerCase().includes('error') || query?.toLowerCase().includes('fix')) {
      routedTo = 'debug'
    } else if (query?.toLowerCase().includes('exercise') || query?.toLowerCase().includes('practice') || query?.toLowerCase().includes('challenge')) {
      routedTo = 'exercise'
    }

    const fallbackResponse = {
      query_id: `q-${Date.now()}`,
      student_id: student_id || 'unknown',
      routed_to: routedTo,
      topic: `learning.query.${routedTo}`,
      timestamp: new Date().toISOString(),
      message: 'Backend service temporarily unavailable. This is a simulated response.',
      status: 'fallback'
    }

    return NextResponse.json(fallbackResponse, { status: 500 })
  }
}