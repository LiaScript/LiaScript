import { LiaScript as Base } from '../../typescript/liascript/index'

require('../../scss/main.scss')

import(
  '../../../node_modules/@webcomponents/webcomponentsjs/webcomponents-bundle.js'
)

import('../../typescript/webcomponents/chart')
import('../../typescript/webcomponents/embed/index')
import('../../typescript/webcomponents/editor')
import('../../typescript/webcomponents/format')
import('../../typescript/webcomponents/formula')
import('../../typescript/webcomponents/preview-lia')
import('../../typescript/webcomponents/terminal.ts')
import('../../typescript/webcomponents/tooltip/index')

import { allowedProtocol } from '../../typescript/helper'

window['LiaScript'] = class LiaScript {
  private app?: Base
  private debug: boolean
  private allowSync: boolean
  private hideURL: boolean
  private allowBrowserStorage: boolean

  constructor(config?: {
    debug?: boolean
    hideURL?: boolean
    allowSync?: boolean
    allowBrowserStorage?: boolean
  }) {
    this.debug = config?.debug || false
    this.hideURL = config?.hideURL || true
    this.allowSync = config?.allowSync || false
    this.allowBrowserStorage = config?.allowBrowserStorage || false
  }

  async loadString(content: string) {
    this.__load(null, content)
  }

  loadUrl(url: string) {
    if (typeof url === 'string' && !allowedProtocol(url)) {
      url = new URL(url, document.location.href).href
    }

    this.__load(url, null)
  }

  async __load(url: string | null, code: string | null) {
    const { Connector } = await (this.allowBrowserStorage
      ? import('../../typescript/connectors/Browser/index')
      : import('../../typescript/connectors/Base/index'))

    this.app = new Base(
      new Connector(),
      this.allowSync,
      this.debug,
      url,
      code,
      this.hideURL
    )
  }
}
