const providers = require("./embed-providers.json");

type Params = {
  maxwidth?: number;
  maxheight?: number;
};

type Provider = {
  name: string;
  url: string;
  endpoint: string;
};

const fetchEmbed = async (url: string, provider: string, params: Params) => {
  let {
    name, // eslint-disable-line camelcase
    url, // eslint-disable-line camelcase
    endpoint: resourceUrl,
  } = provider;

  resourceUrl = resourceUrl.replace(/\{format\}/g, "json");

  let link = `${resourceUrl}?format=json&url=${encodeURIComponent(url)}`;

  link =
    params && params.maxwidth ? `${link}&maxwidth=${params.maxwidth}` : link;
  link =
    params && params.maxheight ? `${link}&maxheight=${params.maxheight}` : link;

  link = "https://api.allorigins.win/get?url=" + encodeURIComponent(link);

  const res = await fetch(link, { mode: "no-cors" });
  const json = await res.json();

  json.provider_name = provider_name; // eslint-disable-line camelcase
  json.provider_url = provider_url; // eslint-disable-line camelcase
  return json;
};

function isValidURL(str: string) {
  if (!str) {
    return false;
  }

  /* eslint-disable*/
  let pattern =
    /^(?:(?:https?|ftp):\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,}))\.?)(?::\d{2,5})?(?:[/?#]\S*)?$/i;
  /* eslint-enable*/

  return pattern.test(str);
}

function findProvider(url: string) {
  const candidates = providers.filter((provider: any) => {
    const { schemes, domain } = provider;
    if (!schemes.length) {
      return url.includes(domain);
    }
    return schemes.some((scheme) => {
      const reg = new RegExp(scheme.replace(/\*/g, "(.*)"), "i");
      return url.match(reg);
    });
  });

  return candidates.length > 0 ? candidates[0] : null;
}

async function extract(url: string, params) {
  if (!isValidURL(url)) {
    throw new Error("Invalid input URL");
  }
  const p = findProvider(url);
  if (!p) {
    throw new Error(`No provider found with given url "${url}"`);
  }
  const data = await fetchEmbed(url, p, params);
  return data;
}

function iframe(url: string) {
  return `<iframe src="${url}" style="width: 100%; height: inherit" allowfullscreen loading="lazy"></iframe>`;
}

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
            try {
              json = JSON.parse(json.contents);
              div.innerHTML = json.html;
            } catch (e) {
              div.innerHTML = iframe(this.url_);
            }
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
