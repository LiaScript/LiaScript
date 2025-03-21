/**
 * Utilities for communicating with a Learning Record Store (LRS)
 */

export class LRSConnection {
  public endpoint: string
  public auth: string
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
    this.endpoint = endpoint + (endpoint.endsWith('/') ? '' : '/')
    this.auth = auth
    this.version = version
    this.debug = debug

    if (this.debug) {
      console.log('LRS endpoint configured as:', this.endpoint)
    }
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

      // Ensure all object references are properly stringified
      const processedStatement = this.ensureStringReferences(statement)

      const response = await fetch(this.endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Experience-API-Version': this.version,
          Authorization: this.auth,
        },
        body: JSON.stringify(processedStatement),
      })

      if (!response.ok) {
        console.error('LRS error:', response.status, await response.text())
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

      // Ensure all object references are properly stringified
      const processedStatements = statements.map((statement) =>
        this.ensureStringReferences(statement)
      )

      const response = await fetch(this.endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Experience-API-Version': this.version,
          Authorization: this.auth,
        },
        body: JSON.stringify(processedStatements),
      })

      if (!response.ok) {
        console.error('LRS error:', response.status, await response.text())
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

      const url = this.endpoint + (queryString ? `?${queryString}` : '')

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
        console.error('LRS error:', response.status, await response.text())
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
      // For SCORM Cloud, we need to use a different endpoint for testing
      let testEndpoint = this.endpoint
      if (testEndpoint.includes('api/v2/statements')) {
        testEndpoint = testEndpoint.replace('api/v2/statements', 'api/v2/about')
      } else if (testEndpoint.endsWith('/statements')) {
        testEndpoint = testEndpoint.replace('/statements', '/about')
      }

      const response = await fetch(testEndpoint, {
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

  /**
   * Ensure all object references in a statement are properly stringified
   * @param obj The object to process
   * @returns The processed object with stringified references
   */
  private ensureStringReferences(obj: any): any {
    if (obj === null || obj === undefined) {
      return obj
    }

    if (typeof obj === 'object') {
      if (Array.isArray(obj)) {
        return obj.map((item) => this.ensureStringReferences(item))
      } else {
        const result: any = {}
        for (const key in obj) {
          if (Object.prototype.hasOwnProperty.call(obj, key)) {
            result[key] = this.ensureStringReferences(obj[key])
          }
        }
        return result
      }
    } else if (typeof obj === 'function') {
      return obj.toString()
    } else {
      return obj
    }
  }
}
