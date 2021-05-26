import { extract, setProviderList } from "oembed-parser";

const providers = require("./embed-providers.json");

setProviderList(providers);

customElements.define(
  "lia-embed",
  class extends HTMLElement {
    private url_: string | null;
    private div_: HTMLDivElement;
    private maxwidth_: number | null;
    private maxheight_: number | null;
    private paramCount: number;

    constructor() {
      super();

      this.url_ = null;

      this.div_ = document.createElement("div");
      this.div_.style.width = "inherit";
      this.div_.style.height = "inherit";
      this.div_.style.display = "inline-block";

      this.maxheight_ = null;
      this.maxwidth_ = null;

      this.paramCount = 0;
    }

    connectedCallback() {
      let shadowRoot = this.attachShadow({
        mode: "closed",
      });

      shadowRoot.appendChild(this.div_);

      const container = this.parentElement; // document.getElementsByClassName("lia-slide__content")[0]

      let scale = parseFloat(this.getAttribute("scale") || "0.674");

      if (container) {
        const paddingLeft = parseInt(
          window
            .getComputedStyle(container)
            .getPropertyValue("padding-left")
            .replace("px", "")
        );

        this.maxwidth_ =
          this.maxwidth_ != null
            ? this.maxwidth_
            : container.clientWidth - paddingLeft - 30;
        this.maxheight_ =
          this.maxheight_ != null
            ? this.maxheight_
            : Math.floor(this.maxwidth_ * (scale || 0.674));

        if (this.maxheight_ > screen.availHeight) {
          this.maxheight_ = Math.floor(screen.availHeight * (scale || 0.76));
        }
      }

      this.render();
    }

    render() {
      if (this.paramCount > 2) {
        let div = this.div_;
        let options = {
          maxwidth: this.maxwidth_,
          maxheight: this.maxheight_,
        };

        extract(this.url_, options)
          .then((json: any) => {
            div.innerHTML = json.html;
          })
          .catch((err: any) => {
            div.innerHTML = `<iframe src="${this.url_}" style="width: ${
              options.maxwidth ? options.maxwidth + "px" : "100%"
            }; height: ${
              options.maxheight ? options.maxheight + "px" : "inherit"
            };" allowfullscreen loading="lazy"></iframe>`;
          });
      }
    }

    get url() {
      return this.url_;
    }

    set url(value) {
      if (this.url_ !== value) {
        this.url_ = value;
        this.paramCount++;
        this.render();
      }
    }

    get maxheight() {
      return this.maxheight_;
    }

    set maxheight(value) {
      if (this.maxheight_ !== value) {
        this.paramCount++;
        if (value != 0) {
          this.maxheight_ = value;
        }
      }
    }

    get maxwidth() {
      return this.maxwidth_;
    }

    set maxwidth(value) {
      if (this.maxwidth_ !== value) {
        this.paramCount++;
        if (value != 0) {
          this.maxwidth_ = value;
        }
      }
    }
  }
);
