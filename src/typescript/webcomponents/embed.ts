const providers = require("./embed-providers.json");

type Params = {
  maxwidth?: number;
  maxheight?: number;
};

type Provider = {
  name: string;
  url: string;
  endpoints: Endpoint[];
};

type Endpoint = {
  schemes?: string[];
  url: string;
  discovery?: boolean;
  formats?: string[];
};

function findProvider(link: string): Provider | undefined {
  const candidate = providers.find((provider: Provider) => {
    const { schemes, url } = provider.endpoints[0];

    if (!schemes || !schemes.length) {
      return url.includes(link);
    }

    return schemes.some((scheme) => {
      const reg = new RegExp(scheme.replace(/\*/g, "(?:.*)"), "i");

      return link.match(reg);
    });
  });

  return candidate;
}

async function fetchEmbed(
  link: string,
  provider: Provider,
  params: Params,
  prefix?: string
) {
  let resourceUrl = provider.endpoints[0].url;

  resourceUrl = resourceUrl.replace(/\{format\}/g, "json");

  let url = `${resourceUrl}?format=json&url=${encodeURIComponent(link)}`;

  url = params.maxwidth ? `${url}&maxwidth=${params.maxwidth}` : url;
  url = params.maxheight ? `${url}&maxheight=${params.maxheight}` : url;

  let res, json;

  if (prefix) {
    url = prefix + encodeURIComponent(url);

    res = await fetch(url);
    json = await res.text();
    json = JSON.parse(json);
    json = JSON.parse(json.contents);
  } else {
    res = await fetch(url);
    json = await res.json();
  }

  json.provider_name = provider.name; // eslint-disable-line camelcase
  json.provider_url = provider.url; // eslint-disable-line camelcase

  return json;
}

async function extract(link: string, params: Params) {
  const p = findProvider(link);

  if (!p) {
    throw new Error(`No provider found with given url "${link}"`);
  }
  let data;

  try {
    data = await fetchEmbed(link, p, params);
  } catch (error) {
    data = await fetchEmbed(
      link,
      p,
      params,
      "https://api.allorigins.win/get?url="
    );
  }

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
    private maxwidth_: number | undefined;
    private maxheight_: number | undefined;
    private thumbnail_: boolean;
    private paramCount: number;

    constructor() {
      super();

      this.url_ = null;

      this.div_ = document.createElement("div");
      this.div_.style.width = "inherit";
      this.div_.style.height = "inherit";
      this.div_.style.display = "inline-block";

      this.thumbnail_ = false;

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

        if (this.url_) {
          let url_ = this.url_;
          let thumbnail_ = this.thumbnail_;

          extract(url_, options)
            .then((json: any) => {
              try {
                if (thumbnail_ && json.thumbnail_url) {
                  div.innerHTML = `<img style="width: inherit; height: inherit; object-fit: cover" src="${json.thumbnail_url}"></img>`;
                } else {
                  div.innerHTML = json.html;
                }
              } catch (e) {
                div.innerHTML = iframe(url_);
              }
            })
            .catch((err: any) => {
              div.innerHTML = `<iframe src="${url_}" style="width: ${
                options.maxwidth ? options.maxwidth + "px" : "100%"
              }; height: ${
                options.maxheight ? options.maxheight + "px" : "inherit"
              };" allowfullscreen loading="lazy"></iframe>`;
            });
        }
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

    get thumbnail() {
      return this.thumbnail_;
    }

    set thumbnail(value: boolean) {
      this.thumbnail_ = value;
    }
  }
);
