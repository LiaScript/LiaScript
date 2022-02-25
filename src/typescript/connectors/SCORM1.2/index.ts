import { SCORM } from './scorm'

import * as Base from '../Base/index'

/**
 * A simple json-parser that does not trow an error, but returns null if it fails
 * @param string - a valid JSON representation
 */
function jsonParse(json: string) {
  try {
    return JSON.parse(json)
  } catch (e) {}
  return null
}

/**
 * This is a very simplistic Connector, that does only store the current slide
 * position and restore it, if necessary. SCORM 1.2 is in many ways simply to
 * restrictive.
 *
 * @see <https://scorm.com/scorm-explained/technical-scorm/run-time/run-time-reference/#section-2>
 */
class Connector extends Base.Connector {
  private scorm?: SCORM
  private location: number | null

  constructor() {
    super()

    console.warn(
      `Hello, this is LiaScript from within a SCORM 1.2 package. You should definitely try out the SCORM 2004 exporter, since this one cannot be used to store states or any kind of progress. The only thing that is stores, is currently the user location...

IF YOU ARE AN ELABORATE AND EXPERIENCED SCORM DEVELOPER?
========================================================

And you want to help us, to extend this service, please contact us via LiaScript@web.de

Hava fun ;-)`
    )

    if (window.top && window.top.API) {
      this.scorm = window.top.API

      console.log('LMSInitialize', this.scorm.LMSInitialize(''))

      this.location = jsonParse(
        this.scorm.LMSGetValue('cmi.core.lesson_location')
      )

      // if no location has been stored so far, this is the first visit
      if (this.location === null) {
        this.slide(0)
      }
    }
  }

  /**
   * This module does nothing at the moment, it is only used to indicate that
   * the course is now ready. If so, we will open the last visited slide.
   */
  open(_uri: string, _version: number, _slide: number) {
    if (this.location !== null) window.LIA.goto(this.location)
  }

  slide(id: number): void {
    this.location = id

    if (this.scorm) {
      this.scorm.LMSSetValue('cmi.core.lesson_location', JSON.stringify(id))
      this.scorm.LMSCommit('')
    }
  }

  countInteractions(): number | null {
    if (!this.scorm) return

    let value = parseInt(this.scorm.LMSGetValue('cmi.interactions._count'))

    return value ? value : null
  }

  setInteraction(id: number, content: string) {
    if (!this.scorm) return

    if (content.length <= 256) {
      this.scorm.LMSSetValue(`cmi.interactions.${id}.id`, content)
      return true
    }

    this.scorm.LMSSetValue(
      `cmi.interactions.${id}.id`,
      'Objective could not be stored, content exceeds 256Bytes!'
    )
    return false
  }
}

export { Connector }
