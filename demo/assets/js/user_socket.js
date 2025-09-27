/**
 * Phoenix Socket configuration for FlyMapEx real-time features.
 *
 * Establishes WebSocket connection for real-time map marker updates
 * and provides the socket instance for use by LiveView hooks.
 */

import {Socket} from "phoenix"

// Create and configure socket
const socket = new Socket("/socket", {
  params: {token: window.userToken}
})

// Connect to socket
socket.connect()

// Export for use by LiveView hooks
export default socket