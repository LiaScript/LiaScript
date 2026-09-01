const DB_NAME = 'lia-classroom-keys'
const STORE = 'keys'

function openDB(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, 1)
    req.onupgradeneeded = () => {
      req.result.createObjectStore(STORE)
    }
    req.onsuccess = () => resolve(req.result)
    req.onerror = () => reject(req.error)
  })
}

/** Reuses whatever was stored under `id` across reconnects (Web Crypto
 * `CryptoKey`/`CryptoKeyPair` objects are directly structured-cloneable, no
 * serialization needed) rather than generating fresh key material every
 * time - a reconnect (needed today to apply any classroom config change,
 * including switching mode) must not strand data already encrypted under a
 * key that then gets thrown away.
 *
 * Used for both the classroom owner's ECDH keypair (id: roomId) and each
 * peer's own AES content key (id: `${roomId}:content:${peerID}`).
 */
export async function getOrCreateKey<T>(
  id: string,
  generate: () => Promise<T>,
): Promise<T> {
  try {
    const db = await openDB()

    const existing = await new Promise<T | undefined>((resolve, reject) => {
      const tx = db.transaction(STORE, 'readonly')
      const req = tx.objectStore(STORE).get(id)
      req.onsuccess = () => resolve(req.result)
      req.onerror = () => reject(req.error)
    })

    if (existing) return existing

    const value = await generate()

    await new Promise<void>((resolve, reject) => {
      const tx = db.transaction(STORE, 'readwrite')
      tx.objectStore(STORE).put(value, id)
      tx.oncomplete = () => resolve()
      tx.onerror = () => reject(tx.error)
    })

    return value
  } catch (e) {
    // IndexedDB unavailable (private browsing, etc.) - fall back to a
    // session-only key rather than failing the whole feature. Data written
    // under it becomes unreadable after a reconnect in that case, same as
    // before this store existed.
    console.warn('keyStore: falling back to session-only key ->', e)
    return generate()
  }
}
