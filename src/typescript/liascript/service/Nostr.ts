var elmSend: Lia.Send | null
var nostr: any = undefined
const defaultRelays = [
  'wss://relay.damus.io',
  'wss://relay.nostr.band',
  'wss://nos.lol',
]

const Service = {
  PORT: 'nostr',

  init: function (elmSend_: Lia.Send) {
    elmSend = elmSend_
  },

  handle: async function (event: Lia.Event, reload = false) {
    if (!nostr) {
    }

    switch (event.message.cmd) {
      case 'load': {
        if (nostr === undefined) {
          await loadNostrTools()
        }

        if (nostr === null) {
          failure(event, 'nostr is not initialized')
          return
        }

        const uri = event.message.param.uri

        try {
          // Parse the URI to get the Nostr identifier
          const identifier = uri.substring(6) // Remove 'nostr:'

          const decoded = nostr.nip19.decode(identifier)

          switch (decoded.type) {
            case 'note': {
              break
            }
            case 'nevent': {
              fetchNostrEvent(event, decoded)
              break
            }
            case 'naddr': {
              fetchNostrNaddr(event, decoded)
              break
            }
            default: {
              failure(event, 'unknown type ' + decoded.type)
            }
          }
        } catch (error) {
          console.error('Error processing Nostr URI:', error)
        }

        break
      }
    }
  },
}

function failure(event: Lia.Event, message: string) {
  console.warn('Nostr: failure =>', message)
  event.message.param.data = {
    ok: false,
    body: message,
  }

  send(event)
}

function send(event: Lia.Event) {
  if (elmSend) {
    elmSend(event)
  }
}

async function loadNostrTools() {
  try {
    const importPromise = new Promise((resolve, reject) => {
      const timeoutId = setTimeout(() => {
        reject(new Error('Import timed out - possible CORS issue'))
      }, 5000)

      window['_tempNostrResolve'] = resolve
      window['_tempNostrReject'] = reject
      window['_tempNostrTimeoutId'] = timeoutId

      window.eval(`
        import('https://esm.sh/nostr-tools@1.17.0')
          .then(module => {
            window._tempNostrModule = module;
            clearTimeout(window._tempNostrTimeoutId);
            window._tempNostrResolve(module);
          })
          .catch(error => {
            clearTimeout(window._tempNostrTimeoutId);
            window._tempNostrReject(error);
          });
      `)
    })

    await importPromise
    nostr = window['_tempNostrModule']

    delete window['_tempNostrModule']
    delete window['_tempNostrResolve']
    delete window['_tempNostrReject']
    delete window['_tempNostrTimeoutId']

    if (
      !nostr ||
      !nostr['nip19'] ||
      typeof nostr['nip19'].decode !== 'function'
    ) {
      nostr = null
      console.warn('Nostr failure: Invalid nostr-tools module structure')
    }

    console.log('Nostr-tools loaded successfully')
  } catch (e) {
    nostr = null
    console.warn('Nostr failure: loading nostr-tools ->', e.message)
  }
}

async function fetchNostrEvent(event, decoded) {
  const eventId = decoded.data.id
  const relayUrls = decoded.data.relays || defaultRelays

  const pool = new nostr.SimplePool()

  let timeoutId = setTimeout(() => {
    pool.close(relayUrls)
    event.message.param.data = {
      ok: false,
      body: 'Timeout fetching Nostr event',
    }
    if (elmSend) {
      elmSend(event)
    }
  }, 10000)

  console.log('Fetching event', eventId, 'from relays', relayUrls)

  const fetchedEvent = await pool.get(relayUrls, {
    ids: [eventId],
  })

  clearTimeout(timeoutId)

  pool.close(relayUrls)

  if (!fetchedEvent) {
    failure(event, 'Event not found on specified relays')
    return
  }
  console.log('Successfully fetched event:', fetchedEvent.content)
  event.message.param.data = { ok: true, body: fetchedEvent.content }
  send(event)
}

async function fetchNostrNaddr(event, decoded) {
  const pool = new nostr.SimplePool()

  let timeoutId = setTimeout(() => {
    pool.close(decoded.data.relays)
    failure(event, 'Timeout fetching Nostr addressable content')
  }, 10000)

  console.log(
    'Fetching naddr content from relays',
    decoded.data.relays,
    'with filter:',
    {
      kinds: [decoded.data.kind],
      authors: [decoded.data.pubkey],
      '#d': [decoded.data.identifier],
    }
  )

  const fetchedEvent = await pool.get(decoded.data.relays, {
    kinds: [decoded.data.kind],
    authors: [decoded.data.pubkey],
    '#d': [decoded.data.identifier],
  })

  clearTimeout(timeoutId)
  pool.close(decoded.data.relays)

  if (!fetchedEvent) {
    failure(event, 'Addressable content not found on specified relays')
    return
  }

  console.log('Fetched naddr content:', fetchedEvent.content)
  event.message.param.data = { ok: true, body: fetchedEvent.content }
  send(event)
}

async function fetchNostrNote(event, decoded) {
  // For note type, decoded.data is directly the event ID
  const eventId = decoded.data

  const pool = new nostr.SimplePool()

  // Set timeout to prevent hanging if relays don't respond
  let timeoutId = setTimeout(() => {
    pool.close(defaultRelays)
    event.message.param.data = {
      ok: false,
      body: 'Timeout fetching Nostr note',
    }
    if (elmSend) {
      elmSend(event)
    }
  }, 10000)

  console.log('Fetching note', eventId, 'from relays', defaultRelays)

  try {
    const fetchedEvent = await pool.get(defaultRelays, {
      ids: [eventId],
    })

    clearTimeout(timeoutId)
    pool.close(defaultRelays)

    if (!fetchedEvent) {
      failure(event, 'Note not found on specified relays')
      return
    }

    console.log('Successfully fetched note:', fetchedEvent.content)
    event.message.param.data = { ok: true, body: fetchedEvent.content }
    send(event)
  } catch (error) {
    clearTimeout(timeoutId)
    pool.close(defaultRelays)
    failure(event, `Error fetching note: ${error.message}`)
  }
}

export default Service
