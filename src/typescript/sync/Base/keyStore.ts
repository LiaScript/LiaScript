import Database from '../../liascript/service/Database'

/** Reuses whatever was stored under `id` across reconnects (Web Crypto
 * `CryptoKey`/`CryptoKeyPair` objects are directly structured-cloneable, no
 * serialization needed) rather than generating fresh key material every
 * time - a reconnect (needed today to apply any classroom config change,
 * including switching mode) must not strand data already encrypted under a
 * key that then gets thrown away.
 *
 * Used for both the classroom owner's ECDH keypair (id: roomId) and each
 * peer's own AES content key (id: `${roomId}:content:${peerID}`). Stored via
 * the connector's own per-course Dexie database, not a separate raw
 * IndexedDB database - a standalone `indexedDB.open()` here would trip the
 * `patches/dexie+4.2.1.patch` security guard, and worse, whitelisting an
 * extra database name by itself only gates the first `open()` call: once
 * approved, any same-origin script (including untrusted course-authored
 * ones - LiaScript courses can run JS with no origin isolation) could open
 * it too and read these extractable keys straight out.
 *
 * @param uidDB - identifies the course's local database, see `LiaDB.getKey`/`putKey`
 */
export async function getOrCreateKey<T>(
  uidDB: string,
  id: string,
  generate: () => Promise<T>,
): Promise<T> {
  try {
    const existing = await Database.getKey(uidDB, id)

    if (existing) return existing

    const value = await generate()

    await Database.putKey(uidDB, id, value)

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
