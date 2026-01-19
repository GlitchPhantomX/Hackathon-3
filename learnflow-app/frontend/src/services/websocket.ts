// src/services/websocket.ts
import { io, Socket } from 'socket.io-client';

class WebSocketService {
  private socket: Socket | null = null;
  private baseUrl: string = process.env.NEXT_PUBLIC_WS_URL || 'ws://localhost:8000';

  connect(userId: string, token?: string) {
    // Disconnect if already connected
    if (this.socket) {
      this.disconnect();
    }

    // Connect to WebSocket server
    this.socket = io(this.baseUrl, {
      transports: ['websocket'],
      auth: {
        token: token || localStorage.getItem('authToken'),
        userId: userId,
      },
    });

    // Handle connection events
    this.socket.on('connect', () => {
      console.log('Connected to WebSocket server');
    });

    this.socket.on('disconnect', (reason) => {
      console.log('Disconnected from WebSocket server:', reason);
    });

    this.socket.on('connect_error', (error) => {
      console.error('WebSocket connection error:', error);
    });

    return this.socket;
  }

  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
    }
  }

  getSocket(): Socket | null {
    return this.socket;
  }

  // Subscribe to chat events
  subscribeToChatEvents(callbacks: {
    onMessageReceived?: (data: any) => void;
    onTypingStart?: (data: any) => void;
    onTypingStop?: (data: any) => void;
  }) {
    if (!this.socket) {
      console.warn('WebSocket not connected');
      return;
    }

    if (callbacks.onMessageReceived) {
      this.socket.on('chat_message', callbacks.onMessageReceived);
    }

    if (callbacks.onTypingStart) {
      this.socket.on('typing_start', callbacks.onTypingStart);
    }

    if (callbacks.onTypingStop) {
      this.socket.on('typing_stop', callbacks.onTypingStop);
    }
  }

  unsubscribeFromChatEvents() {
    if (!this.socket) return;

    this.socket.off('chat_message');
    this.socket.off('typing_start');
    this.socket.off('typing_stop');
  }

  // Send chat message
  sendChatMessage(data: { conversationId: string; message: string; senderId: string }) {
    if (!this.socket) {
      console.warn('WebSocket not connected');
      return;
    }

    this.socket.emit('send_chat_message', data);
  }

  // Notify typing status
  notifyTyping(conversationId: string, isTyping: boolean, userId: string) {
    if (!this.socket) {
      console.warn('WebSocket not connected');
      return;
    }

    this.socket.emit('typing_status', {
      conversationId,
      isTyping,
      userId,
    });
  }

  // Subscribe to progress updates
  subscribeToProgressUpdates(callback: (data: any) => void) {
    if (!this.socket) {
      console.warn('WebSocket not connected');
      return;
    }

    this.socket.on('progress_update', callback);
  }

  unsubscribeFromProgressUpdates() {
    if (!this.socket) return;

    this.socket.off('progress_update');
  }

  // Subscribe to notifications
  subscribeToNotifications(callback: (data: any) => void) {
    if (!this.socket) {
      console.warn('WebSocket not connected');
      return;
    }

    this.socket.on('notification', callback);
  }

  unsubscribeFromNotifications() {
    if (!this.socket) return;

    this.socket.off('notification');
  }
}

export default new WebSocketService();