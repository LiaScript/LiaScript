import { encode, decode } from 'uint8-to-base64'

function b64(bytes: ArrayBuffer): string {
  return encode(new Uint8Array(bytes))
}

function unb64(s: string): Uint8Array {
  return decode(s)
}

export function generateContentKey(): Promise<CryptoKey> {
  return crypto.subtle.generateKey({ name: 'AES-GCM', length: 256 }, true, [
    'encrypt',
    'decrypt',
  ])
}

export function generateECDHKeyPair(): Promise<CryptoKeyPair> {
  return crypto.subtle.generateKey(
    { name: 'ECDH', namedCurve: 'P-256' },
    true,
    ['deriveKey'],
  )
}

export async function exportPublicKey(key: CryptoKey): Promise<string> {
  return b64(await crypto.subtle.exportKey('spki', key))
}

async function importPublicKey(publicKeyB64: string): Promise<CryptoKey> {
  return crypto.subtle.importKey(
    'spki',
    unb64(publicKeyB64),
    { name: 'ECDH', namedCurve: 'P-256' },
    false,
    [],
  )
}

/** Wrap `contentKey` so only the holder of the private key matching
 * `ownerPublicKeyB64` can unwrap it, via one-shot ECDH between a fresh
 * ephemeral keypair and the owner's public key. The ephemeral public key
 * travels alongside the ciphertext - no separate publication needed.
 */
export async function wrapContentKeyForOwner(
  contentKey: CryptoKey,
  ownerPublicKeyB64: string,
): Promise<string> {
  const ownerPub = await importPublicKey(ownerPublicKeyB64)
  const ephemeral = await generateECDHKeyPair()

  const kek = await crypto.subtle.deriveKey(
    { name: 'ECDH', public: ownerPub } as EcdhKeyDeriveParams,
    ephemeral.privateKey,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt'],
  )

  const raw = await crypto.subtle.exportKey('raw', contentKey)
  const iv = crypto.getRandomValues(new Uint8Array(12))
  const ct = await crypto.subtle.encrypt({ name: 'AES-GCM', iv }, kek, raw)

  return JSON.stringify({
    pub: await exportPublicKey(ephemeral.publicKey),
    iv: b64(iv),
    ct: b64(ct),
  })
}

/** Reverse of wrapContentKeyForOwner - only succeeds with the owner private
 * key matching the public key the wrapping was originally done against.
 */
export async function unwrapContentKey(
  wrapped: string,
  ownerPrivateKey: CryptoKey,
): Promise<CryptoKey> {
  const { pub, iv, ct } = JSON.parse(wrapped)
  const peerPub = await importPublicKey(pub)

  const kek = await crypto.subtle.deriveKey(
    { name: 'ECDH', public: peerPub } as EcdhKeyDeriveParams,
    ownerPrivateKey,
    { name: 'AES-GCM', length: 256 },
    false,
    ['decrypt'],
  )

  const raw = await crypto.subtle.decrypt(
    { name: 'AES-GCM', iv: unb64(iv) },
    kek,
    unb64(ct),
  )
  return crypto.subtle.importKey('raw', raw, { name: 'AES-GCM' }, false, [
    'encrypt',
    'decrypt',
  ])
}

export interface EncryptedValue {
  __enc: 1
  iv: string
  ct: string
}

// Disambiguates from a legacy/legitimate plaintext answer that happens to be
// an object with keys named `iv`/`ct` - cheap insurance against a
// duck-typing false positive.
export function isEncryptedValue(value: any): value is EncryptedValue {
  return !!value && typeof value === 'object' && value.__enc === 1
}

export async function encryptValue(
  contentKey: CryptoKey,
  value: any,
): Promise<EncryptedValue> {
  const iv = crypto.getRandomValues(new Uint8Array(12))
  const plaintext = new TextEncoder().encode(JSON.stringify(value))
  const ct = await crypto.subtle.encrypt({ name: 'AES-GCM', iv }, contentKey, plaintext)
  return { __enc: 1, iv: b64(iv), ct: b64(ct) }
}

export async function decryptValue(
  contentKey: CryptoKey,
  envelope: EncryptedValue,
): Promise<any> {
  const plaintext = await crypto.subtle.decrypt(
    { name: 'AES-GCM', iv: unb64(envelope.iv) },
    contentKey,
    unb64(envelope.ct),
  )
  return JSON.parse(new TextDecoder().decode(plaintext))
}

// --- Chat message signing (authenticity, not confidentiality - see item D
// of the plan: chat stays readable by everyone in the room, this only
// stops one peer from writing a message that claims to be someone else). ---

export function generateSigningKeyPair(): Promise<CryptoKeyPair> {
  return crypto.subtle.generateKey({ name: 'ECDSA', namedCurve: 'P-256' }, true, [
    'sign',
    'verify',
  ])
}

async function importVerifyKey(publicKeyB64: string): Promise<CryptoKey> {
  return crypto.subtle.importKey(
    'spki',
    unb64(publicKeyB64),
    { name: 'ECDSA', namedCurve: 'P-256' },
    false,
    ['verify'],
  )
}

export interface ChatSignedPayload {
  message: string
  user: string
  ts: number
}

export async function signChatMessage(
  privateKey: CryptoKey,
  payload: ChatSignedPayload,
): Promise<string> {
  const bytes = new TextEncoder().encode(JSON.stringify(payload))
  const sig = await crypto.subtle.sign(
    { name: 'ECDSA', hash: 'SHA-256' },
    privateKey,
    bytes,
  )
  return b64(sig)
}

export async function verifyChatMessage(
  publicKeyB64: string,
  payload: ChatSignedPayload,
  signatureB64: string,
): Promise<boolean> {
  try {
    const key = await importVerifyKey(publicKeyB64)
    const bytes = new TextEncoder().encode(JSON.stringify(payload))
    return await crypto.subtle.verify(
      { name: 'ECDSA', hash: 'SHA-256' },
      key,
      unb64(signatureB64),
      bytes,
    )
  } catch (e) {
    return false
  }
}

// --- Owner-token proof-of-possession & password hint (see the classroom
// owner-election redesign: only the holder of the room's random owner
// secret may claim ownership - everyone else only ever sees its hash). ---

export function randomBytesBase64(byteLength: number): string {
  return b64(crypto.getRandomValues(new Uint8Array(byteLength)).buffer)
}

export async function sha256Base64(input: string): Promise<string> {
  const bytes = new TextEncoder().encode(input)
  return b64(await crypto.subtle.digest('SHA-256', bytes))
}

export const PBKDF2_ITERATIONS = 150000

export async function pbkdf2Base64(
  password: string,
  saltBase64: string,
  iterations: number = PBKDF2_ITERATIONS,
): Promise<string> {
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(password),
    'PBKDF2',
    false,
    ['deriveBits'],
  )
  const bits = await crypto.subtle.deriveBits(
    { name: 'PBKDF2', hash: 'SHA-256', salt: unb64(saltBase64), iterations },
    keyMaterial,
    256,
  )
  return b64(bits)
}

// A blank `expectedCheckBase64` means the room carries no password hint at
// all (a legacy link, or a room without a password) - nothing to check.
export async function verifyPasswordCheck(
  password: string,
  saltBase64: string,
  expectedCheckBase64: string,
  iterations: number = PBKDF2_ITERATIONS,
): Promise<boolean> {
  if (!expectedCheckBase64) return true
  const actual = await pbkdf2Base64(password, saltBase64, iterations)
  return actual === expectedCheckBase64
}
