import {
  extract,
  setProviderList
} from 'oembed-parser';

const providers = require('./embed-providers.json');

setProviderList(providers)

customElements.define(
  'lia-embed',
  class extends HTMLElement {
    constructor() {
      super()
    }

    connectedCallback() {
      let shadowRoot = this.attachShadow({
        mode: 'closed',
      })
      const urlAttr = this.getAttribute('url')

      const span = document.createElement('div')
      span.style.width = "inherit"
      span.style.height = "inherit"
      span.style.display = "inline-block"
      span.style.maxHeight = "60vh"

      shadowRoot.appendChild(span)

      if (urlAttr) {
        let options = null

        try {
          const container = document.getElementsByClassName("lia-slide__content")[0]

          const paddingLeft = parseInt(window.getComputedStyle(container).getPropertyValue('padding-left').replace("px", ""))

          options = { 
            maxwidth: container.clientWidth - paddingLeft - 30,
            maxheight: Math.floor(container.clientHeight * 0.6)
          }
        } catch (e) {}

        extract(urlAttr, options)
        .then((json: any) => {
          span.innerHTML = json.html
        })
        .catch((err: any) => {
          span.innerHTML = `<iframe src="${urlAttr}" style="border: none; width: 100%; height: inherit;" allowfullscreen loading="lazy"></iframe>`

          console.warn(err);
        });
      }
    }
  },
)

