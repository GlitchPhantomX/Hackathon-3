// src/components/ProtectedRoute.tsx
'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/auth/AuthProvider';
import { ReactNode } from 'react';

interface ProtectedRouteProps {
  children: ReactNode;
  allowedRoles?: ('student' | 'teacher')[];
  fallbackUrl?: string;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({
  children,
  allowedRoles = ['student', 'teacher'],
  fallbackUrl = '/auth/login'
}) => {
  const { user, loading, isAuthenticated } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading) {
      if (!isAuthenticated) {
        router.push(fallbackUrl);
        return;
      }

      if (user && allowedRoles && !allowedRoles.includes(user.role)) {
        router.push(fallbackUrl);
        return;
      }
    }
  }, [isAuthenticated, loading, user, allowedRoles, fallbackUrl, router]);

  // Show loading state while checking auth
  if (loading || (!isAuthenticated && !loading)) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Checking authentication...</p>
        </div>
      </div>
    );
  }

  // If user is authenticated and has the right role, show the content
  if (isAuthenticated && user && allowedRoles.includes(user.role)) {
    return <>{children}</>;
  }

  // Otherwise, don't render anything (redirect effect will handle navigation)
  return null;
};

export default ProtectedRoute;