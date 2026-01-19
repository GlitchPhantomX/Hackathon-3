// src/auth/AuthProvider.tsx
'use client';

import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { useSession, signIn as authSignIn, signOut as authSignOut } from './better-auth';

interface AuthContextType {
  user: any;
  signIn: (provider: string, credentials?: any) => Promise<void>;
  signOut: () => Promise<void>;
  loading: boolean;
  isAuthenticated: boolean;
  role: 'student' | 'teacher' | null;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [loading, setLoading] = useState(true);
  const [role, setRole] = useState<'student' | 'teacher' | null>(null);
  const { data: session, isLoading } = useSession();

  useEffect(() => {
    if (!isLoading) {
      setLoading(false);
      if (session?.user) {
        // Determine role from user data
        const userRole = session.user.role as 'student' | 'teacher' | undefined;
        setRole(userRole || null);
      } else {
        setRole(null);
      }
    }
  }, [session, isLoading]);

  const handleSignIn = async (provider: string, credentials?: any) => {
    try {
      // Sign in using the auth client
      await authSignIn(provider, credentials);
    } catch (error) {
      console.error('Sign in error:', error);
      throw error;
    }
  };

  const handleSignOut = async () => {
    try {
      await authSignOut();
      setRole(null);
    } catch (error) {
      console.error('Sign out error:', error);
      throw error;
    }
  };

  const value: AuthContextType = {
    user: session?.user,
    signIn: handleSignIn,
    signOut: handleSignOut,
    loading,
    isAuthenticated: !!session?.user,
    role
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};