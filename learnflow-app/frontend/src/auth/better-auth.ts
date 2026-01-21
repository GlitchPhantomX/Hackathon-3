// src/auth/better-auth.ts
import { createAuthClient } from 'better-auth/react';

// Create the auth client
export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_BETTER_AUTH_URL || 'http://localhost:8080', // Your Better Auth server URL
  fetchOptions: {
    // Additional fetch options if needed
  },
});

// Export the hooks and methods
export const { signIn, signOut, useSession } = authClient;