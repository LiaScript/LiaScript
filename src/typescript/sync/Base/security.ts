import type { Transport } from '../../../../node_modules/y-generic/dist/transport'
import { encode, decode } from 'uint8-to-base64'
import { Crypto } from '../Crypto'

/** Wrap a y-generic Transport so every outgoing/incoming frame is run
 * through the existing password-keyed Crypto wrapper (see ../Crypto.ts).
 * Used for backends that don't already encrypt payload content themselves
 * (WebSocket, PeerJS, SimplePeer, Ably) - Gun/PubNub/Trystero already do
 * real encryption and are left untouched.
 *
 * No-op when no password is set, so rooms without a password see zero
 * behavior change.
 *
 * Caller is responsible for calling `Crypto.init(password)` (after
 * SimpleCrypto has loaded) before any frame is sent/received.
 *
 * @param stripHeaderBytes - some concrete transports (WebSocket, Ably) speak
 * a wire protocol that doesn't natively have GenericProvider's own 4-byte
 * CRC32 header, so they unconditionally strip it before their own send() and
 * re-add a freshly computed one in their own onMessage() - transparently, as
 * far as GenericProvider is concerned. But that translation happens on
 * whatever bytes THIS wrapper hands them, which are our ciphertext, not
 * GenericProvider's real payload - so their strip/re-add would silently
 * chop 4 bytes off every single encrypted frame. Padding our ciphertext with
 * `stripHeaderBytes` dummy leading bytes before send (so their strip removes
 * exactly those, leaving our ciphertext intact on the wire) and stripping
 * the same count back off on receive (undoing their re-add) cancels this
 * out. Pass 0 (default) for transports with no such translation (PeerJS,
 * SimplePeer).
 */
export function wrapTransport(
  transport: Transport,
  password?: string,
  stripHeaderBytes: number = 0,
): Transport {
  if (!password) return transport

  return {
    connect: (config) => transport.connect(config),
    disconnect: () => transport.disconnect(),

    send: (data: Uint8Array) => {
      const cipher = new TextEncoder().encode(Crypto.encode(encode(data)))
      if (stripHeaderBytes === 0) return transport.send(cipher)

      const padded = new Uint8Array(stripHeaderBytes + cipher.length)
      padded.set(cipher, stripHeaderBytes)
      return transport.send(padded)
    },

    onMessage: (callback: (data: Uint8Array) => void) =>
      transport.onMessage((frame: Uint8Array) => {
        try {
          const cipher =
            stripHeaderBytes === 0 ? frame : frame.subarray(stripHeaderBytes)
          const data = decode(Crypto.decode(new TextDecoder().decode(cipher)))
          callback(data)
        } catch (e) {
          // Wrong password or corrupted frame - drop it rather than crash.
          console.warn('security: dropping undecryptable frame ->', e)
        }
      }),

    onPeerConnect: transport.onPeerConnect
      ? (callback: (peerId: string) => void) =>
          transport.onPeerConnect!(callback)
      : undefined,

    get isConnected() {
      return transport.isConnected
    },

    get preferredBatchMs() {
      return transport.preferredBatchMs
    },
  }
}
