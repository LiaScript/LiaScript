/**
 * Utilities for communicating with a Learning Record Store (LRS)
 */

export class LRSConnection {
  private endpoint: string
  private auth: string
  private version: string
  private debug: boolean

  /**
   * Create a new LRS connection
   * @param endpoint The LRS endpoint URL
   * @param auth The authentication string (e.g., "Basic " + btoa("username:password"))
   * @param version The xAPI version (default: "1.0.3")
   * @param debug Whether to enable debug logging (default: false)
   */
  constructor(
    endpoint: string,
    auth: string,
    version: string = '1.0.3',
    debug: boolean = false
  ) {
    // Ensure endpoint ends with a slash
    this.endpoint = endpoint.endsWith('/') ? endpoint : endpoint + '/'
    this.auth = auth
    this.version = version
    this.debug = debug
  }

  /**
   * Send a statement to the LRS
   * @param statement The xAPI statement to send
   * @returns Promise resolving to the statement ID
   */
  async sendStatement(statement: any): Promise<string | null> {
    try {
      if (this.debug) {
        console.log(
          'Sending statement to LRS:',
          JSON.stringify(statement, null, 2)
        )
      }

      const response = await fetch(this.endpoint + 'statements', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Experience-API-Version': this.version,
          Authorization: this.auth,
        },
        body: JSON.stringify(statement),
      })

      if (!response.ok) {
        console.error('LRS error:', response.status, response.statusText)
        return null
      }

      const data = await response.json()

      if (this.debug) {
        console.log('LRS response:', data)
      }

      return data.id || null
    } catch (error) {
      console.error('Error sending statement to LRS:', error)
      return null
    }
  }

  /**
   * Send multiple statements to the LRS
   * @param statements Array of xAPI statements to send
   * @returns Promise resolving to an array of statement IDs
   */
  async sendStatements(statements: any[]): Promise<string[]> {
    try {
      if (this.debug) {
        console.log(
          'Sending statements to LRS:',
          JSON.stringify(statements, null, 2)
        )
      }

      const response = await fetch(this.endpoint + 'statements', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Experience-API-Version': this.version,
          Authorization: this.auth,
        },
        body: JSON.stringify(statements),
      })

      if (!response.ok) {
        console.error('LRS error:', response.status, response.statusText)
        return []
      }

      const data = await response.json()

      if (this.debug) {
        console.log('LRS response:', data)
      }

      return Array.isArray(data) ? data : []
    } catch (error) {
      console.error('Error sending statements to LRS:', error)
      return []
    }
  }

  /**
   * Get statements from the LRS
   * @param query Query parameters for filtering statements
   * @returns Promise resolving to the statements
   */
  async getStatements(query: Record<string, string> = {}): Promise<any> {
    try {
      const queryString = Object.entries(query)
        .map(
          ([key, value]) =>
            `${encodeURIComponent(key)}=${encodeURIComponent(value)}`
        )
        .join('&')

      const url =
        this.endpoint + 'statements' + (queryString ? `?${queryString}` : '')

      if (this.debug) {
        console.log('Getting statements from LRS:', url)
      }

      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'X-Experience-API-Version': this.version,
          Authorization: this.auth,
        },
      })

      if (!response.ok) {
        console.error('LRS error:', response.status, response.statusText)
        return null
      }

      const data = await response.json()

      if (this.debug) {
        console.log('LRS response:', data)
      }

      return data
    } catch (error) {
      console.error('Error getting statements from LRS:', error)
      return null
    }
  }

  /**
   * Test the LRS connection
   * @returns Promise resolving to true if connection is successful
   */
  async testConnection(): Promise<boolean> {
    try {
      const response = await fetch(this.endpoint + 'about', {
        method: 'GET',
        headers: {
          'X-Experience-API-Version': this.version,
          Authorization: this.auth,
        },
      })

      return response.ok
    } catch (error) {
      console.error('Error testing LRS connection:', error)
      return false
    }
  }
}
