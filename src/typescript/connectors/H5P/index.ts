import Lia from '../../liascript/types/lia.d'

import * as XAPI from '../XAPI/index'
import { Settings } from '../Base/settings'
import * as Utils from '../utils'

/**
 * H5P Connector for LiaScript
 *
 * This connector extends the xAPI connector to provide H5P-specific
 * functionality while maintaining full xAPI tracking capabilities.
 *
 * H5P content can be tracked via xAPI statements, making this connector
 * a specialized xAPI implementation for H5P environments.
 */
export class Connector extends XAPI.Connector {
  private h5pConfig: any
  private h5pInitialized: boolean

  /**
   * Create a new H5P connector
   * @param config Configuration options for the connector
   */
  constructor(
    config: {
      courseId?: string
      courseTitle?: string
      debug?: boolean
      endpoint?: string
      auth?: string
      actor?: any
      registration?: string
      masteryThreshold?: number
      progressThreshold?: number
    } = {}
  ) {
    // Initialize H5P configuration from window object
    const h5pConfig = (window as any)['h5pConfig'] || {}

    // Merge H5P config with provided config
    const xapiConfig = {
      endpoint: config.endpoint || h5pConfig.endpoint,
      auth: config.auth || h5pConfig.auth,
      actor: config.actor || h5pConfig.actor,
      courseId: config.courseId || h5pConfig.courseId || window.location.href,
      courseTitle:
        config.courseTitle ||
        h5pConfig.courseTitle ||
        document.title ||
        'LiaScript Course',
      registration: config.registration || h5pConfig.registration,
      debug: config.debug || h5pConfig.debug || false,
      masteryThreshold: config.masteryThreshold || h5pConfig.masteryThreshold,
      progressThreshold:
        config.progressThreshold || h5pConfig.progressThreshold,
    }

    // Initialize parent xAPI connector with merged config
    super(xapiConfig)

    // Store H5P-specific configuration
    this.h5pConfig = h5pConfig
    this.h5pInitialized = false

    if (xapiConfig.debug) {
      console.log('H5P connector initialized with config:', {
        h5p: this.h5pConfig,
        xapi: xapiConfig,
      })
    }

    // Set up H5P xAPI event listeners if H5P is available
    this.initializeH5PListeners()
  }

  /**
   * Initialize H5P-specific xAPI event listeners
   * This connects H5P's internal xAPI events to our connector
   */
  private initializeH5PListeners() {
    // Wait for H5P to be available
    if (typeof window !== 'undefined' && (window as any).H5P) {
      this.setupH5PEventHandlers()
    } else {
      // Poll for H5P availability
      const checkH5P = setInterval(() => {
        if ((window as any).H5P) {
          clearInterval(checkH5P)
          this.setupH5PEventHandlers()
        }
      }, 100)

      // Stop polling after 10 seconds
      setTimeout(() => clearInterval(checkH5P), 10000)
    }
  }

  /**
   * Set up H5P xAPI event handlers
   */
  private setupH5PEventHandlers() {
    const H5P = (window as any).H5P
    if (!H5P || !H5P.externalDispatcher) {
      console.warn('H5P.externalDispatcher not available')
      return
    }

    this.h5pInitialized = true

    // Listen to H5P xAPI events
    H5P.externalDispatcher.on('xAPI', (event: any) => {
      if (this.h5pConfig.debug) {
        console.log('H5P xAPI event received:', event)
      }

      // Forward H5P xAPI events to our LRS
      // The event.data.statement contains the xAPI statement
      if (event.data && event.data.statement) {
        this.handleH5PStatement(event.data.statement, event)
      }
    })

    if (this.h5pConfig.debug) {
      console.log('H5P xAPI event listeners initialized')
    }
  }

  /**
   * Handle H5P xAPI statements
   * Processes and potentially modifies H5P statements before sending to LRS
   */
  private handleH5PStatement(statement: any, event: any) {
    // H5P generates its own xAPI statements
    // We can enhance them with additional context or forward them as-is

    // Add registration if available
    if (this.h5pConfig.registration && !statement.context) {
      statement.context = { registration: this.h5pConfig.registration }
    } else if (this.h5pConfig.registration && statement.context) {
      statement.context.registration = this.h5pConfig.registration
    }

    // Add course context
    if (!statement.context) {
      statement.context = {}
    }
    if (!statement.context.contextActivities) {
      statement.context.contextActivities = {}
    }
    if (!statement.context.contextActivities.parent) {
      statement.context.contextActivities.parent = [
        {
          id: this.h5pConfig.courseId || window.location.href,
          definition: {
            name: {
              'en-US':
                this.h5pConfig.courseTitle ||
                document.title ||
                'LiaScript Course',
            },
            type: 'http://adlnet.gov/expapi/activities/course',
          },
        },
      ]
    }

    // Send to LRS (parent class method)
    // Note: We'd need to expose a method in XAPI connector to send custom statements
    if (this.h5pConfig.debug) {
      console.log('Processed H5P statement:', statement)
    }
  }

  /**
   * Open a course and initialize tracking
   * Extends parent xAPI implementation with H5P-specific logic
   * @param uidDB Course ID
   * @param versionDB Course version
   * @param slide Initial slide number
   */
  async open(uidDB: string, versionDB: number, slide: number) {
    // Call parent xAPI implementation
    await super.open(uidDB, versionDB, slide)

    if (this.h5pConfig.debug) {
      console.log('H5P connector opened course:', uidDB, 'version:', versionDB)
    }

    // H5P-specific initialization can go here if needed
    // The parent xAPI connector already handles most tracking
  }

  /**
   * Track slide navigation
   * Extends parent xAPI implementation
   * @param id Slide number
   */
  async slide(id: number) {
    // Call parent xAPI implementation (sends xAPI statements)
    await super.slide(id)

    // H5P-specific slide tracking can go here if needed
    if (this.h5pConfig.debug) {
      console.log('H5P connector tracking slide:', id)
    }
  }

  /**
   * Store data (quiz, survey, task)
   * Extends parent xAPI implementation
   * @param record Record to store
   */
  store(record: any) {
    // Call parent xAPI implementation (handles xAPI statements)
    super.store(record)

    // H5P-specific storage logic can go here if needed
    if (this.h5pConfig.debug && record.table) {
      console.log('H5P connector storing data:', record.table, record.id)
    }
  }

  /**
   * Update data
   * Extends parent xAPI implementation
   * @param record Record to update
   * @param fn Update function
   */
  update(record: any, fn: (a: any) => any) {
    // Call parent xAPI implementation
    super.update(record, fn)

    // H5P-specific update logic can go here if needed
  }

  /**
   * Get settings
   * Uses parent xAPI implementation
   * @returns Settings object
   */
  getSettings() {
    return super.getSettings()
  }

  /**
   * Set settings
   * Uses parent xAPI implementation
   * @param data Settings data
   */
  setSettings(data: Lia.Settings) {
    super.setSettings(data)
  }

  /**
   * Reset the connector
   * Extends parent xAPI implementation
   * @param uidDB Course ID
   * @param versionDB Course version
   */
  reset(uidDB?: string, versionDB?: number) {
    // Call parent xAPI implementation
    super.reset(uidDB, versionDB)

    if (this.h5pConfig.debug) {
      console.log('H5P connector reset')
    }
  }
}
