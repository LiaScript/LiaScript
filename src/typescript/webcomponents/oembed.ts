import {
  extract,
} from 'oembed-parser';

customElements.define(
  'oembed-element',
  class extends HTMLElement {
    constructor() {
      super()
    }

    connectedCallback() {
      let shadowRoot = this.attachShadow({
        mode: 'closed',
      })
      const urlAttr = this.getAttribute('url')

      const span = document.createElement('span')

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
          span.innerHTML = `<iframe src="${urlAttr}" style="width: 100%; height: 60vh;"></iframe>`

          console.warn(err);
        });
      }
    }
  },
)

