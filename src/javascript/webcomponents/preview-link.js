function fetch (self, trial = 0) {
  var http = new XMLHttpRequest();

  http.open("GET", self._src, true);
  http.setRequestHeader('User-Agent','bla');

  http.onload = function(e) {

    if (http.readyState == 4 && http.status == 200) {
      try {
        self.parse(http.responseText)
      } catch (e) {
        console.warn("fetching", e);
      }
    }
    http = null;
  }

  http.onerror = function(e) {
    if (trial == 0) {
      self._src = `https://cors-anywhere.herokuapp.com/${self._src}`
      fetch(self, 1)
    }
  }
  http.send();
}

customElements.define('preview-link', class extends HTMLElement {
  constructor () {
    super()

    const template = document.createElement('template');

    template.innerHTML = `
    <style></style>
    <div id="container" style="display: inline"></div>
    `;

    this._shadowRoot = this.attachShadow({ mode: 'open' });
    this._shadowRoot.appendChild(template.content.cloneNode(true));
  }

  connectedCallback () {
    this._src = this.getAttribute('src')

    let div = this._shadowRoot.getElementById("container")

    div.innerHTML = `<a href="${this._src}">preview-lidddnk</a>`

    let self = this
    fetch(self)
  }

  disconnectedCallback () {
    if (super.disconnectedCallback) {
      super.disconnectedCallback()
    }
  }

  parse(index) {
    try {
      index = index.match(/<head>(.|\n)*=?<\/head>/m)[0] // search head
                   .replaceAll(/<!--(.|\n)*=?-->/g, "")  // replace comments

      let og = this.parse_og(index)

    } catch (e) {

    } finally {

    }
    console.warn("----------------------", index);
  }

  parse_og(index) {
    let list = [
      "description",
      "image",
      "title",
      "type",
      "url",
    ]

    let og = {}
    for (e in list) {
      try {
        og[e] = index.match(/<meta\w*property="og:/g)
      } catch (e) {

      }
    }
  }
})


/*






<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
  <link rel="dns-prefetch" href="https://github.githubassets.com">
  <link rel="dns-prefetch" href="https://avatars0.githubusercontent.com">
  <link rel="dns-prefetch" href="https://avatars1.githubusercontent.com">
  <link rel="dns-prefetch" href="https://avatars2.githubusercontent.com">
  <link rel="dns-prefetch" href="https://avatars3.githubusercontent.com">
  <link rel="dns-prefetch" href="https://github-cloud.s3.amazonaws.com">
  <link rel="dns-prefetch" href="https://user-images.githubusercontent.com/">



  <link crossorigin="anonymous" media="all" integrity="sha512-ekFX2g7PYIGaDbomaCyqrqMzsSWXkrjcUDfW22m+AKcTx57MRDeT+0boW84wloPSnmOxOBEQcB89vNK3PjVaWg==" rel="stylesheet" href="https://github.githubassets.com/assets/frameworks-7a4157da0ecf60819a0dba26682caaae.css" />
  <link crossorigin="anonymous" media="all" integrity="sha512-UAB+zamhynzlpuXnpw73fw/BBB7mSmoD5bmdzbInf6YM1/Csnq+pdyOYFvmZWsm70H08nPhrK3xEpg3KLOr54g==" rel="stylesheet" href="https://github.githubassets.com/assets/site-50007ecda9a1ca7ce5a6e5e7a70ef77f.css" />
    <link crossorigin="anonymous" media="all" integrity="sha512-0HfmOetbpC7eoN1tKWhiufvCpydlKdwx0bWhx/2i8E402ZZSGnsXWwca1Uky0QAjZ6kfn1z/kjRfKo5B8GkyDw==" rel="stylesheet" href="https://github.githubassets.com/assets/github-d077e639eb5ba42edea0dd6d296862b9.css" />






  <meta name="viewport" content="width=device-width">

  <title>GitHub - LiaScript/LiaScript-Exporter: A simple module to export LiaScript docs into other formats...</title>
    <meta name="description" content="A simple module to export LiaScript docs into other formats... - LiaScript/LiaScript-Exporter">
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub">
  <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub">
  <meta property="fb:app_id" content="1401488693436528">
  <meta name="apple-itunes-app" content="app-id=1477376905">

    <meta name="twitter:image:src" content="https://repository-images.githubusercontent.com/252826941/cdf2c380-e6f0-11ea-9424-0b4e183baff6" /><meta name="twitter:site" content="@github" /><meta name="twitter:card" content="summary_large_image" /><meta name="twitter:title" content="LiaScript/LiaScript-Exporter" /><meta name="twitter:description" content="A simple module to export LiaScript docs into other formats... - LiaScript/LiaScript-Exporter" />
    <meta property="og:image" content="https://repository-images.githubusercontent.com/252826941/cdf2c380-e6f0-11ea-9424-0b4e183baff6" /><meta property="og:site_name" content="GitHub" /><meta property="og:type" content="object" /><meta property="og:title" content="LiaScript/LiaScript-Exporter" /><meta property="og:url" content="https://github.com/LiaScript/LiaScript-Exporter" /><meta property="og:description" content="A simple module to export LiaScript docs into other formats... - LiaScript/LiaScript-Exporter" />





  <link rel="assets" href="https://github.githubassets.com/">


  <meta name="request-id" content="D11C:3236:5E9549:A9A409:5F743E5C" data-pjax-transient="true"/><meta name="html-safe-nonce" content="f8deed27ad74cce00142b0b2c25a6738a30f8915" data-pjax-transient="true"/><meta name="visitor-payload" content="eyJyZWZlcnJlciI6Imh0dHA6Ly9sb2NhbGhvc3Q6MTIzNC8/aHR0cDovL2xvY2FsaG9zdDoxMjM0L1JFQURNRS5tZCIsInJlcXVlc3RfaWQiOiJEMTFDOjMyMzY6NUU5NTQ5OkE5QTQwOTo1Rjc0M0U1QyIsInZpc2l0b3JfaWQiOiI1OTY3OTkwMjgwNjg5MDQwOTg4IiwicmVnaW9uX2VkZ2UiOiJpYWQiLCJyZWdpb25fcmVuZGVyIjoiaWFkIn0=" data-pjax-transient="true"/><meta name="visitor-hmac" content="96c79d842dedd27c82fcf2a0bc4b0be9aca80678ddc5722bc9a2dbb667e5200f" data-pjax-transient="true"/><meta name="cookie-consent-required" content="false" data-pjax-transient="true"/>

    <meta name="hovercard-subject-tag" content="repository:252826941" data-pjax-transient>


  <meta name="github-keyboard-shortcuts" content="repository" data-pjax-transient="true" />



  <meta name="selected-link" value="repo_source" data-pjax-transient>

    <meta name="google-site-verification" content="c1kuD-K2HIVF635lypcsWPoD4kilo5-jA_wBFyT4uMY">
  <meta name="google-site-verification" content="KT5gs8h0wvaagLKAVWq8bbeNwnZZK1r1XQysX3xurLU">
  <meta name="google-site-verification" content="ZzhVyEFwb7w3e0-uOTltm8Jsck2F5StVihD0exw2fsA">
  <meta name="google-site-verification" content="GXs5KoUUkNCoaAZn7wPN-t01Pywp9M3sEjnt_3_ZWPc">

  <meta name="octolytics-host" content="collector.githubapp.com" /><meta name="octolytics-app-id" content="github" /><meta name="octolytics-event-url" content="https://collector.githubapp.com/github-external/browser_event" /><meta name="octolytics-dimension-ga_id" content="" class="js-octo-ga-id" />

  <meta name="analytics-location" content="/&lt;user-name&gt;/&lt;repo-name&gt;" data-pjax-transient="true" />







    <meta name="google-analytics" content="UA-3769691-2">


<meta class="js-ga-set" name="dimension10" content="Responsive" data-pjax-transient>

<meta class="js-ga-set" name="dimension1" content="Logged Out">





      <meta name="hostname" content="github.com">
    <meta name="user-login" content="">


      <meta name="expected-hostname" content="github.com">


    <meta name="enabled-features" content="MARKETPLACE_PENDING_INSTALLATIONS">

  <meta http-equiv="x-pjax-version" content="4c98a1606f9abe5200c834c0b82ade94ea7ec33b30abb5ac44653358e3d60eb2">


        <link href="https://github.com/LiaScript/LiaScript-Exporter/commits/master.atom" rel="alternate" title="Recent Commits to LiaScript-Exporter:master" type="application/atom+xml">

  <meta name="go-import" content="github.com/LiaScript/LiaScript-Exporter git https://github.com/LiaScript/LiaScript-Exporter.git">

  <meta name="octolytics-dimension-user_id" content="32539316" /><meta name="octolytics-dimension-user_login" content="LiaScript" /><meta name="octolytics-dimension-repository_id" content="252826941" /><meta name="octolytics-dimension-repository_nwo" content="LiaScript/LiaScript-Exporter" /><meta name="octolytics-dimension-repository_public" content="true" /><meta name="octolytics-dimension-repository_is_fork" content="false" /><meta name="octolytics-dimension-repository_network_root_id" content="252826941" /><meta name="octolytics-dimension-repository_network_root_nwo" content="LiaScript/LiaScript-Exporter" /><meta name="octolytics-dimension-repository_explore_github_marketplace_ci_cta_shown" content="false" />


    <link rel="canonical" href="https://github.com/LiaScript/LiaScript-Exporter" data-pjax-transient>


  <meta name="browser-stats-url" content="https://api.github.com/_private/browser/stats">

  <meta name="browser-errors-url" content="https://api.github.com/_private/browser/errors">

  <link rel="mask-icon" href="https://github.githubassets.com/pinned-octocat.svg" color="#000000">
  <link rel="alternate icon" class="js-site-favicon" type="image/png" href="https://github.githubassets.com/favicons/favicon.png">
  <link rel="icon" class="js-site-favicon" type="image/svg+xml" href="https://github.githubassets.com/favicons/favicon.svg">

<meta name="theme-color" content="#1e2327">


  <link rel="manifest" href="/manifest.json" crossOrigin="use-credentials">

  </head>

  <body class="logged-out env-production page-responsive">


    <div class="position-relative js-header-wrapper ">
      <a href="#start-of-content" class="px-2 py-4 bg-blue text-white show-on-focus js-skip-to-content">Skip to content</a>
      <span class="progress-pjax-loader width-full js-pjax-loader-bar Progress position-fixed">
    <span style="background-color: #79b8ff;width: 0%;" class="Progress-item progress-pjax-loader-bar "></span>
</span>




          <header class="Header-old header-logged-out js-details-container Details position-relative f4 py-2" role="banner">
  <div class="container-xl d-lg-flex flex-items-center p-responsive">
    <div class="d-flex flex-justify-between flex-items-center">
        <a class="mr-4" href="https://github.com/" aria-label="Homepage" data-ga-click="(Logged out) Header, go to homepage, icon:logo-wordmark">
          <svg height="32" class="octicon octicon-mark-github text-white" viewBox="0 0 16 16" version="1.1" width="32" aria-hidden="true"><path fill-rule="evenodd" d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"></path></svg>
        </a>

          <div class="d-lg-none css-truncate css-truncate-target width-fit p-2">


          </div>

        <div class="d-flex flex-items-center">
              <a href="/join?ref_cta=Sign+up&amp;ref_loc=header+logged+out&amp;ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E&amp;source=header-repo"
                class="d-inline-block d-lg-none f5 text-white no-underline border border-gray-dark rounded-2 px-2 py-1 mr-3 mr-sm-5"
                data-hydro-click="{&quot;event_type&quot;:&quot;authentication.click&quot;,&quot;payload&quot;:{&quot;location_in_page&quot;:&quot;site header&quot;,&quot;repository_id&quot;:null,&quot;auth_type&quot;:&quot;SIGN_UP&quot;,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="23240cd8680395506cf041a89af1a3d4a6f9e7648ea46d4e2849f5f3c5d30ef8"
                data-ga-click="Sign up, click to sign up for account, ref_page:/&lt;user-name&gt;/&lt;repo-name&gt;;ref_cta:Sign up;ref_loc:header logged out">
                Sign&nbsp;up
              </a>

          <button class="btn-link d-lg-none mt-1 js-details-target" type="button" aria-label="Toggle navigation" aria-expanded="false">
            <svg height="24" class="octicon octicon-three-bars text-white" viewBox="0 0 16 16" version="1.1" width="24" aria-hidden="true"><path fill-rule="evenodd" d="M1 2.75A.75.75 0 011.75 2h12.5a.75.75 0 110 1.5H1.75A.75.75 0 011 2.75zm0 5A.75.75 0 011.75 7h12.5a.75.75 0 110 1.5H1.75A.75.75 0 011 7.75zM1.75 12a.75.75 0 100 1.5h12.5a.75.75 0 100-1.5H1.75z"></path></svg>
          </button>
        </div>
    </div>

    <div class="HeaderMenu HeaderMenu--logged-out position-fixed top-0 right-0 bottom-0 height-fit position-lg-relative d-lg-flex flex-justify-between flex-items-center flex-auto">
      <div class="d-flex d-lg-none flex-justify-end border-bottom bg-gray-light p-3">
        <button class="btn-link js-details-target" type="button" aria-label="Toggle navigation" aria-expanded="false">
          <svg height="24" class="octicon octicon-x text-gray" viewBox="0 0 24 24" version="1.1" width="24" aria-hidden="true"><path fill-rule="evenodd" d="M5.72 5.72a.75.75 0 011.06 0L12 10.94l5.22-5.22a.75.75 0 111.06 1.06L13.06 12l5.22 5.22a.75.75 0 11-1.06 1.06L12 13.06l-5.22 5.22a.75.75 0 01-1.06-1.06L10.94 12 5.72 6.78a.75.75 0 010-1.06z"></path></svg>
        </button>
      </div>

        <nav class="mt-0 px-3 px-lg-0 mb-5 mb-lg-0" aria-label="Global">
          <ul class="d-lg-flex list-style-none">
              <li class="d-block d-lg-flex flex-lg-nowrap flex-lg-items-center border-bottom border-lg-bottom-0 mr-0 mr-lg-3 edge-item-fix position-relative flex-wrap flex-justify-between d-flex flex-items-center ">
                <details class="HeaderMenu-details details-overlay details-reset width-full">
                  <summary class="HeaderMenu-summary HeaderMenu-link px-0 py-3 border-0 no-wrap d-block d-lg-inline-block">
                    Why GitHub?
                    <svg x="0px" y="0px" viewBox="0 0 14 8" xml:space="preserve" fill="none" class="icon-chevon-down-mktg position-absolute position-lg-relative">
                      <path d="M1,1l6.2,6L13,1"></path>
                    </svg>
                  </summary>
                  <div class="dropdown-menu flex-auto rounded-1 bg-white px-0 mt-0 pb-4 p-lg-4 position-relative position-lg-absolute left-0 left-lg-n4">
                    <a href="/features" class="py-2 lh-condensed-ultra d-block link-gray-dark no-underline h5 Bump-link--hover" data-ga-click="(Logged out) Header, go to Features">Features <span class="Bump-link-symbol float-right text-normal text-gray-light">&rarr;</span></a>
                    <ul class="list-style-none f5 pb-3">
                      <li class="edge-item-fix"><a href="/features/code-review/" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Code review">Code review</a></li>
                      <li class="edge-item-fix"><a href="/features/project-management/" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Project management">Project management</a></li>
                      <li class="edge-item-fix"><a href="/features/integrations" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Integrations">Integrations</a></li>
                      <li class="edge-item-fix"><a href="/features/actions" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Actions">Actions</a></li>
                      <li class="edge-item-fix"><a href="/features/packages" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to GitHub Packages">Packages</a></li>
                      <li class="edge-item-fix"><a href="/features/security" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Security">Security</a></li>
                      <li class="edge-item-fix"><a href="/features#team-management" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Team management">Team management</a></li>
                      <li class="edge-item-fix"><a href="/features#hosting" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Code hosting">Hosting</a></li>
                      <li class="edge-item-fix hide-xl"><a href="/mobile" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Mobile">Mobile</a></li>
                    </ul>

                    <ul class="list-style-none mb-0 border-lg-top pt-lg-3">
                      <li class="edge-item-fix"><a href="/customer-stories" class="py-2 lh-condensed-ultra d-block no-underline link-gray-dark no-underline h5 Bump-link--hover" data-ga-click="(Logged out) Header, go to Customer stories">Customer stories <span class="Bump-link-symbol float-right text-normal text-gray-light">&rarr;</span></a></li>
                      <li class="edge-item-fix"><a href="/security" class="py-2 lh-condensed-ultra d-block no-underline link-gray-dark no-underline h5 Bump-link--hover" data-ga-click="(Logged out) Header, go to Security">Security <span class="Bump-link-symbol float-right text-normal text-gray-light">&rarr;</span></a></li>
                    </ul>
                  </div>
                </details>
              </li>
              <li class="border-bottom border-lg-bottom-0 mr-0 mr-lg-3">
                <a href="/team" class="HeaderMenu-link no-underline py-3 d-block d-lg-inline-block" data-ga-click="(Logged out) Header, go to Team">Team</a>
              </li>
              <li class="border-bottom border-lg-bottom-0 mr-0 mr-lg-3">
                <a href="/enterprise" class="HeaderMenu-link no-underline py-3 d-block d-lg-inline-block" data-ga-click="(Logged out) Header, go to Enterprise">Enterprise</a>
              </li>

              <li class="d-block d-lg-flex flex-lg-nowrap flex-lg-items-center border-bottom border-lg-bottom-0 mr-0 mr-lg-3 edge-item-fix position-relative flex-wrap flex-justify-between d-flex flex-items-center ">
                <details class="HeaderMenu-details details-overlay details-reset width-full">
                  <summary class="HeaderMenu-summary HeaderMenu-link px-0 py-3 border-0 no-wrap d-block d-lg-inline-block">
                    Explore
                    <svg x="0px" y="0px" viewBox="0 0 14 8" xml:space="preserve" fill="none" class="icon-chevon-down-mktg position-absolute position-lg-relative">
                      <path d="M1,1l6.2,6L13,1"></path>
                    </svg>
                  </summary>

                  <div class="dropdown-menu flex-auto rounded-1 bg-white px-0 pt-2 pb-0 mt-0 pb-4 p-lg-4 position-relative position-lg-absolute left-0 left-lg-n4">
                    <ul class="list-style-none mb-3">
                      <li class="edge-item-fix"><a href="/explore" class="py-2 lh-condensed-ultra d-block link-gray-dark no-underline h5 Bump-link--hover" data-ga-click="(Logged out) Header, go to Explore">Explore GitHub <span class="Bump-link-symbol float-right text-normal text-gray-light">&rarr;</span></a></li>
                    </ul>

                    <h4 class="text-gray-light text-normal text-mono f5 mb-2 border-lg-top pt-lg-3">Learn &amp; contribute</h4>
                    <ul class="list-style-none mb-3">
                      <li class="edge-item-fix"><a href="/topics" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Topics">Topics</a></li>
                        <li class="edge-item-fix"><a href="/collections" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Collections">Collections</a></li>
                      <li class="edge-item-fix"><a href="/trending" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Trending">Trending</a></li>
                      <li class="edge-item-fix"><a href="https://lab.github.com/" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Learning lab">Learning Lab</a></li>
                      <li class="edge-item-fix"><a href="https://opensource.guide" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Open source guides">Open source guides</a></li>
                    </ul>

                    <h4 class="text-gray-light text-normal text-mono f5 mb-2 border-lg-top pt-lg-3">Connect with others</h4>
                    <ul class="list-style-none mb-0">
                      <li class="edge-item-fix"><a href="https://github.com/events" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Events">Events</a></li>
                      <li class="edge-item-fix"><a href="https://github.community" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Community forum">Community forum</a></li>
                      <li class="edge-item-fix"><a href="https://education.github.com" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to GitHub Education">GitHub Education</a></li>
                      <li class="edge-item-fix"><a href="https://stars.github.com" class="py-2 pb-0 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to GitHub Stars Program">GitHub Stars program</a></li>
                    </ul>
                  </div>
                </details>
              </li>

              <li class="border-bottom border-lg-bottom-0 mr-0 mr-lg-3">
                <a href="/marketplace" class="HeaderMenu-link no-underline py-3 d-block d-lg-inline-block" data-ga-click="(Logged out) Header, go to Marketplace">Marketplace</a>
              </li>

              <li class="d-block d-lg-flex flex-lg-nowrap flex-lg-items-center border-bottom border-lg-bottom-0 mr-0 mr-lg-3 edge-item-fix position-relative flex-wrap flex-justify-between d-flex flex-items-center ">
                <details class="HeaderMenu-details details-overlay details-reset width-full">
                  <summary class="HeaderMenu-summary HeaderMenu-link px-0 py-3 border-0 no-wrap d-block d-lg-inline-block">
                    Pricing
                    <svg x="0px" y="0px" viewBox="0 0 14 8" xml:space="preserve" fill="none" class="icon-chevon-down-mktg position-absolute position-lg-relative">
                       <path d="M1,1l6.2,6L13,1"></path>
                    </svg>
                  </summary>

                  <div class="dropdown-menu flex-auto rounded-1 bg-white px-0 pt-2 pb-4 mt-0 p-lg-4 position-relative position-lg-absolute left-0 left-lg-n4">
                    <a href="/pricing" class="pb-2 lh-condensed-ultra d-block link-gray-dark no-underline h5 Bump-link--hover" data-ga-click="(Logged out) Header, go to Pricing">Plans <span class="Bump-link-symbol float-right text-normal text-gray-light">&rarr;</span></a>

                    <ul class="list-style-none mb-3">
                      <li class="edge-item-fix"><a href="/pricing#feature-comparison" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Compare plans">Compare plans</a></li>
                      <li class="edge-item-fix"><a href="https://enterprise.github.com/contact" class="py-2 lh-condensed-ultra d-block link-gray no-underline f5" data-ga-click="(Logged out) Header, go to Contact Sales">Contact Sales</a></li>
                    </ul>

                    <ul class="list-style-none mb-0 border-lg-top pt-lg-3">
                      <li class="edge-item-fix"><a href="/nonprofit" class="py-2 lh-condensed-ultra d-block no-underline link-gray-dark no-underline h5 Bump-link--hover" data-ga-click="(Logged out) Header, go to Nonprofits">Nonprofit <span class="Bump-link-symbol float-right text-normal text-gray-light">&rarr;</span></a></li>
                      <li class="edge-item-fix"><a href="https://education.github.com" class="py-2 pb-0 lh-condensed-ultra d-block no-underline link-gray-dark no-underline h5 Bump-link--hover"  data-ga-click="(Logged out) Header, go to Education">Education <span class="Bump-link-symbol float-right text-normal text-gray-light">&rarr;</span></a></li>
                    </ul>
                  </div>
                </details>
              </li>
          </ul>
        </nav>

      <div class="d-lg-flex flex-items-center px-3 px-lg-0 text-center text-lg-left">
          <div class="d-lg-flex mb-3 mb-lg-0">
              <div class="header-search header-search-current js-header-search-current flex-auto js-site-search position-relative flex-self-stretch flex-md-self-auto mb-3 mb-md-0 mr-0 mr-md-3 scoped-search site-scoped-search js-jump-to js-header-search-current-jump-to"
  role="combobox"
  aria-owns="jump-to-results"
  aria-label="Search or jump to"
  aria-haspopup="listbox"
  aria-expanded="false"
>
  <div class="position-relative">
    <!-- '"` --><!-- </textarea></xmp> --></option></form><form class="js-site-search-form" role="search" aria-label="Site" data-scope-type="Repository" data-scope-id="252826941" data-scoped-search-url="/LiaScript/LiaScript-Exporter/search" data-unscoped-search-url="/search" action="/LiaScript/LiaScript-Exporter/search" accept-charset="UTF-8" method="get">
      <label class="form-control input-sm header-search-wrapper p-0 js-chromeless-input-container header-search-wrapper-jump-to position-relative d-flex flex-justify-between flex-items-center">
        <input type="text"
          class="form-control input-sm header-search-input jump-to-field js-jump-to-field js-site-search-focus js-site-search-field is-clearable"
          data-hotkey="s,/"
          name="q"
          value=""
          placeholder="Search"
          data-unscoped-placeholder="Search GitHub"
          data-scoped-placeholder="Search"
          autocapitalize="off"
          aria-autocomplete="list"
          aria-controls="jump-to-results"
          aria-label="Search"
          data-jump-to-suggestions-path="/_graphql/GetSuggestedNavigationDestinations"
          spellcheck="false"
          autocomplete="off"
          >
          <input type="hidden" data-csrf="true" class="js-data-jump-to-suggestions-path-csrf" value="Vf6HX9S7NVDRLV4TNk4IJmiiVpmcRcfUGZ5k/LCGOBgz3ojr9oj0qim3tYJusjRRAULQJ0ZOm8cGaKvqhm9+2Q==" />
          <input type="hidden" class="js-site-search-type-field" name="type" >
            <img src="https://github.githubassets.com/images/search-key-slash.svg" alt="" class="mr-2 header-search-key-slash">

            <div class="Box position-absolute overflow-hidden d-none jump-to-suggestions js-jump-to-suggestions-container">

<ul class="d-none js-jump-to-suggestions-template-container">


<li class="d-flex flex-justify-start flex-items-center p-0 f5 navigation-item js-navigation-item js-jump-to-suggestion" role="option">
  <a tabindex="-1" class="no-underline d-flex flex-auto flex-items-center jump-to-suggestions-path js-jump-to-suggestion-path js-navigation-open p-2" href="">
    <div class="jump-to-octicon js-jump-to-octicon flex-shrink-0 mr-2 text-center d-none">
      <svg height="16" width="16" class="octicon octicon-repo flex-shrink-0 js-jump-to-octicon-repo d-none" title="Repository" aria-label="Repository" viewBox="0 0 16 16" version="1.1" role="img"><path fill-rule="evenodd" d="M2 2.5A2.5 2.5 0 014.5 0h8.75a.75.75 0 01.75.75v12.5a.75.75 0 01-.75.75h-2.5a.75.75 0 110-1.5h1.75v-2h-8a1 1 0 00-.714 1.7.75.75 0 01-1.072 1.05A2.495 2.495 0 012 11.5v-9zm10.5-1V9h-8c-.356 0-.694.074-1 .208V2.5a1 1 0 011-1h8zM5 12.25v3.25a.25.25 0 00.4.2l1.45-1.087a.25.25 0 01.3 0L8.6 15.7a.25.25 0 00.4-.2v-3.25a.25.25 0 00-.25-.25h-3.5a.25.25 0 00-.25.25z"></path></svg>
      <svg height="16" width="16" class="octicon octicon-project flex-shrink-0 js-jump-to-octicon-project d-none" title="Project" aria-label="Project" viewBox="0 0 16 16" version="1.1" role="img"><path fill-rule="evenodd" d="M1.75 0A1.75 1.75 0 000 1.75v12.5C0 15.216.784 16 1.75 16h12.5A1.75 1.75 0 0016 14.25V1.75A1.75 1.75 0 0014.25 0H1.75zM1.5 1.75a.25.25 0 01.25-.25h12.5a.25.25 0 01.25.25v12.5a.25.25 0 01-.25.25H1.75a.25.25 0 01-.25-.25V1.75zM11.75 3a.75.75 0 00-.75.75v7.5a.75.75 0 001.5 0v-7.5a.75.75 0 00-.75-.75zm-8.25.75a.75.75 0 011.5 0v5.5a.75.75 0 01-1.5 0v-5.5zM8 3a.75.75 0 00-.75.75v3.5a.75.75 0 001.5 0v-3.5A.75.75 0 008 3z"></path></svg>
      <svg height="16" width="16" class="octicon octicon-search flex-shrink-0 js-jump-to-octicon-search d-none" title="Search" aria-label="Search" viewBox="0 0 16 16" version="1.1" role="img"><path fill-rule="evenodd" d="M11.5 7a4.499 4.499 0 11-8.998 0A4.499 4.499 0 0111.5 7zm-.82 4.74a6 6 0 111.06-1.06l3.04 3.04a.75.75 0 11-1.06 1.06l-3.04-3.04z"></path></svg>
    </div>

    <img class="avatar mr-2 flex-shrink-0 js-jump-to-suggestion-avatar d-none" alt="" aria-label="Team" src="" width="28" height="28">

    <div class="jump-to-suggestion-name js-jump-to-suggestion-name flex-auto overflow-hidden text-left no-wrap css-truncate css-truncate-target">
    </div>

    <div class="border rounded-1 flex-shrink-0 bg-gray px-1 text-gray-light ml-1 f6 d-none js-jump-to-badge-search">
      <span class="js-jump-to-badge-search-text-default d-none" aria-label="in this repository">
        In this repository
      </span>
      <span class="js-jump-to-badge-search-text-global d-none" aria-label="in all of GitHub">
        All GitHub
      </span>
      <span aria-hidden="true" class="d-inline-block ml-1 v-align-middle">↵</span>
    </div>

    <div aria-hidden="true" class="border rounded-1 flex-shrink-0 bg-gray px-1 text-gray-light ml-1 f6 d-none d-on-nav-focus js-jump-to-badge-jump">
      Jump to
      <span class="d-inline-block ml-1 v-align-middle">↵</span>
    </div>
  </a>
</li>

</ul>

<ul class="d-none js-jump-to-no-results-template-container">
  <li class="d-flex flex-justify-center flex-items-center f5 d-none js-jump-to-suggestion p-2">
    <span class="text-gray">No suggested jump to results</span>
  </li>
</ul>

<ul id="jump-to-results" role="listbox" class="p-0 m-0 js-navigation-container jump-to-suggestions-results-container js-jump-to-suggestions-results-container">


<li class="d-flex flex-justify-start flex-items-center p-0 f5 navigation-item js-navigation-item js-jump-to-scoped-search d-none" role="option">
  <a tabindex="-1" class="no-underline d-flex flex-auto flex-items-center jump-to-suggestions-path js-jump-to-suggestion-path js-navigation-open p-2" href="">
    <div class="jump-to-octicon js-jump-to-octicon flex-shrink-0 mr-2 text-center d-none">
      <svg height="16" width="16" class="octicon octicon-repo flex-shrink-0 js-jump-to-octicon-repo d-none" title="Repository" aria-label="Repository" viewBox="0 0 16 16" version="1.1" role="img"><path fill-rule="evenodd" d="M2 2.5A2.5 2.5 0 014.5 0h8.75a.75.75 0 01.75.75v12.5a.75.75 0 01-.75.75h-2.5a.75.75 0 110-1.5h1.75v-2h-8a1 1 0 00-.714 1.7.75.75 0 01-1.072 1.05A2.495 2.495 0 012 11.5v-9zm10.5-1V9h-8c-.356 0-.694.074-1 .208V2.5a1 1 0 011-1h8zM5 12.25v3.25a.25.25 0 00.4.2l1.45-1.087a.25.25 0 01.3 0L8.6 15.7a.25.25 0 00.4-.2v-3.25a.25.25 0 00-.25-.25h-3.5a.25.25 0 00-.25.25z"></path></svg>
      <svg height="16" width="16" class="octicon octicon-project flex-shrink-0 js-jump-to-octicon-project d-none" title="Project" aria-label="Project" viewBox="0 0 16 16" version="1.1" role="img"><path fill-rule="evenodd" d="M1.75 0A1.75 1.75 0 000 1.75v12.5C0 15.216.784 16 1.75 16h12.5A1.75 1.75 0 0016 14.25V1.75A1.75 1.75 0 0014.25 0H1.75zM1.5 1.75a.25.25 0 01.25-.25h12.5a.25.25 0 01.25.25v12.5a.25.25 0 01-.25.25H1.75a.25.25 0 01-.25-.25V1.75zM11.75 3a.75.75 0 00-.75.75v7.5a.75.75 0 001.5 0v-7.5a.75.75 0 00-.75-.75zm-8.25.75a.75.75 0 011.5 0v5.5a.75.75 0 01-1.5 0v-5.5zM8 3a.75.75 0 00-.75.75v3.5a.75.75 0 001.5 0v-3.5A.75.75 0 008 3z"></path></svg>
      <svg height="16" width="16" class="octicon octicon-search flex-shrink-0 js-jump-to-octicon-search d-none" title="Search" aria-label="Search" viewBox="0 0 16 16" version="1.1" role="img"><path fill-rule="evenodd" d="M11.5 7a4.499 4.499 0 11-8.998 0A4.499 4.499 0 0111.5 7zm-.82 4.74a6 6 0 111.06-1.06l3.04 3.04a.75.75 0 11-1.06 1.06l-3.04-3.04z"></path></svg>
    </div>

    <img class="avatar mr-2 flex-shrink-0 js-jump-to-suggestion-avatar d-none" alt="" aria-label="Team" src="" width="28" height="28">

    <div class="jump-to-suggestion-name js-jump-to-suggestion-name flex-auto overflow-hidden text-left no-wrap css-truncate css-truncate-target">
    </div>

    <div class="border rounded-1 flex-shrink-0 bg-gray px-1 text-gray-light ml-1 f6 d-none js-jump-to-badge-search">
      <span class="js-jump-to-badge-search-text-default d-none" aria-label="in this repository">
        In this repository
      </span>
      <span class="js-jump-to-badge-search-text-global d-none" aria-label="in all of GitHub">
        All GitHub
      </span>
      <span aria-hidden="true" class="d-inline-block ml-1 v-align-middle">↵</span>
    </div>

    <div aria-hidden="true" class="border rounded-1 flex-shrink-0 bg-gray px-1 text-gray-light ml-1 f6 d-none d-on-nav-focus js-jump-to-badge-jump">
      Jump to
      <span class="d-inline-block ml-1 v-align-middle">↵</span>
    </div>
  </a>
</li>



<li class="d-flex flex-justify-start flex-items-center p-0 f5 navigation-item js-navigation-item js-jump-to-global-search d-none" role="option">
  <a tabindex="-1" class="no-underline d-flex flex-auto flex-items-center jump-to-suggestions-path js-jump-to-suggestion-path js-navigation-open p-2" href="">
    <div class="jump-to-octicon js-jump-to-octicon flex-shrink-0 mr-2 text-center d-none">
      <svg height="16" width="16" class="octicon octicon-repo flex-shrink-0 js-jump-to-octicon-repo d-none" title="Repository" aria-label="Repository" viewBox="0 0 16 16" version="1.1" role="img"><path fill-rule="evenodd" d="M2 2.5A2.5 2.5 0 014.5 0h8.75a.75.75 0 01.75.75v12.5a.75.75 0 01-.75.75h-2.5a.75.75 0 110-1.5h1.75v-2h-8a1 1 0 00-.714 1.7.75.75 0 01-1.072 1.05A2.495 2.495 0 012 11.5v-9zm10.5-1V9h-8c-.356 0-.694.074-1 .208V2.5a1 1 0 011-1h8zM5 12.25v3.25a.25.25 0 00.4.2l1.45-1.087a.25.25 0 01.3 0L8.6 15.7a.25.25 0 00.4-.2v-3.25a.25.25 0 00-.25-.25h-3.5a.25.25 0 00-.25.25z"></path></svg>
      <svg height="16" width="16" class="octicon octicon-project flex-shrink-0 js-jump-to-octicon-project d-none" title="Project" aria-label="Project" viewBox="0 0 16 16" version="1.1" role="img"><path fill-rule="evenodd" d="M1.75 0A1.75 1.75 0 000 1.75v12.5C0 15.216.784 16 1.75 16h12.5A1.75 1.75 0 0016 14.25V1.75A1.75 1.75 0 0014.25 0H1.75zM1.5 1.75a.25.25 0 01.25-.25h12.5a.25.25 0 01.25.25v12.5a.25.25 0 01-.25.25H1.75a.25.25 0 01-.25-.25V1.75zM11.75 3a.75.75 0 00-.75.75v7.5a.75.75 0 001.5 0v-7.5a.75.75 0 00-.75-.75zm-8.25.75a.75.75 0 011.5 0v5.5a.75.75 0 01-1.5 0v-5.5zM8 3a.75.75 0 00-.75.75v3.5a.75.75 0 001.5 0v-3.5A.75.75 0 008 3z"></path></svg>
      <svg height="16" width="16" class="octicon octicon-search flex-shrink-0 js-jump-to-octicon-search d-none" title="Search" aria-label="Search" viewBox="0 0 16 16" version="1.1" role="img"><path fill-rule="evenodd" d="M11.5 7a4.499 4.499 0 11-8.998 0A4.499 4.499 0 0111.5 7zm-.82 4.74a6 6 0 111.06-1.06l3.04 3.04a.75.75 0 11-1.06 1.06l-3.04-3.04z"></path></svg>
    </div>

    <img class="avatar mr-2 flex-shrink-0 js-jump-to-suggestion-avatar d-none" alt="" aria-label="Team" src="" width="28" height="28">

    <div class="jump-to-suggestion-name js-jump-to-suggestion-name flex-auto overflow-hidden text-left no-wrap css-truncate css-truncate-target">
    </div>

    <div class="border rounded-1 flex-shrink-0 bg-gray px-1 text-gray-light ml-1 f6 d-none js-jump-to-badge-search">
      <span class="js-jump-to-badge-search-text-default d-none" aria-label="in this repository">
        In this repository
      </span>
      <span class="js-jump-to-badge-search-text-global d-none" aria-label="in all of GitHub">
        All GitHub
      </span>
      <span aria-hidden="true" class="d-inline-block ml-1 v-align-middle">↵</span>
    </div>

    <div aria-hidden="true" class="border rounded-1 flex-shrink-0 bg-gray px-1 text-gray-light ml-1 f6 d-none d-on-nav-focus js-jump-to-badge-jump">
      Jump to
      <span class="d-inline-block ml-1 v-align-middle">↵</span>
    </div>
  </a>
</li>


</ul>

            </div>
      </label>
</form>  </div>
</div>

          </div>

        <a href="/login?return_to=%2FLiaScript%2FLiaScript-Exporter"
          class="HeaderMenu-link no-underline mr-3"
          data-hydro-click="{&quot;event_type&quot;:&quot;authentication.click&quot;,&quot;payload&quot;:{&quot;location_in_page&quot;:&quot;site header menu&quot;,&quot;repository_id&quot;:null,&quot;auth_type&quot;:&quot;SIGN_UP&quot;,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="6c07a512b9c603f0c60b0613f58da48d82b52eb6a09d05c5f58f79894169587e"
          data-ga-click="(Logged out) Header, clicked Sign in, text:sign-in">
          Sign&nbsp;in
        </a>
            <a href="/join?ref_cta=Sign+up&amp;ref_loc=header+logged+out&amp;ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E&amp;source=header-repo&amp;source_repo=LiaScript%2FLiaScript-Exporter"
              class="HeaderMenu-link d-inline-block no-underline border border-gray-dark rounded-1 px-2 py-1"
              data-hydro-click="{&quot;event_type&quot;:&quot;authentication.click&quot;,&quot;payload&quot;:{&quot;location_in_page&quot;:&quot;site header menu&quot;,&quot;repository_id&quot;:null,&quot;auth_type&quot;:&quot;SIGN_UP&quot;,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="6c07a512b9c603f0c60b0613f58da48d82b52eb6a09d05c5f58f79894169587e"
              data-ga-click="Sign up, click to sign up for account, ref_page:/&lt;user-name&gt;/&lt;repo-name&gt;;ref_cta:Sign up;ref_loc:header logged out">
              Sign&nbsp;up
            </a>
      </div>
    </div>
  </div>
</header>

    </div>

  <div id="start-of-content" class="show-on-focus"></div>






    <div data-pjax-replace id="js-flash-container">


  <template class="js-flash-template">
    <div class="flash flash-full  {{ className }}">
  <div class=" px-2" >
    <button class="flash-close js-flash-close" type="button" aria-label="Dismiss this message">
      <svg class="octicon octicon-x" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M3.72 3.72a.75.75 0 011.06 0L8 6.94l3.22-3.22a.75.75 0 111.06 1.06L9.06 8l3.22 3.22a.75.75 0 11-1.06 1.06L8 9.06l-3.22 3.22a.75.75 0 01-1.06-1.06L6.94 8 3.72 4.78a.75.75 0 010-1.06z"></path></svg>
    </button>

      <div>{{ message }}</div>

  </div>
</div>
  </template>
</div>




  <include-fragment class="js-notification-shelf-include-fragment" data-base-src="https://github.com/notifications/beta/shelf"></include-fragment>



  <div
    class="application-main "
    data-commit-hovercards-enabled
    data-discussion-hovercards-enabled
    data-issue-and-pr-hovercards-enabled
  >
        <div itemscope itemtype="http://schema.org/SoftwareSourceCode" class="">
    <main id="js-repo-pjax-container" data-pjax-container >















  <div class="bg-gray-light pt-3 hide-full-screen mb-5">

      <div class="d-flex mb-3 px-3 px-md-4 px-lg-5">

        <div class="flex-auto min-width-0 width-fit mr-3">
            <h1 class=" d-flex flex-wrap flex-items-center break-word f3 text-normal">
    <svg class="octicon octicon-repo text-gray mr-2" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M2 2.5A2.5 2.5 0 014.5 0h8.75a.75.75 0 01.75.75v12.5a.75.75 0 01-.75.75h-2.5a.75.75 0 110-1.5h1.75v-2h-8a1 1 0 00-.714 1.7.75.75 0 01-1.072 1.05A2.495 2.495 0 012 11.5v-9zm10.5-1V9h-8c-.356 0-.694.074-1 .208V2.5a1 1 0 011-1h8zM5 12.25v3.25a.25.25 0 00.4.2l1.45-1.087a.25.25 0 01.3 0L8.6 15.7a.25.25 0 00.4-.2v-3.25a.25.25 0 00-.25-.25h-3.5a.25.25 0 00-.25.25z"></path></svg>
    <span class="author flex-self-stretch" itemprop="author">
      <a class="url fn" rel="author" data-hovercard-type="organization" data-hovercard-url="/orgs/LiaScript/hovercard" href="/LiaScript">LiaScript</a>
    </span>
    <span class="mx-1 flex-self-stretch">/</span>
  <strong itemprop="name" class="mr-2 flex-self-stretch">
    <a data-pjax="#js-repo-pjax-container" href="/LiaScript/LiaScript-Exporter">LiaScript-Exporter</a>
  </strong>

</h1>


        </div>

          <ul class="pagehead-actions flex-shrink-0 d-none d-md-inline" style="padding: 2px 0;">

  <li>
          <a class="tooltipped tooltipped-s btn btn-sm btn-with-count" aria-label="You must be signed in to watch a repository" rel="nofollow" data-hydro-click="{&quot;event_type&quot;:&quot;authentication.click&quot;,&quot;payload&quot;:{&quot;location_in_page&quot;:&quot;notification subscription menu watch&quot;,&quot;repository_id&quot;:null,&quot;auth_type&quot;:&quot;LOG_IN&quot;,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="2427f69e191562175016e8cfae1f0d0b14bde20596454379a58b595cc79c812c" href="/login?return_to=%2FLiaScript%2FLiaScript-Exporter">
    <svg height="16" class="octicon octicon-eye" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M1.679 7.932c.412-.621 1.242-1.75 2.366-2.717C5.175 4.242 6.527 3.5 8 3.5c1.473 0 2.824.742 3.955 1.715 1.124.967 1.954 2.096 2.366 2.717a.119.119 0 010 .136c-.412.621-1.242 1.75-2.366 2.717C10.825 11.758 9.473 12.5 8 12.5c-1.473 0-2.824-.742-3.955-1.715C2.92 9.818 2.09 8.69 1.679 8.068a.119.119 0 010-.136zM8 2c-1.981 0-3.67.992-4.933 2.078C1.797 5.169.88 6.423.43 7.1a1.619 1.619 0 000 1.798c.45.678 1.367 1.932 2.637 3.024C4.329 13.008 6.019 14 8 14c1.981 0 3.67-.992 4.933-2.078 1.27-1.091 2.187-2.345 2.637-3.023a1.619 1.619 0 000-1.798c-.45-.678-1.367-1.932-2.637-3.023C11.671 2.992 9.981 2 8 2zm0 8a2 2 0 100-4 2 2 0 000 4z"></path></svg>
    Watch
</a>    <a class="social-count" href="/LiaScript/LiaScript-Exporter/watchers"
       aria-label="3 users are watching this repository">
      3
    </a>

  </li>

  <li>
          <a class="btn btn-sm btn-with-count  tooltipped tooltipped-s" aria-label="You must be signed in to star a repository" rel="nofollow" data-hydro-click="{&quot;event_type&quot;:&quot;authentication.click&quot;,&quot;payload&quot;:{&quot;location_in_page&quot;:&quot;star button&quot;,&quot;repository_id&quot;:252826941,&quot;auth_type&quot;:&quot;LOG_IN&quot;,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="e64d5a47a94bbd3b85d2b395a0ff6c147f6ce134cfb3a6415ed76948201b2454" href="/login?return_to=%2FLiaScript%2FLiaScript-Exporter">
      <svg vertical_align="text_bottom" height="16" class="octicon octicon-star v-align-text-bottom" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M8 .25a.75.75 0 01.673.418l1.882 3.815 4.21.612a.75.75 0 01.416 1.279l-3.046 2.97.719 4.192a.75.75 0 01-1.088.791L8 12.347l-3.766 1.98a.75.75 0 01-1.088-.79l.72-4.194L.818 6.374a.75.75 0 01.416-1.28l4.21-.611L7.327.668A.75.75 0 018 .25zm0 2.445L6.615 5.5a.75.75 0 01-.564.41l-3.097.45 2.24 2.184a.75.75 0 01.216.664l-.528 3.084 2.769-1.456a.75.75 0 01.698 0l2.77 1.456-.53-3.084a.75.75 0 01.216-.664l2.24-2.183-3.096-.45a.75.75 0 01-.564-.41L8 2.694v.001z"></path></svg>
      Star
</a>
    <a class="social-count js-social-count" href="/LiaScript/LiaScript-Exporter/stargazers"
      aria-label="1 user starred this repository">
      1
    </a>

  </li>

  <li>
        <a class="btn btn-sm btn-with-count tooltipped tooltipped-s" aria-label="You must be signed in to fork a repository" rel="nofollow" data-hydro-click="{&quot;event_type&quot;:&quot;authentication.click&quot;,&quot;payload&quot;:{&quot;location_in_page&quot;:&quot;repo details fork button&quot;,&quot;repository_id&quot;:252826941,&quot;auth_type&quot;:&quot;LOG_IN&quot;,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="ce46f955bc08b30826ea8f78dda4a72c61bade800fe2ebc3d9d7b1b75b382bce" href="/login?return_to=%2FLiaScript%2FLiaScript-Exporter">
          <svg class="octicon octicon-repo-forked" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M5 3.25a.75.75 0 11-1.5 0 .75.75 0 011.5 0zm0 2.122a2.25 2.25 0 10-1.5 0v.878A2.25 2.25 0 005.75 8.5h1.5v2.128a2.251 2.251 0 101.5 0V8.5h1.5a2.25 2.25 0 002.25-2.25v-.878a2.25 2.25 0 10-1.5 0v.878a.75.75 0 01-.75.75h-4.5A.75.75 0 015 6.25v-.878zm3.75 7.378a.75.75 0 11-1.5 0 .75.75 0 011.5 0zm3-8.75a.75.75 0 100-1.5.75.75 0 000 1.5z"></path></svg>
          Fork
</a>
      <a href="/LiaScript/LiaScript-Exporter/network/members" class="social-count"
         aria-label="0 users forked this repository">
        0
      </a>
  </li>
</ul>

      </div>
          <div class="d-block d-md-none mb-2 px-3 px-md-4 px-lg-5">
      <p class="f4 mb-3">
        A simple module to export LiaScript docs into other formats...
      </p>
      <div class="mb-2">
        <a href="/LiaScript/LiaScript-Exporter/blob/master/LICENSE" class="muted-link">
          <svg mr="1" height="16" class="octicon octicon-law mr-1" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M8.75.75a.75.75 0 00-1.5 0V2h-.984c-.305 0-.604.08-.869.23l-1.288.737A.25.25 0 013.984 3H1.75a.75.75 0 000 1.5h.428L.066 9.192a.75.75 0 00.154.838l.53-.53-.53.53v.001l.002.002.002.002.006.006.016.015.045.04a3.514 3.514 0 00.686.45A4.492 4.492 0 003 11c.88 0 1.556-.22 2.023-.454a3.515 3.515 0 00.686-.45l.045-.04.016-.015.006-.006.002-.002.001-.002L5.25 9.5l.53.53a.75.75 0 00.154-.838L3.822 4.5h.162c.305 0 .604-.08.869-.23l1.289-.737a.25.25 0 01.124-.033h.984V13h-2.5a.75.75 0 000 1.5h6.5a.75.75 0 000-1.5h-2.5V3.5h.984a.25.25 0 01.124.033l1.29.736c.264.152.563.231.868.231h.162l-2.112 4.692a.75.75 0 00.154.838l.53-.53-.53.53v.001l.002.002.002.002.006.006.016.015.045.04a3.517 3.517 0 00.686.45A4.492 4.492 0 0013 11c.88 0 1.556-.22 2.023-.454a3.512 3.512 0 00.686-.45l.045-.04.01-.01.006-.005.006-.006.002-.002.001-.002-.529-.531.53.53a.75.75 0 00.154-.838L13.823 4.5h.427a.75.75 0 000-1.5h-2.234a.25.25 0 01-.124-.033l-1.29-.736A1.75 1.75 0 009.735 2H8.75V.75zM1.695 9.227c.285.135.718.273 1.305.273s1.02-.138 1.305-.273L3 6.327l-1.305 2.9zm10 0c.285.135.718.273 1.305.273s1.02-.138 1.305-.273L13 6.327l-1.305 2.9z"></path></svg>
            BSD-3-Clause License
        </a>
      </div>
    <div class="mb-3">
      <a class="link-gray no-underline mr-3" href="/LiaScript/LiaScript-Exporter/stargazers">
        <svg mr="1" height="16" class="octicon octicon-star mr-1" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M8 .25a.75.75 0 01.673.418l1.882 3.815 4.21.612a.75.75 0 01.416 1.279l-3.046 2.97.719 4.192a.75.75 0 01-1.088.791L8 12.347l-3.766 1.98a.75.75 0 01-1.088-.79l.72-4.194L.818 6.374a.75.75 0 01.416-1.28l4.21-.611L7.327.668A.75.75 0 018 .25zm0 2.445L6.615 5.5a.75.75 0 01-.564.41l-3.097.45 2.24 2.184a.75.75 0 01.216.664l-.528 3.084 2.769-1.456a.75.75 0 01.698 0l2.77 1.456-.53-3.084a.75.75 0 01.216-.664l2.24-2.183-3.096-.45a.75.75 0 01-.564-.41L8 2.694v.001z"></path></svg>
        <span class="text-bold">1</span>
        star
</a>      <a class="link-gray no-underline" href="/LiaScript/LiaScript-Exporter/network/members">
        <svg mr="1" height="16" class="octicon octicon-repo-forked mr-1" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M5 3.25a.75.75 0 11-1.5 0 .75.75 0 011.5 0zm0 2.122a2.25 2.25 0 10-1.5 0v.878A2.25 2.25 0 005.75 8.5h1.5v2.128a2.251 2.251 0 101.5 0V8.5h1.5a2.25 2.25 0 002.25-2.25v-.878a2.25 2.25 0 10-1.5 0v.878a.75.75 0 01-.75.75h-4.5A.75.75 0 015 6.25v-.878zm3.75 7.378a.75.75 0 11-1.5 0 .75.75 0 011.5 0zm3-8.75a.75.75 0 100-1.5.75.75 0 000 1.5z"></path></svg>
        <span class="text-bold">0</span>
        forks
</a>    </div>
    <div class="d-flex">
      <div class="flex-1 mr-2">
            <a class="btn btn-sm  btn-block tooltipped tooltipped-s" aria-label="You must be signed in to star a repository" rel="nofollow" data-hydro-click="{&quot;event_type&quot;:&quot;authentication.click&quot;,&quot;payload&quot;:{&quot;location_in_page&quot;:&quot;star button&quot;,&quot;repository_id&quot;:252826941,&quot;auth_type&quot;:&quot;LOG_IN&quot;,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="e64d5a47a94bbd3b85d2b395a0ff6c147f6ce134cfb3a6415ed76948201b2454" href="/login?return_to=%2FLiaScript%2FLiaScript-Exporter">
      <svg vertical_align="text_bottom" height="16" class="octicon octicon-star v-align-text-bottom" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M8 .25a.75.75 0 01.673.418l1.882 3.815 4.21.612a.75.75 0 01.416 1.279l-3.046 2.97.719 4.192a.75.75 0 01-1.088.791L8 12.347l-3.766 1.98a.75.75 0 01-1.088-.79l.72-4.194L.818 6.374a.75.75 0 01.416-1.28l4.21-.611L7.327.668A.75.75 0 018 .25zm0 2.445L6.615 5.5a.75.75 0 01-.564.41l-3.097.45 2.24 2.184a.75.75 0 01.216.664l-.528 3.084 2.769-1.456a.75.75 0 01.698 0l2.77 1.456-.53-3.084a.75.75 0 01.216-.664l2.24-2.183-3.096-.45a.75.75 0 01-.564-.41L8 2.694v.001z"></path></svg>
      Star
</a>

      </div>
      <div class="flex-1">
              <a class="tooltipped tooltipped-s btn btn-sm btn-block" aria-label="You must be signed in to watch a repository" rel="nofollow" data-hydro-click="{&quot;event_type&quot;:&quot;authentication.click&quot;,&quot;payload&quot;:{&quot;location_in_page&quot;:&quot;notification subscription menu watch&quot;,&quot;repository_id&quot;:null,&quot;auth_type&quot;:&quot;LOG_IN&quot;,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="2427f69e191562175016e8cfae1f0d0b14bde20596454379a58b595cc79c812c" href="/login?return_to=%2FLiaScript%2FLiaScript-Exporter">
    <svg height="16" class="octicon octicon-eye" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M1.679 7.932c.412-.621 1.242-1.75 2.366-2.717C5.175 4.242 6.527 3.5 8 3.5c1.473 0 2.824.742 3.955 1.715 1.124.967 1.954 2.096 2.366 2.717a.119.119 0 010 .136c-.412.621-1.242 1.75-2.366 2.717C10.825 11.758 9.473 12.5 8 12.5c-1.473 0-2.824-.742-3.955-1.715C2.92 9.818 2.09 8.69 1.679 8.068a.119.119 0 010-.136zM8 2c-1.981 0-3.67.992-4.933 2.078C1.797 5.169.88 6.423.43 7.1a1.619 1.619 0 000 1.798c.45.678 1.367 1.932 2.637 3.024C4.329 13.008 6.019 14 8 14c1.981 0 3.67-.992 4.933-2.078 1.27-1.091 2.187-2.345 2.637-3.023a1.619 1.619 0 000-1.798c-.45-.678-1.367-1.932-2.637-3.023C11.671 2.992 9.981 2 8 2zm0 8a2 2 0 100-4 2 2 0 000 4z"></path></svg>
    Watch
</a>
      </div>
    </div>
  </div>


<nav aria-label="Repository" data-pjax="#js-repo-pjax-container" class="js-repo-nav js-sidenav-container-pjax js-responsive-underlinenav overflow-hidden UnderlineNav px-3 px-md-4 px-lg-5 bg-gray-light">
  <ul class="UnderlineNav-body list-style-none ">
          <li class="d-flex">
        <a class="js-selected-navigation-item selected UnderlineNav-item hx_underlinenav-item no-wrap js-responsive-underlinenav-item" data-tab-item="code-tab" data-hotkey="g c" data-ga-click="Repository, Navigation click, Code tab" aria-current="page" data-selected-links="repo_source repo_downloads repo_commits repo_releases repo_tags repo_branches repo_packages repo_deployments /LiaScript/LiaScript-Exporter" href="/LiaScript/LiaScript-Exporter">
              <svg classes="UnderlineNav-octicon" display="none inline" height="16" class="octicon octicon-code UnderlineNav-octicon d-none d-sm-inline" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M4.72 3.22a.75.75 0 011.06 1.06L2.06 8l3.72 3.72a.75.75 0 11-1.06 1.06L.47 8.53a.75.75 0 010-1.06l4.25-4.25zm6.56 0a.75.75 0 10-1.06 1.06L13.94 8l-3.72 3.72a.75.75 0 101.06 1.06l4.25-4.25a.75.75 0 000-1.06l-4.25-4.25z"></path></svg>
            <span data-content="Code">Code</span>
              <span title="Not available" class="Counter "></span>
</a>      </li>
      <li class="d-flex">
        <a class="js-selected-navigation-item UnderlineNav-item hx_underlinenav-item no-wrap js-responsive-underlinenav-item" data-tab-item="issues-tab" data-hotkey="g i" data-ga-click="Repository, Navigation click, Issues tab" data-selected-links="repo_issues repo_labels repo_milestones /LiaScript/LiaScript-Exporter/issues" href="/LiaScript/LiaScript-Exporter/issues">
              <svg classes="UnderlineNav-octicon" display="none inline" height="16" class="octicon octicon-issue-opened UnderlineNav-octicon d-none d-sm-inline" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M8 1.5a6.5 6.5 0 100 13 6.5 6.5 0 000-13zM0 8a8 8 0 1116 0A8 8 0 010 8zm9 3a1 1 0 11-2 0 1 1 0 012 0zm-.25-6.25a.75.75 0 00-1.5 0v3.5a.75.75 0 001.5 0v-3.5z"></path></svg>
            <span data-content="Issues">Issues</span>
              <span title="0" hidden="hidden" class="Counter ">0</span>
</a>      </li>
      <li class="d-flex">
        <a class="js-selected-navigation-item UnderlineNav-item hx_underlinenav-item no-wrap js-responsive-underlinenav-item" data-tab-item="pull-requests-tab" data-hotkey="g p" data-ga-click="Repository, Navigation click, Pull requests tab" data-selected-links="repo_pulls checks /LiaScript/LiaScript-Exporter/pulls" href="/LiaScript/LiaScript-Exporter/pulls">
              <svg classes="UnderlineNav-octicon" display="none inline" height="16" class="octicon octicon-git-pull-request UnderlineNav-octicon d-none d-sm-inline" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M7.177 3.073L9.573.677A.25.25 0 0110 .854v4.792a.25.25 0 01-.427.177L7.177 3.427a.25.25 0 010-.354zM3.75 2.5a.75.75 0 100 1.5.75.75 0 000-1.5zm-2.25.75a2.25 2.25 0 113 2.122v5.256a2.251 2.251 0 11-1.5 0V5.372A2.25 2.25 0 011.5 3.25zM11 2.5h-1V4h1a1 1 0 011 1v5.628a2.251 2.251 0 101.5 0V5A2.5 2.5 0 0011 2.5zm1 10.25a.75.75 0 111.5 0 .75.75 0 01-1.5 0zM3.75 12a.75.75 0 100 1.5.75.75 0 000-1.5z"></path></svg>
            <span data-content="Pull requests">Pull requests</span>
              <span title="0" hidden="hidden" class="Counter ">0</span>
</a>      </li>
      <li class="d-flex">
        <a class="js-selected-navigation-item UnderlineNav-item hx_underlinenav-item no-wrap js-responsive-underlinenav-item" data-tab-item="actions-tab" data-hotkey="g a" data-ga-click="Repository, Navigation click, Actions tab" data-selected-links="repo_actions /LiaScript/LiaScript-Exporter/actions" href="/LiaScript/LiaScript-Exporter/actions">
              <svg classes="UnderlineNav-octicon" display="none inline" height="16" class="octicon octicon-play UnderlineNav-octicon d-none d-sm-inline" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M1.5 8a6.5 6.5 0 1113 0 6.5 6.5 0 01-13 0zM8 0a8 8 0 100 16A8 8 0 008 0zM6.379 5.227A.25.25 0 006 5.442v5.117a.25.25 0 00.379.214l4.264-2.559a.25.25 0 000-.428L6.379 5.227z"></path></svg>
            <span data-content="Actions">Actions</span>
              <span title="Not available" class="Counter "></span>
</a>      </li>
      <li class="d-flex">
        <a class="js-selected-navigation-item UnderlineNav-item hx_underlinenav-item no-wrap js-responsive-underlinenav-item" data-tab-item="projects-tab" data-hotkey="g b" data-ga-click="Repository, Navigation click, Projects tab" data-selected-links="repo_projects new_repo_project repo_project /LiaScript/LiaScript-Exporter/projects" href="/LiaScript/LiaScript-Exporter/projects">
              <svg classes="UnderlineNav-octicon" display="none inline" height="16" class="octicon octicon-project UnderlineNav-octicon d-none d-sm-inline" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M1.75 0A1.75 1.75 0 000 1.75v12.5C0 15.216.784 16 1.75 16h12.5A1.75 1.75 0 0016 14.25V1.75A1.75 1.75 0 0014.25 0H1.75zM1.5 1.75a.25.25 0 01.25-.25h12.5a.25.25 0 01.25.25v12.5a.25.25 0 01-.25.25H1.75a.25.25 0 01-.25-.25V1.75zM11.75 3a.75.75 0 00-.75.75v7.5a.75.75 0 001.5 0v-7.5a.75.75 0 00-.75-.75zm-8.25.75a.75.75 0 011.5 0v5.5a.75.75 0 01-1.5 0v-5.5zM8 3a.75.75 0 00-.75.75v3.5a.75.75 0 001.5 0v-3.5A.75.75 0 008 3z"></path></svg>
            <span data-content="Projects">Projects</span>
              <span title="0" hidden="hidden" class="Counter ">0</span>
</a>      </li>
      <li class="d-flex">
        <a class="js-selected-navigation-item UnderlineNav-item hx_underlinenav-item no-wrap js-responsive-underlinenav-item" data-tab-item="security-tab" data-hotkey="g s" data-ga-click="Repository, Navigation click, Security tab" data-selected-links="security overview alerts policy token_scanning code_scanning /LiaScript/LiaScript-Exporter/security" href="/LiaScript/LiaScript-Exporter/security">
              <svg classes="UnderlineNav-octicon" display="none inline" height="16" class="octicon octicon-shield UnderlineNav-octicon d-none d-sm-inline" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M7.467.133a1.75 1.75 0 011.066 0l5.25 1.68A1.75 1.75 0 0115 3.48V7c0 1.566-.32 3.182-1.303 4.682-.983 1.498-2.585 2.813-5.032 3.855a1.7 1.7 0 01-1.33 0c-2.447-1.042-4.049-2.357-5.032-3.855C1.32 10.182 1 8.566 1 7V3.48a1.75 1.75 0 011.217-1.667l5.25-1.68zm.61 1.429a.25.25 0 00-.153 0l-5.25 1.68a.25.25 0 00-.174.238V7c0 1.358.275 2.666 1.057 3.86.784 1.194 2.121 2.34 4.366 3.297a.2.2 0 00.154 0c2.245-.956 3.582-2.104 4.366-3.298C13.225 9.666 13.5 8.36 13.5 7V3.48a.25.25 0 00-.174-.237l-5.25-1.68zM9 10.5a1 1 0 11-2 0 1 1 0 012 0zm-.25-5.75a.75.75 0 10-1.5 0v3a.75.75 0 001.5 0v-3z"></path></svg>
            <span data-content="Security">Security</span>
              <include-fragment src="/LiaScript/LiaScript-Exporter/security/overall-count" accept="text/fragment+html"></include-fragment>
</a>      </li>
      <li class="d-flex">
        <a class="js-selected-navigation-item UnderlineNav-item hx_underlinenav-item no-wrap js-responsive-underlinenav-item" data-tab-item="insights-tab" data-ga-click="Repository, Navigation click, Insights tab" data-selected-links="repo_graphs repo_contributors dependency_graph dependabot_updates pulse people /LiaScript/LiaScript-Exporter/pulse" href="/LiaScript/LiaScript-Exporter/pulse">
              <svg classes="UnderlineNav-octicon" display="none inline" height="16" class="octicon octicon-graph UnderlineNav-octicon d-none d-sm-inline" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M1.5 1.75a.75.75 0 00-1.5 0v12.5c0 .414.336.75.75.75h14.5a.75.75 0 000-1.5H1.5V1.75zm14.28 2.53a.75.75 0 00-1.06-1.06L10 7.94 7.53 5.47a.75.75 0 00-1.06 0L3.22 8.72a.75.75 0 001.06 1.06L7 7.06l2.47 2.47a.75.75 0 001.06 0l5.25-5.25z"></path></svg>
            <span data-content="Insights">Insights</span>
              <span title="Not available" class="Counter "></span>
</a>      </li>

</ul>        <div class="position-absolute right-0 pr-3 pr-md-4 pr-lg-5 js-responsive-underlinenav-overflow" style="visibility:hidden;">
      <details class="details-overlay details-reset position-relative">
  <summary role="button">
    <div class="UnderlineNav-item mr-0 border-0">
            <svg class="octicon octicon-kebab-horizontal" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path d="M8 9a1.5 1.5 0 100-3 1.5 1.5 0 000 3zM1.5 9a1.5 1.5 0 100-3 1.5 1.5 0 000 3zm13 0a1.5 1.5 0 100-3 1.5 1.5 0 000 3z"></path></svg>
            <span class="sr-only">More</span>
          </div>
</summary>  <div>
    <details-menu role="menu" class="dropdown-menu dropdown-menu-sw ">

            <ul>
                <li data-menu-item="code-tab" hidden>
                  <a role="menuitem" class="js-selected-navigation-item selected dropdown-item" aria-current="page" data-selected-links=" /LiaScript/LiaScript-Exporter" href="/LiaScript/LiaScript-Exporter">
                    Code
</a>                </li>
                <li data-menu-item="issues-tab" hidden>
                  <a role="menuitem" class="js-selected-navigation-item dropdown-item" data-selected-links=" /LiaScript/LiaScript-Exporter/issues" href="/LiaScript/LiaScript-Exporter/issues">
                    Issues
</a>                </li>
                <li data-menu-item="pull-requests-tab" hidden>
                  <a role="menuitem" class="js-selected-navigation-item dropdown-item" data-selected-links=" /LiaScript/LiaScript-Exporter/pulls" href="/LiaScript/LiaScript-Exporter/pulls">
                    Pull requests
</a>                </li>
                <li data-menu-item="actions-tab" hidden>
                  <a role="menuitem" class="js-selected-navigation-item dropdown-item" data-selected-links=" /LiaScript/LiaScript-Exporter/actions" href="/LiaScript/LiaScript-Exporter/actions">
                    Actions
</a>                </li>
                <li data-menu-item="projects-tab" hidden>
                  <a role="menuitem" class="js-selected-navigation-item dropdown-item" data-selected-links=" /LiaScript/LiaScript-Exporter/projects" href="/LiaScript/LiaScript-Exporter/projects">
                    Projects
</a>                </li>
                <li data-menu-item="security-tab" hidden>
                  <a role="menuitem" class="js-selected-navigation-item dropdown-item" data-selected-links=" /LiaScript/LiaScript-Exporter/security" href="/LiaScript/LiaScript-Exporter/security">
                    Security
</a>                </li>
                <li data-menu-item="insights-tab" hidden>
                  <a role="menuitem" class="js-selected-navigation-item dropdown-item" data-selected-links=" /LiaScript/LiaScript-Exporter/pulse" href="/LiaScript/LiaScript-Exporter/pulse">
                    Insights
</a>                </li>
            </ul>

</details-menu>
</div></details>    </div>

</nav>
  </div>


<div class="container-xl clearfix new-discussion-timeline px-3 px-md-4 px-lg-5">
  <div class="repository-content " >




  <div class="d-none d-lg-block mt-6 mr-3 Popover top-0 right-0 box-shadow-medium col-3">

  </div>

    <signup-prompt class="signup-prompt-bg rounded-1" data-prompt="signup" hidden>
    <div class="signup-prompt p-4 text-center mb-4 rounded-1">
      <div class="position-relative">
        <button
          type="button"
          class="position-absolute top-0 right-0 btn-link link-gray"
          data-action="click:signup-prompt#dismiss"
          data-ga-click="(Logged out) Sign up prompt, clicked Dismiss, text:dismiss"
        >
          Dismiss
        </button>
        <h3 class="pt-2">Join GitHub today</h3>
        <p class="col-6 mx-auto">GitHub is home to over 50 million developers working together to host and review code, manage projects, and build software together.</p>
        <a class="btn btn-primary" data-ga-click="(Logged out) Sign up prompt, clicked Sign up, text:sign-up" data-hydro-click="{&quot;event_type&quot;:&quot;authentication.click&quot;,&quot;payload&quot;:{&quot;location_in_page&quot;:&quot;files signup prompt&quot;,&quot;repository_id&quot;:null,&quot;auth_type&quot;:&quot;SIGN_UP&quot;,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="e05dec9fffe28ad68ebb2f7a2b6e17e6fd63644c0a07274ba474bd280546666b" href="/join?source=prompt-code&amp;source_repo=LiaScript%2FLiaScript-Exporter">Sign up</a>
      </div>
    </div>
  </signup-prompt>



  <div class="gutter-condensed gutter-lg flex-column flex-md-row d-flex">

  <div class="flex-shrink-0 col-12 col-md-9 mb-4 mb-md-0">





      <div class="file-navigation mb-3 d-flex flex-items-start">

<div class="position-relative">
  <details class="details-reset details-overlay mr-0 mb-0 " id="branch-select-menu">
    <summary class="btn css-truncate"
            data-hotkey="w"
            title="Switch branches or tags">
      <svg text="gray" height="16" class="octicon octicon-git-branch text-gray" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M11.75 2.5a.75.75 0 100 1.5.75.75 0 000-1.5zm-2.25.75a2.25 2.25 0 113 2.122V6A2.5 2.5 0 0110 8.5H6a1 1 0 00-1 1v1.128a2.251 2.251 0 11-1.5 0V5.372a2.25 2.25 0 111.5 0v1.836A2.492 2.492 0 016 7h4a1 1 0 001-1v-.628A2.25 2.25 0 019.5 3.25zM4.25 12a.75.75 0 100 1.5.75.75 0 000-1.5zM3.5 3.25a.75.75 0 111.5 0 .75.75 0 01-1.5 0z"></path></svg>
      <span class="css-truncate-target" data-menu-button>master</span>
      <span class="dropdown-caret"></span>
    </summary>

    <details-menu class="SelectMenu SelectMenu--hasFilter" src="/LiaScript/LiaScript-Exporter/refs/master?source_action=disambiguate&amp;source_controller=files" preload>
      <div class="SelectMenu-modal">
        <include-fragment class="SelectMenu-loading" aria-label="Menu is loading">
          <svg class="octicon octicon-octoface anim-pulse" height="32" viewBox="0 0 24 24" version="1.1" width="32" aria-hidden="true"><path d="M7.75 11c-.69 0-1.25.56-1.25 1.25v1.5a1.25 1.25 0 102.5 0v-1.5C9 11.56 8.44 11 7.75 11zm1.27 4.5a.469.469 0 01.48-.5h5a.47.47 0 01.48.5c-.116 1.316-.759 2.5-2.98 2.5s-2.864-1.184-2.98-2.5zm7.23-4.5c-.69 0-1.25.56-1.25 1.25v1.5a1.25 1.25 0 102.5 0v-1.5c0-.69-.56-1.25-1.25-1.25z"></path><path fill-rule="evenodd" d="M21.255 3.82a1.725 1.725 0 00-2.141-1.195c-.557.16-1.406.44-2.264.866-.78.386-1.647.93-2.293 1.677A18.442 18.442 0 0012 5c-.93 0-1.784.059-2.569.17-.645-.74-1.505-1.28-2.28-1.664a13.876 13.876 0 00-2.265-.866 1.725 1.725 0 00-2.141 1.196 23.645 23.645 0 00-.69 3.292c-.125.97-.191 2.07-.066 3.112C1.254 11.882 1 13.734 1 15.527 1 19.915 3.13 23 12 23c8.87 0 11-3.053 11-7.473 0-1.794-.255-3.647-.99-5.29.127-1.046.06-2.15-.066-3.125a23.652 23.652 0 00-.689-3.292zM20.5 14c.5 3.5-1.5 6.5-8.5 6.5s-9-3-8.5-6.5c.583-4 3-6 8.5-6s7.928 2 8.5 6z"></path></svg>
        </include-fragment>
      </div>
    </details-menu>
  </details>

</div>


  <div class="flex-self-center ml-3 flex-self-stretch d-none d-lg-flex flex-items-center lh-condensed-ultra">
    <a data-pjax href="/LiaScript/LiaScript-Exporter/branches" class="link-gray-dark no-underline">
      <svg text="gray" height="16" class="octicon octicon-git-branch text-gray" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M11.75 2.5a.75.75 0 100 1.5.75.75 0 000-1.5zm-2.25.75a2.25 2.25 0 113 2.122V6A2.5 2.5 0 0110 8.5H6a1 1 0 00-1 1v1.128a2.251 2.251 0 11-1.5 0V5.372a2.25 2.25 0 111.5 0v1.836A2.492 2.492 0 016 7h4a1 1 0 001-1v-.628A2.25 2.25 0 019.5 3.25zM4.25 12a.75.75 0 100 1.5.75.75 0 000-1.5zM3.5 3.25a.75.75 0 111.5 0 .75.75 0 01-1.5 0z"></path></svg>
      <strong>1</strong>
      <span class="text-gray-light">branch</span>
    </a>
    <a data-pjax href="/LiaScript/LiaScript-Exporter/tags" class="ml-3 link-gray-dark no-underline">
      <svg text="gray" height="16" class="octicon octicon-tag text-gray" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M2.5 7.775V2.75a.25.25 0 01.25-.25h5.025a.25.25 0 01.177.073l6.25 6.25a.25.25 0 010 .354l-5.025 5.025a.25.25 0 01-.354 0l-6.25-6.25a.25.25 0 01-.073-.177zm-1.5 0V2.75C1 1.784 1.784 1 2.75 1h5.025c.464 0 .91.184 1.238.513l6.25 6.25a1.75 1.75 0 010 2.474l-5.026 5.026a1.75 1.75 0 01-2.474 0l-6.25-6.25A1.75 1.75 0 011 7.775zM6 5a1 1 0 100 2 1 1 0 000-2z"></path></svg>
      <strong>5</strong>
      <span class="text-gray-light">tags</span>
    </a>
  </div>

  <div class="flex-auto"></div>

  <a class="btn ml-2" data-hydro-click="{&quot;event_type&quot;:&quot;repository.click&quot;,&quot;payload&quot;:{&quot;target&quot;:&quot;FIND_FILE_BUTTON&quot;,&quot;repository_id&quot;:252826941,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="466d6cbf8b3a1bbedc840f2fd4105d9a2690640f734ee9aca850a8e2c58bb8b4" data-ga-click="Repository, find file, location:repo overview" data-hotkey="t" data-pjax="true" href="/LiaScript/LiaScript-Exporter/find/master">
    Go to file
</a>



    <span class="d-none d-md-flex ml-2">

<get-repo>
  <details class="position-relative details-overlay details-reset" data-action="toggle:get-repo#onDetailsToggle">
    <summary class="btn btn-primary" data-hydro-click="{&quot;event_type&quot;:&quot;repository.click&quot;,&quot;payload&quot;:{&quot;repository_id&quot;:252826941,&quot;target&quot;:&quot;CLONE_OR_DOWNLOAD_BUTTON&quot;,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="15d3263b551fab7a8c09049c1eb1502e5f6dc2f4188bfcd3babb9c402b429ec7">
      <svg class="octicon octicon-download mr-1" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M7.47 10.78a.75.75 0 001.06 0l3.75-3.75a.75.75 0 00-1.06-1.06L8.75 8.44V1.75a.75.75 0 00-1.5 0v6.69L4.78 5.97a.75.75 0 00-1.06 1.06l3.75 3.75zM3.75 13a.75.75 0 000 1.5h8.5a.75.75 0 000-1.5h-8.5z"></path></svg>
      Code
      <span class="dropdown-caret"></span>
</summary>    <div class="position-relative">
      <div class="dropdown-menu dropdown-menu-sw p-0" style="top:6px;width:352px;">
        <div data-target="get-repo.modal">
          <div class="border-bottom p-3">
            <a class="muted-link float-right tooltipped tooltipped-s" href="https://docs.github.com/articles/which-remote-url-should-i-use" target="_blank" aria-label="Which remote URL should I use?">
  <svg class="octicon octicon-question" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M8 1.5a6.5 6.5 0 100 13 6.5 6.5 0 000-13zM0 8a8 8 0 1116 0A8 8 0 010 8zm9 3a1 1 0 11-2 0 1 1 0 012 0zM6.92 6.085c.081-.16.19-.299.34-.398.145-.097.371-.187.74-.187.28 0 .553.087.738.225A.613.613 0 019 6.25c0 .177-.04.264-.077.318a.956.956 0 01-.277.245c-.076.051-.158.1-.258.161l-.007.004a7.728 7.728 0 00-.313.195 2.416 2.416 0 00-.692.661.75.75 0 001.248.832.956.956 0 01.276-.245 6.3 6.3 0 01.26-.16l.006-.004c.093-.057.204-.123.313-.195.222-.149.487-.355.692-.662.214-.32.329-.702.329-1.15 0-.76-.36-1.348-.863-1.725A2.76 2.76 0 008 4c-.631 0-1.155.16-1.572.438-.413.276-.68.638-.849.977a.75.75 0 101.342.67z"></path></svg>
</a>

<div class="text-bold">
  <svg class="octicon octicon-terminal mr-3" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M0 2.75C0 1.784.784 1 1.75 1h12.5c.966 0 1.75.784 1.75 1.75v10.5A1.75 1.75 0 0114.25 15H1.75A1.75 1.75 0 010 13.25V2.75zm1.75-.25a.25.25 0 00-.25.25v10.5c0 .138.112.25.25.25h12.5a.25.25 0 00.25-.25V2.75a.25.25 0 00-.25-.25H1.75zM7.25 8a.75.75 0 01-.22.53l-2.25 2.25a.75.75 0 11-1.06-1.06L5.44 8 3.72 6.28a.75.75 0 111.06-1.06l2.25 2.25c.141.14.22.331.22.53zm1.5 1.5a.75.75 0 000 1.5h3a.75.75 0 000-1.5h-3z"></path></svg>
  Clone
</div>

<tab-container>

  <div class="UnderlineNav my-2 box-shadow-none">
    <div class="UnderlineNav-body" role="tablist">
      <!-- '"` --><!-- </textarea></xmp> --></option></form><form data-remote="true" action="/users/set_protocol?protocol_type=clone" accept-charset="UTF-8" method="post"><input type="hidden" data-csrf="true" name="authenticity_token" value="MaWpF5w3nHZYwQT6Ay32rv5pM3894mywhMEiXmhagJtaCbC8ShlPAzY4onFzr2HSlANuuckca+Z2MXYk1rmOMg==" />
          <button name="protocol_selector" type="submit" role="tab" class="UnderlineNav-item lh-default f6 py-0 px-0 mr-2 position-relative" aria-selected="true" value="http" data-hydro-click="{&quot;event_type&quot;:&quot;clone_or_download.click&quot;,&quot;payload&quot;:{&quot;feature_clicked&quot;:&quot;USE_HTTPS&quot;,&quot;git_repository_type&quot;:&quot;REPOSITORY&quot;,&quot;repository_id&quot;:252826941,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="0fae3d207ab57180fa646a057da994c416f8fc70de85960b6bbed31c6bc19502">
            HTTPS
</button>          <button name="protocol_selector" type="submit" role="tab" class="UnderlineNav-item lh-default f6 py-0 px-0 mr-2 position-relative" value="gh_cli" data-hydro-click="{&quot;event_type&quot;:&quot;clone_or_download.click&quot;,&quot;payload&quot;:{&quot;feature_clicked&quot;:&quot;USE_GH_CLI&quot;,&quot;git_repository_type&quot;:&quot;REPOSITORY&quot;,&quot;repository_id&quot;:252826941,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="2092feab1bc5476aef37b083ec3edfd6e4e0862c517f2c48845f2c0ac0908d1f">
            GitHub CLI
</button></form>    </div>
  </div>

  <div role="tabpanel">
    <div class="input-group">
  <input type="text" class="form-control input-monospace input-sm bg-gray-light" data-autoselect value="https://github.com/LiaScript/LiaScript-Exporter.git" aria-label="https://github.com/LiaScript/LiaScript-Exporter.git" readonly>
  <div class="input-group-button">
    <clipboard-copy value="https://github.com/LiaScript/LiaScript-Exporter.git" aria-label="Copy to clipboard" class="btn btn-sm" data-hydro-click="{&quot;event_type&quot;:&quot;clone_or_download.click&quot;,&quot;payload&quot;:{&quot;feature_clicked&quot;:&quot;COPY_URL&quot;,&quot;git_repository_type&quot;:&quot;REPOSITORY&quot;,&quot;repository_id&quot;:252826941,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="457dfb41035247ee741651cc3637b839a9a9f12f29503219f30e5a310e465f9e"><svg class="octicon octicon-clippy" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M5.75 1a.75.75 0 00-.75.75v3c0 .414.336.75.75.75h4.5a.75.75 0 00.75-.75v-3a.75.75 0 00-.75-.75h-4.5zm.75 3V2.5h3V4h-3zm-2.874-.467a.75.75 0 00-.752-1.298A1.75 1.75 0 002 3.75v9.5c0 .966.784 1.75 1.75 1.75h8.5A1.75 1.75 0 0014 13.25v-9.5a1.75 1.75 0 00-.874-1.515.75.75 0 10-.752 1.298.25.25 0 01.126.217v9.5a.25.25 0 01-.25.25h-8.5a.25.25 0 01-.25-.25v-9.5a.25.25 0 01.126-.217z"></path></svg></clipboard-copy>
  </div>
</div>

    <p class="mt-2 mb-0 f6 text-gray">
      Use Git or checkout with SVN using the web URL.
    </p>
  </div>


  <div role="tabpanel" hidden>
    <div class="input-group">
  <input type="text" class="form-control input-monospace input-sm bg-gray-light" data-autoselect value="gh repo clone LiaScript/LiaScript-Exporter" aria-label="gh repo clone LiaScript/LiaScript-Exporter" readonly>
  <div class="input-group-button">
    <clipboard-copy value="gh repo clone LiaScript/LiaScript-Exporter" aria-label="Copy to clipboard" class="btn btn-sm" data-hydro-click="{&quot;event_type&quot;:&quot;clone_or_download.click&quot;,&quot;payload&quot;:{&quot;feature_clicked&quot;:&quot;COPY_URL&quot;,&quot;git_repository_type&quot;:&quot;REPOSITORY&quot;,&quot;repository_id&quot;:252826941,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="457dfb41035247ee741651cc3637b839a9a9f12f29503219f30e5a310e465f9e"><svg class="octicon octicon-clippy" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M5.75 1a.75.75 0 00-.75.75v3c0 .414.336.75.75.75h4.5a.75.75 0 00.75-.75v-3a.75.75 0 00-.75-.75h-4.5zm.75 3V2.5h3V4h-3zm-2.874-.467a.75.75 0 00-.752-1.298A1.75 1.75 0 002 3.75v9.5c0 .966.784 1.75 1.75 1.75h8.5A1.75 1.75 0 0014 13.25v-9.5a1.75 1.75 0 00-.874-1.515.75.75 0 10-.752 1.298.25.25 0 01.126.217v9.5a.25.25 0 01-.25.25h-8.5a.25.25 0 01-.25-.25v-9.5a.25.25 0 01.126-.217z"></path></svg></clipboard-copy>
  </div>
</div>

    <p class="mt-2 mb-0 f6 text-gray">
      Work fast with our official CLI.
      <a href="https://cli.github.com" target="_blank">Learn more</a>.
    </p>
  </div>
</tab-container>

          </div>
          <ul class="list-style-none">
            <li data-platforms="windows,mac" class="Box-row Box-row--hover-gray p-0 rounded-0 mt-0 js-remove-unless-platform">
              <a class="d-flex flex-items-center text-gray-dark text-bold no-underline p-3" data-hydro-click="{&quot;event_type&quot;:&quot;clone_or_download.click&quot;,&quot;payload&quot;:{&quot;feature_clicked&quot;:&quot;OPEN_IN_DESKTOP&quot;,&quot;git_repository_type&quot;:&quot;REPOSITORY&quot;,&quot;repository_id&quot;:252826941,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="aa43a608fb5e6ed2d1b56546576188f6073b46d67412427dd225ea68e9f8c908" data-action="click:get-repo#showDownloadMessage" href="https://desktop.github.com">
                <svg class="octicon octicon-desktop-download mr-3" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M8.75 5V.75a.75.75 0 00-1.5 0V5H5.104a.25.25 0 00-.177.427l2.896 2.896a.25.25 0 00.354 0l2.896-2.896A.25.25 0 0010.896 5H8.75zM1.5 2.75a.25.25 0 01.25-.25h3a.75.75 0 000-1.5h-3A1.75 1.75 0 000 2.75v7.5C0 11.216.784 12 1.75 12h3.727c-.1 1.041-.52 1.872-1.292 2.757A.75.75 0 004.75 16h6.5a.75.75 0 00.565-1.243c-.772-.885-1.193-1.716-1.292-2.757h3.727A1.75 1.75 0 0016 10.25v-7.5A1.75 1.75 0 0014.25 1h-3a.75.75 0 000 1.5h3a.25.25 0 01.25.25v7.5a.25.25 0 01-.25.25H1.75a.25.25 0 01-.25-.25v-7.5zM9.018 12H6.982a5.72 5.72 0 01-.765 2.5h3.566a5.72 5.72 0 01-.765-2.5z"></path></svg>
                Open with GitHub Desktop
</a>            </li>
            <li class="Box-row Box-row--hover-gray p-0">
              <a class="d-flex flex-items-center text-gray-dark text-bold no-underline p-3" rel="nofollow" data-hydro-click="{&quot;event_type&quot;:&quot;clone_or_download.click&quot;,&quot;payload&quot;:{&quot;feature_clicked&quot;:&quot;DOWNLOAD_ZIP&quot;,&quot;git_repository_type&quot;:&quot;REPOSITORY&quot;,&quot;repository_id&quot;:252826941,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}" data-hydro-click-hmac="4741d64ed1810dd87cd672443e98d1d92a4471476f0a98c7c94ec1533c8d01f8" data-ga-click="Repository, download zip, location:repo overview" data-open-app="link" href="/LiaScript/LiaScript-Exporter/archive/master.zip">
                <svg class="octicon octicon-file-zip mr-3" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M3.5 1.75a.25.25 0 01.25-.25h3a.75.75 0 000 1.5h.5a.75.75 0 000-1.5h2.086a.25.25 0 01.177.073l2.914 2.914a.25.25 0 01.073.177v8.586a.25.25 0 01-.25.25h-.5a.75.75 0 000 1.5h.5A1.75 1.75 0 0014 13.25V4.664c0-.464-.184-.909-.513-1.237L10.573.513A1.75 1.75 0 009.336 0H3.75A1.75 1.75 0 002 1.75v11.5c0 .649.353 1.214.874 1.515a.75.75 0 10.752-1.298.25.25 0 01-.126-.217V1.75zM8.75 3a.75.75 0 000 1.5h.5a.75.75 0 000-1.5h-.5zM6 5.25a.75.75 0 01.75-.75h.5a.75.75 0 010 1.5h-.5A.75.75 0 016 5.25zm2 1.5A.75.75 0 018.75 6h.5a.75.75 0 010 1.5h-.5A.75.75 0 018 6.75zm-1.25.75a.75.75 0 000 1.5h.5a.75.75 0 000-1.5h-.5zM8 9.75A.75.75 0 018.75 9h.5a.75.75 0 010 1.5h-.5A.75.75 0 018 9.75zm-.75.75a1.75 1.75 0 00-1.75 1.75v3c0 .414.336.75.75.75h2.5a.75.75 0 00.75-.75v-3a1.75 1.75 0 00-1.75-1.75h-.5zM7 12.25a.25.25 0 01.25-.25h.5a.25.25 0 01.25.25v2.25H7v-2.25z"></path></svg>
                Download ZIP
</a>            </li>
          </ul>
        </div>

        <div class="p-3" data-targets="get-repo.platforms" data-platform="mac" hidden>
          <h4 class="lh-condensed mb-3">Launching GitHub Desktop<span class="AnimatedEllipsis"></span></h4>
          <p class="text-gray">If nothing happens, <a href="https://desktop.github.com/">download GitHub Desktop</a> and try again.</p>
          <button type="button" class="btn-link" data-action="click:get-repo#onDetailsToggle">Go back</button>
        </div>

        <div class="p-3" data-targets="get-repo.platforms" data-platform="windows" hidden>
          <h4 class="lh-condensed mb-3">Launching GitHub Desktop<span class="AnimatedEllipsis"></span></h4>
          <p class="text-gray">If nothing happens, <a href="https://desktop.github.com/">download GitHub Desktop</a> and try again.</p>
          <button type="button" class="btn-link" data-action="click:get-repo#onDetailsToggle">Go back</button>
        </div>

        <div class="p-3" data-targets="get-repo.platforms" data-platform="xcode" hidden>
          <h4 class="lh-condensed mb-3">Launching Xcode<span class="AnimatedEllipsis"></span></h4>
          <p class="text-gray">If nothing happens, <a href="https://developer.apple.com/xcode/">download Xcode</a> and try again.</p>
          <button type="button" class="btn-link" data-action="click:get-repo#onDetailsToggle">Go back</button>
        </div>

        <div class="p-3" data-targets="get-repo.platforms" data-platform="visual-studio" hidden>
          <h4 class="lh-condensed mb-3">Launching Visual Studio<span class="AnimatedEllipsis"></span></h4>
          <p class="text-gray">If nothing happens, <a href="https://visualstudio.github.com/">download the GitHub extension for Visual Studio</a> and try again.</p>
          <button type="button" class="btn-link" data-action="click:get-repo#onDetailsToggle">Go back</button>
        </div>

      </div>
    </div>
  </details>
</get-repo>



    </span>
</div>




<div class="Box mb-3">
  <div class="Box-header Box-header--blue position-relative">
    <h2 class="sr-only">Latest commit</h2>
    <div class="js-details-container Details d-flex rounded-top-1 flex-items-center flex-wrap" data-issue-and-pr-hovercards-enabled>
      <include-fragment src="/LiaScript/LiaScript-Exporter/tree-commit/8f761952a5be43a5aaa22dce545fc9fdc0471961" class="d-flex flex-auto flex-items-center" aria-busy="true" aria-label="Loading latest commit">
        <div class="Skeleton avatar avatar-user flex-shrink-0 ml-n1 mr-n1 mt-n1 mb-n1" style="width:24px;height:24px;"></div>
        <div class="Skeleton Skeleton--text col-5 ml-3">&nbsp;</div>
</include-fragment>      <div class="flex-shrink-0">
        <h2 class="sr-only">Git stats</h2>
        <ul class="list-style-none d-flex">
          <li class="ml-0 ml-md-3">
            <a data-pjax href="/LiaScript/LiaScript-Exporter/commits/master" class="pl-3 pr-3 py-3 p-md-0 mt-n3 mb-n3 mr-n3 m-md-0 link-gray-dark no-underline no-wrap">
              <svg text="gray" height="16" class="octicon octicon-history text-gray" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M1.643 3.143L.427 1.927A.25.25 0 000 2.104V5.75c0 .138.112.25.25.25h3.646a.25.25 0 00.177-.427L2.715 4.215a6.5 6.5 0 11-1.18 4.458.75.75 0 10-1.493.154 8.001 8.001 0 101.6-5.684zM7.75 4a.75.75 0 01.75.75v2.992l2.028.812a.75.75 0 01-.557 1.392l-2.5-1A.75.75 0 017 8.25v-3.5A.75.75 0 017.75 4z"></path></svg>
              <span class="d-none d-sm-inline">
                    <strong>51</strong>
                  <span aria-label="Commits on master" class="text-gray d-none d-lg-inline">commits</span>
              </span>
            </a>
          </li>
        </ul>
      </div>
    </div>
  </div>
  <h2 id="files"  class="sr-only">Files</h2>



  <include-fragment src="/LiaScript/LiaScript-Exporter/file-list/master">
      <a class="d-none js-permalink-shortcut" data-hotkey="y" href="/LiaScript/LiaScript-Exporter/tree/8f761952a5be43a5aaa22dce545fc9fdc0471961">Permalink</a>

  <div class="include-fragment-error flash flash-error flash-full py-2">
  <svg height="16" class="octicon octicon-alert" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M8.22 1.754a.25.25 0 00-.44 0L1.698 13.132a.25.25 0 00.22.368h12.164a.25.25 0 00.22-.368L8.22 1.754zm-1.763-.707c.659-1.234 2.427-1.234 3.086 0l6.082 11.378A1.75 1.75 0 0114.082 15H1.918a1.75 1.75 0 01-1.543-2.575L6.457 1.047zM9 11a1 1 0 11-2 0 1 1 0 012 0zm-.25-5.25a.75.75 0 00-1.5 0v2.5a.75.75 0 001.5 0v-2.5z"></path></svg>

    Failed to load latest commit information.

</div>  <div class="js-details-container Details">
    <div role="grid" aria-labelledby="files" class="Details-content--hidden-not-important js-navigation-container js-active-navigation-container d-md-block" data-pjax>
      <div class="sr-only" role="row">
        <div role="columnheader">Type</div>
        <div role="columnheader">Name</div>
        <div role="columnheader" class="d-none d-md-block">Latest commit message</div>
        <div role="columnheader">Commit time</div>
      </div>

        <div role="row" class="Box-row Box-row--focus-gray py-2 d-flex position-relative js-navigation-item ">
          <div role="gridcell" class="mr-3 flex-shrink-0" style="width: 16px;">
              <svg color="blue-3" aria-label="Submodule" height="16" class="octicon octicon-file-submodule color-blue-3" viewBox="0 0 16 16" version="1.1" width="16" role="img"><path fill-rule="evenodd" d="M0 2.75C0 1.784.784 1 1.75 1H5c.55 0 1.07.26 1.4.7l.9 1.2a.25.25 0 00.2.1h6.75c.966 0 1.75.784 1.75 1.75v8.5A1.75 1.75 0 0114.25 15H1.75A1.75 1.75 0 010 13.25V2.75zm9.42 9.36l2.883-2.677a.25.25 0 000-.366L9.42 6.39a.25.25 0 00-.42.183V8.5H4.75a.75.75 0 100 1.5H9v1.927c0 .218.26.331.42.183z"></path></svg>

          </div>

          <div role="rowheader" class="flex-auto min-width-0 col-md-2 mr-3">
            <span class="css-truncate css-truncate-target d-block width-fit"><span title="LiaScript @ ab837a6"><a data-skip-pjax="true" href="/LiaScript/LiaScript/tree/ab837a6f58a20552c83eb1cca5508dd3f8851deb">LiaScript @ ab837a6</a></span></span>
          </div>

          <div role="gridcell" class="flex-auto min-width-0 d-none d-md-block col-5 mr-3 commit-message">
              <div class="Skeleton Skeleton--text col-7">&nbsp;</div>
          </div>

          <div role="gridcell" class="text-gray-light text-right" style="width:100px;">
              <div class="Skeleton Skeleton--text">&nbsp;</div>
          </div>

        </div>
        <div role="row" class="Box-row Box-row--focus-gray py-2 d-flex position-relative js-navigation-item ">
          <div role="gridcell" class="mr-3 flex-shrink-0" style="width: 16px;">
              <svg color="blue-3" aria-label="Directory" height="16" class="octicon octicon-file-directory color-blue-3" viewBox="0 0 16 16" version="1.1" width="16" role="img"><path fill-rule="evenodd" d="M1.75 1A1.75 1.75 0 000 2.75v10.5C0 14.216.784 15 1.75 15h12.5A1.75 1.75 0 0016 13.25v-8.5A1.75 1.75 0 0014.25 3h-6.5a.25.25 0 01-.2-.1l-.9-1.2c-.33-.44-.85-.7-1.4-.7h-3.5z"></path></svg>

          </div>

          <div role="rowheader" class="flex-auto min-width-0 col-md-2 mr-3">
            <span class="css-truncate css-truncate-target d-block width-fit"><a class="js-navigation-open link-gray-dark" title="dist" id="2a6d07eef8b10b84129b42424ed99327-1dec7aeee153af3d62b1666a40b0a72901d20438" href="/LiaScript/LiaScript-Exporter/tree/master/dist">dist</a></span>
          </div>

          <div role="gridcell" class="flex-auto min-width-0 d-none d-md-block col-5 mr-3 commit-message">
              <div class="Skeleton Skeleton--text col-7">&nbsp;</div>
          </div>

          <div role="gridcell" class="text-gray-light text-right" style="width:100px;">
              <div class="Skeleton Skeleton--text">&nbsp;</div>
          </div>

        </div>
        <div role="row" class="Box-row Box-row--focus-gray py-2 d-flex position-relative js-navigation-item ">
          <div role="gridcell" class="mr-3 flex-shrink-0" style="width: 16px;">
              <svg color="blue-3" aria-label="Directory" height="16" class="octicon octicon-file-directory color-blue-3" viewBox="0 0 16 16" version="1.1" width="16" role="img"><path fill-rule="evenodd" d="M1.75 1A1.75 1.75 0 000 2.75v10.5C0 14.216.784 15 1.75 15h12.5A1.75 1.75 0 0016 13.25v-8.5A1.75 1.75 0 0014.25 3h-6.5a.25.25 0 01-.2-.1l-.9-1.2c-.33-.44-.85-.7-1.4-.7h-3.5z"></path></svg>

          </div>

          <div role="rowheader" class="flex-auto min-width-0 col-md-2 mr-3">
            <span class="css-truncate css-truncate-target d-block width-fit"><a class="js-navigation-open link-gray-dark" title="src" id="25d902c24283ab8cfbac54dfa101ad31-3aed68efa11905b59a6ccc5a3e6fc28ea03252cc" href="/LiaScript/LiaScript-Exporter/tree/master/src">src</a></span>
          </div>

          <div role="gridcell" class="flex-auto min-width-0 d-none d-md-block col-5 mr-3 commit-message">
              <div class="Skeleton Skeleton--text col-7">&nbsp;</div>
          </div>

          <div role="gridcell" class="text-gray-light text-right" style="width:100px;">
              <div class="Skeleton Skeleton--text">&nbsp;</div>
          </div>

        </div>
        <div role="row" class="Box-row Box-row--focus-gray py-2 d-flex position-relative js-navigation-item ">
          <div role="gridcell" class="mr-3 flex-shrink-0" style="width: 16px;">
              <svg color="gray-light" aria-label="File" height="16" class="octicon octicon-file text-gray-light" viewBox="0 0 16 16" version="1.1" width="16" role="img"><path fill-rule="evenodd" d="M3.75 1.5a.25.25 0 00-.25.25v11.5c0 .138.112.25.25.25h8.5a.25.25 0 00.25-.25V6H9.75A1.75 1.75 0 018 4.25V1.5H3.75zm5.75.56v2.19c0 .138.112.25.25.25h2.19L9.5 2.06zM2 1.75C2 .784 2.784 0 3.75 0h5.086c.464 0 .909.184 1.237.513l3.414 3.414c.329.328.513.773.513 1.237v8.086A1.75 1.75 0 0112.25 15h-8.5A1.75 1.75 0 012 13.25V1.75z"></path></svg>

          </div>

          <div role="rowheader" class="flex-auto min-width-0 col-md-2 mr-3">
            <span class="css-truncate css-truncate-target d-block width-fit"><a class="js-navigation-open link-gray-dark" title=".gitignore" id="a084b794bc0759e7a6b77810e01874f2-906979f0f7549c0e941b18a3d00dee58ec6907da" href="/LiaScript/LiaScript-Exporter/blob/master/.gitignore">.gitignore</a></span>
          </div>

          <div role="gridcell" class="flex-auto min-width-0 d-none d-md-block col-5 mr-3 commit-message">
              <div class="Skeleton Skeleton--text col-7">&nbsp;</div>
          </div>

          <div role="gridcell" class="text-gray-light text-right" style="width:100px;">
              <div class="Skeleton Skeleton--text">&nbsp;</div>
          </div>

        </div>
        <div role="row" class="Box-row Box-row--focus-gray py-2 d-flex position-relative js-navigation-item ">
          <div role="gridcell" class="mr-3 flex-shrink-0" style="width: 16px;">
              <svg color="gray-light" aria-label="File" height="16" class="octicon octicon-file text-gray-light" viewBox="0 0 16 16" version="1.1" width="16" role="img"><path fill-rule="evenodd" d="M3.75 1.5a.25.25 0 00-.25.25v11.5c0 .138.112.25.25.25h8.5a.25.25 0 00.25-.25V6H9.75A1.75 1.75 0 018 4.25V1.5H3.75zm5.75.56v2.19c0 .138.112.25.25.25h2.19L9.5 2.06zM2 1.75C2 .784 2.784 0 3.75 0h5.086c.464 0 .909.184 1.237.513l3.414 3.414c.329.328.513.773.513 1.237v8.086A1.75 1.75 0 0112.25 15h-8.5A1.75 1.75 0 012 13.25V1.75z"></path></svg>

          </div>

          <div role="rowheader" class="flex-auto min-width-0 col-md-2 mr-3">
            <span class="css-truncate css-truncate-target d-block width-fit"><a class="js-navigation-open link-gray-dark" title=".gitmodules" id="8903239df476d7401cf9e76af0252622-ede3efa6e32de23566d42b3d0f631bbe21103904" href="/LiaScript/LiaScript-Exporter/blob/master/.gitmodules">.gitmodules</a></span>
          </div>

          <div role="gridcell" class="flex-auto min-width-0 d-none d-md-block col-5 mr-3 commit-message">
              <div class="Skeleton Skeleton--text col-7">&nbsp;</div>
          </div>

          <div role="gridcell" class="text-gray-light text-right" style="width:100px;">
              <div class="Skeleton Skeleton--text">&nbsp;</div>
          </div>

        </div>
        <div role="row" class="Box-row Box-row--focus-gray py-2 d-flex position-relative js-navigation-item ">
          <div role="gridcell" class="mr-3 flex-shrink-0" style="width: 16px;">
              <svg color="gray-light" aria-label="File" height="16" class="octicon octicon-file text-gray-light" viewBox="0 0 16 16" version="1.1" width="16" role="img"><path fill-rule="evenodd" d="M3.75 1.5a.25.25 0 00-.25.25v11.5c0 .138.112.25.25.25h8.5a.25.25 0 00.25-.25V6H9.75A1.75 1.75 0 018 4.25V1.5H3.75zm5.75.56v2.19c0 .138.112.25.25.25h2.19L9.5 2.06zM2 1.75C2 .784 2.784 0 3.75 0h5.086c.464 0 .909.184 1.237.513l3.414 3.414c.329.328.513.773.513 1.237v8.086A1.75 1.75 0 0112.25 15h-8.5A1.75 1.75 0 012 13.25V1.75z"></path></svg>

          </div>

          <div role="rowheader" class="flex-auto min-width-0 col-md-2 mr-3">
            <span class="css-truncate css-truncate-target d-block width-fit"><a class="js-navigation-open link-gray-dark" title="LICENSE" id="9879d6db96fd29134fc802214163b95a-81a7c7c0992da305351b7122f794b235810b0c12" itemprop="license" href="/LiaScript/LiaScript-Exporter/blob/master/LICENSE">LICENSE</a></span>
          </div>

          <div role="gridcell" class="flex-auto min-width-0 d-none d-md-block col-5 mr-3 commit-message">
              <div class="Skeleton Skeleton--text col-7">&nbsp;</div>
          </div>

          <div role="gridcell" class="text-gray-light text-right" style="width:100px;">
              <div class="Skeleton Skeleton--text">&nbsp;</div>
          </div>

        </div>
        <div role="row" class="Box-row Box-row--focus-gray py-2 d-flex position-relative js-navigation-item ">
          <div role="gridcell" class="mr-3 flex-shrink-0" style="width: 16px;">
              <svg color="gray-light" aria-label="File" height="16" class="octicon octicon-file text-gray-light" viewBox="0 0 16 16" version="1.1" width="16" role="img"><path fill-rule="evenodd" d="M3.75 1.5a.25.25 0 00-.25.25v11.5c0 .138.112.25.25.25h8.5a.25.25 0 00.25-.25V6H9.75A1.75 1.75 0 018 4.25V1.5H3.75zm5.75.56v2.19c0 .138.112.25.25.25h2.19L9.5 2.06zM2 1.75C2 .784 2.784 0 3.75 0h5.086c.464 0 .909.184 1.237.513l3.414 3.414c.329.328.513.773.513 1.237v8.086A1.75 1.75 0 0112.25 15h-8.5A1.75 1.75 0 012 13.25V1.75z"></path></svg>

          </div>

          <div role="rowheader" class="flex-auto min-width-0 col-md-2 mr-3">
            <span class="css-truncate css-truncate-target d-block width-fit"><a class="js-navigation-open link-gray-dark" title="README.md" id="04c6e90faac2675aa89e2176d2eec7d8-bad7cd509322e37202f265b3dea242140b582df5" href="/LiaScript/LiaScript-Exporter/blob/master/README.md">README.md</a></span>
          </div>

          <div role="gridcell" class="flex-auto min-width-0 d-none d-md-block col-5 mr-3 commit-message">
              <div class="Skeleton Skeleton--text col-7">&nbsp;</div>
          </div>

          <div role="gridcell" class="text-gray-light text-right" style="width:100px;">
              <div class="Skeleton Skeleton--text">&nbsp;</div>
          </div>

        </div>
        <div role="row" class="Box-row Box-row--focus-gray py-2 d-flex position-relative js-navigation-item ">
          <div role="gridcell" class="mr-3 flex-shrink-0" style="width: 16px;">
              <svg color="gray-light" aria-label="File" height="16" class="octicon octicon-file text-gray-light" viewBox="0 0 16 16" version="1.1" width="16" role="img"><path fill-rule="evenodd" d="M3.75 1.5a.25.25 0 00-.25.25v11.5c0 .138.112.25.25.25h8.5a.25.25 0 00.25-.25V6H9.75A1.75 1.75 0 018 4.25V1.5H3.75zm5.75.56v2.19c0 .138.112.25.25.25h2.19L9.5 2.06zM2 1.75C2 .784 2.784 0 3.75 0h5.086c.464 0 .909.184 1.237.513l3.414 3.414c.329.328.513.773.513 1.237v8.086A1.75 1.75 0 0112.25 15h-8.5A1.75 1.75 0 012 13.25V1.75z"></path></svg>

          </div>

          <div role="rowheader" class="flex-auto min-width-0 col-md-2 mr-3">
            <span class="css-truncate css-truncate-target d-block width-fit"><a class="js-navigation-open link-gray-dark" title="package-lock.json" id="32607347f8126e6534ebc7ebaec4853d-598a5d401a08abc16b9fe80e8f8d00f6a839ea76" href="/LiaScript/LiaScript-Exporter/blob/master/package-lock.json">package-lock.json</a></span>
          </div>

          <div role="gridcell" class="flex-auto min-width-0 d-none d-md-block col-5 mr-3 commit-message">
              <div class="Skeleton Skeleton--text col-7">&nbsp;</div>
          </div>

          <div role="gridcell" class="text-gray-light text-right" style="width:100px;">
              <div class="Skeleton Skeleton--text">&nbsp;</div>
          </div>

        </div>
        <div role="row" class="Box-row Box-row--focus-gray py-2 d-flex position-relative js-navigation-item ">
          <div role="gridcell" class="mr-3 flex-shrink-0" style="width: 16px;">
              <svg color="gray-light" aria-label="File" height="16" class="octicon octicon-file text-gray-light" viewBox="0 0 16 16" version="1.1" width="16" role="img"><path fill-rule="evenodd" d="M3.75 1.5a.25.25 0 00-.25.25v11.5c0 .138.112.25.25.25h8.5a.25.25 0 00.25-.25V6H9.75A1.75 1.75 0 018 4.25V1.5H3.75zm5.75.56v2.19c0 .138.112.25.25.25h2.19L9.5 2.06zM2 1.75C2 .784 2.784 0 3.75 0h5.086c.464 0 .909.184 1.237.513l3.414 3.414c.329.328.513.773.513 1.237v8.086A1.75 1.75 0 0112.25 15h-8.5A1.75 1.75 0 012 13.25V1.75z"></path></svg>

          </div>

          <div role="rowheader" class="flex-auto min-width-0 col-md-2 mr-3">
            <span class="css-truncate css-truncate-target d-block width-fit"><a class="js-navigation-open link-gray-dark" title="package.json" id="b9cfc7f2cdf78a7f4b91a753d10865a2-05aca23d02bedab850475a9e4ec2af44ee55ad92" href="/LiaScript/LiaScript-Exporter/blob/master/package.json">package.json</a></span>
          </div>

          <div role="gridcell" class="flex-auto min-width-0 d-none d-md-block col-5 mr-3 commit-message">
              <div class="Skeleton Skeleton--text col-7">&nbsp;</div>
          </div>

          <div role="gridcell" class="text-gray-light text-right" style="width:100px;">
              <div class="Skeleton Skeleton--text">&nbsp;</div>
          </div>

        </div>
    </div>
    <div class="Details-content--shown Box-footer d-md-none p-0">
      <button type="button" class="d-block btn-link js-details-target width-full px-3 py-2" aria-expanded="false">
        View code
      </button>
    </div>
  </div>

</include-fragment>


</div>

  <div id="readme" class="Box md js-code-block-container Box--responsive">
    <div class="Box-header d-flex flex-items-center flex-justify-between bg-white border-bottom-0">
      <h2 class="Box-title pr-3">
        README.md
      </h2>
    </div>
        <div class="Popover anim-scale-in js-tagsearch-popover"
     hidden
     data-tagsearch-url="/LiaScript/LiaScript-Exporter/find-definition"
     data-tagsearch-ref="master"
     data-tagsearch-path="README.md"
     data-tagsearch-lang="Markdown"
     data-hydro-click="{&quot;event_type&quot;:&quot;code_navigation.click_on_symbol&quot;,&quot;payload&quot;:{&quot;action&quot;:&quot;click_on_symbol&quot;,&quot;repository_id&quot;:252826941,&quot;ref&quot;:&quot;master&quot;,&quot;language&quot;:&quot;Markdown&quot;,&quot;originating_url&quot;:&quot;https://github.com/LiaScript/LiaScript-Exporter&quot;,&quot;user_id&quot;:null}}"
     data-hydro-click-hmac="2e6773efc558eb9e360006781fd57268cee2b9967a52340c99ad26680e8a188f">
  <div class="Popover-message Popover-message--large Popover-message--top-left TagsearchPopover mt-1 mb-4 mx-auto Box box-shadow-large">
    <div class="TagsearchPopover-content js-tagsearch-popover-content overflow-auto" style="will-change:transform;">
    </div>
  </div>
</div>

      <div class="Box-body px-5 pb-5">
        <article class="markdown-body entry-content container-lg" itemprop="text"><h1><a id="user-content-liascript-exporter" class="anchor" aria-hidden="true" href="#liascript-exporter"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M7.775 3.275a.75.75 0 001.06 1.06l1.25-1.25a2 2 0 112.83 2.83l-2.5 2.5a2 2 0 01-2.83 0 .75.75 0 00-1.06 1.06 3.5 3.5 0 004.95 0l2.5-2.5a3.5 3.5 0 00-4.95-4.95l-1.25 1.25zm-4.69 9.64a2 2 0 010-2.83l2.5-2.5a2 2 0 012.83 0 .75.75 0 001.06-1.06 3.5 3.5 0 00-4.95 0l-2.5 2.5a3.5 3.5 0 004.95 4.95l1.25-1.25a.75.75 0 00-1.06-1.06l-1.25 1.25a2 2 0 01-2.83 0z"></path></svg></a>LiaScript-Exporter</h1>
<p>This shall be a generic LiaScript-Exporter that can export educational content
into different formats, so that LiaScript courses can also be utilized in
different Learning Management Systems (LMS) or Readers for static content (PDF,
ePub, ...). At the moment there is only support for SCORM1.2, as the most
wide-spread exchange format. See the last section <a href="#LMS-Support-List">LMS Support List</a></p>
<blockquote>
<p><strong>But</strong>, it is still the easiest way to share your courses via
<strong><code>https://LiaScript.github.io/course/?YOUR_REPO</code></strong>. The LiaScript course
website is a fully fledged "offline-first" Progressive Web App (PWA), which
allows to store all of your courses and states directly within your browser. If
you are comming from Android, you can also directly install the website as an
app on your device. Actually, there is now need for a BackEnd-system anymore,
but if you need to track the progress of you students, you can use this tool...</p>
</blockquote>
<h2><a id="user-content-install" class="anchor" aria-hidden="true" href="#install"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M7.775 3.275a.75.75 0 001.06 1.06l1.25-1.25a2 2 0 112.83 2.83l-2.5 2.5a2 2 0 01-2.83 0 .75.75 0 00-1.06 1.06 3.5 3.5 0 004.95 0l2.5-2.5a3.5 3.5 0 00-4.95-4.95l-1.25 1.25zm-4.69 9.64a2 2 0 010-2.83l2.5-2.5a2 2 0 012.83 0 .75.75 0 001.06-1.06 3.5 3.5 0 00-4.95 0l-2.5 2.5a3.5 3.5 0 004.95 4.95l1.25-1.25a.75.75 0 00-1.06-1.06l-1.25 1.25a2 2 0 01-2.83 0z"></path></svg></a>Install</h2>
<p>At the moment this is a simple command-line tool based on NodeJS, thus you will
have to install NodeJS first, which contains also <code>npm</code> the Node Package
Manager. You can directly download the installer for your system from:</p>
<p><a href="https://nodejs.org/en/download/" rel="nofollow">https://nodejs.org/en/download/</a></p>
<p>Afterwards you can open your terminal and type in the following command, this
will install the LiaScript-Exporter as a global application on your system.</p>
<div class="highlight highlight-source-shell"><pre>$ npm install -g --verbose https://github.com/liaScript/LiaScript-Exporter</pre></div>
<p>Depending on your configuration, you might need to run this command with root
privileges. In my case on Linux it is simply:</p>
<div class="highlight highlight-source-shell"><pre>$ sudo npm install -g --verbose https://github.com/liaScript/LiaScript-Exporter</pre></div>
<p>On Windows you might need to run the terminal with administrator-privileges.</p>
<h2><a id="user-content-basic-usage" class="anchor" aria-hidden="true" href="#basic-usage"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M7.775 3.275a.75.75 0 001.06 1.06l1.25-1.25a2 2 0 112.83 2.83l-2.5 2.5a2 2 0 01-2.83 0 .75.75 0 00-1.06 1.06 3.5 3.5 0 004.95 0l2.5-2.5a3.5 3.5 0 00-4.95-4.95l-1.25 1.25zm-4.69 9.64a2 2 0 010-2.83l2.5-2.5a2 2 0 012.83 0 .75.75 0 001.06-1.06 3.5 3.5 0 00-4.95 0l-2.5 2.5a3.5 3.5 0 004.95 4.95l1.25-1.25a.75.75 0 00-1.06-1.06l-1.25 1.25a2 2 0 01-2.83 0z"></path></svg></a>Basic usage</h2>
<p>If you have installed the package, you can now use <code>liaex</code> or
<code>liascript-exporter</code>. If you type one of the following commands, you will get
the following output.</p>
<div class="highlight highlight-source-shell"><pre>$ liaex
No input defined
LiaScript-Exporter

-h --help            show this <span class="pl-c1">help</span>
-i --input           file to be used as input
-p --path            path to be packed, <span class="pl-k">if</span> not set, the path of the input file is used
-o --output          output file name (default is output), the ending is define by the format
-f --format          scorm1.2, json, fullJson, web (default is json)

-k --key             responsive voice key

SCORM 1.2 settings:

--organization          <span class="pl-c1">set</span> the organization title
--masteryScore          <span class="pl-c1">set</span> the scorm masteryScore (a value between 0 -- 100), default is 80</pre></div>
<h3><a id="user-content-scorm12" class="anchor" aria-hidden="true" href="#scorm12"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M7.775 3.275a.75.75 0 001.06 1.06l1.25-1.25a2 2 0 112.83 2.83l-2.5 2.5a2 2 0 01-2.83 0 .75.75 0 00-1.06 1.06 3.5 3.5 0 004.95 0l2.5-2.5a3.5 3.5 0 00-4.95-4.95l-1.25 1.25zm-4.69 9.64a2 2 0 010-2.83l2.5-2.5a2 2 0 012.83 0 .75.75 0 001.06-1.06 3.5 3.5 0 00-4.95 0l-2.5 2.5a3.5 3.5 0 004.95 4.95l1.25-1.25a.75.75 0 00-1.06-1.06l-1.25 1.25a2 2 0 01-2.83 0z"></path></svg></a>SCORM1.2</h3>
<p>If you want to generate a SCORM1.2 conformant package of you LiaScript-course,
use the following command:</p>
<div class="highlight highlight-source-shell"><pre>$ liaex -i project/README.md --format scorm1.2 --output rockOn

[17:8:33] SCORM <span class="pl-s"><span class="pl-pds">'</span>Init<span class="pl-pds">'</span></span>
[17:8:33] SCORM <span class="pl-s"><span class="pl-pds">'</span>create /tmp/lia202037-30349-o6yx80.zb0eo/pro/imsmanifest.xml<span class="pl-pds">'</span></span>
[17:8:33] SCORM <span class="pl-s"><span class="pl-pds">'</span>create /tmp/lia202037-30349-o6yx80.zb0eo/pro/metadata.xml<span class="pl-pds">'</span></span>
[17:8:33] SCORM <span class="pl-s"><span class="pl-pds">'</span>create /tmp/lia202037-30349-o6yx80.zb0eo/pro/adlcp_rootv1p2.xsd<span class="pl-pds">'</span></span>
[17:8:33] SCORM <span class="pl-s"><span class="pl-pds">'</span>create /tmp/lia202037-30349-o6yx80.zb0eo/pro/ims_xml.xsd<span class="pl-pds">'</span></span>
[17:8:33] SCORM <span class="pl-s"><span class="pl-pds">'</span>create /tmp/lia202037-30349-o6yx80.zb0eo/pro/imscp_rootv1p1p2.xsd<span class="pl-pds">'</span></span>
[17:8:33] SCORM <span class="pl-s"><span class="pl-pds">'</span>create /tmp/lia202037-30349-o6yx80.zb0eo/pro/imsmd_rootv1p2p1.xsd<span class="pl-pds">'</span></span>
[17:8:33] SCORM <span class="pl-s"><span class="pl-pds">'</span>Archiving /tmp/lia202037-30349-o6yx80.zb0eo/pro to rockOn_v1.0.0_2020-04-07.zip<span class="pl-pds">'</span></span>
[17:8:34] SCORM <span class="pl-s"><span class="pl-pds">'</span>rockOn_v1.0.0_2020-04-07.zip 4977779 total bytes<span class="pl-pds">'</span></span>
Done

$ ls
.. rockOn_v1.0.0_2020-04-07.zip ..</pre></div>
<p>The format is <code>scorm1.2</code> and the input folder is <code>project/README.md</code>. All the
content and sub-folders of this folder is then coppied into your SCORM.zip. The
name is defined by your output definition and contains the current version
number of you course as well as the current date.</p>
<p><strong>Text 2 Speech <code>--key</code></strong></p>
<p>If you want to use text2speech, you will have to register your website (where
the scorm package will be served) at <a href="https://responsivevoice.org/" rel="nofollow">https://responsivevoice.org/</a> ... it is free
for educational and non commercial purposes. After your registration, you will
get a key in the format of <code>KluQksUs</code>. To inject this key into your package,
simly add the key as a paramter:</p>
<div class="highlight highlight-source-shell"><pre>$ liaex -i project/README.md --format scorm1.2 --key KluQksUs --output rockOn
...</pre></div>
<p><strong>Mastery Score <code>--masteryScore</code></strong></p>
<p>You can define the percentage of quizzes and surveys a student had to fullfill
in order to accomplish or pass the course by adding the <code>--masteryScore</code>
parameter. Just set it to 0 to allow all to pass the course, otherwise choose a
value between 0 and 100. All quizzes and surveys are treated equally, thus if
your course contains 10 quizzes, every quiz counts as 10%. If you do not set
this paramter, a default value of 80 percent is used.</p>
<div class="highlight highlight-source-shell"><pre>$ liaex -i project/README.md --format scorm1.2 --masteryScore 0 --output rockOn
...</pre></div>
<p><strong>Other Root <code>--path</code></strong></p>
<p>If your README is not in the root of your project, you can also use the <code>--path</code>
paramter to the directory to be coppied into your scorm project. You will still
have to use <code>--input</code> to define the main course document, but his has to be
relative to path paramter.</p>
<p><strong><code>--organization</code></strong></p>
<p>This paramter simply sets the organization paramter in your SCORM imsmanifest file. All other parameters are taken from the course</p>
<h2><a id="user-content-todos--contributions" class="anchor" aria-hidden="true" href="#todos--contributions"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M7.775 3.275a.75.75 0 001.06 1.06l1.25-1.25a2 2 0 112.83 2.83l-2.5 2.5a2 2 0 01-2.83 0 .75.75 0 00-1.06 1.06 3.5 3.5 0 004.95 0l2.5-2.5a3.5 3.5 0 00-4.95-4.95l-1.25 1.25zm-4.69 9.64a2 2 0 010-2.83l2.5-2.5a2 2 0 012.83 0 .75.75 0 001.06-1.06 3.5 3.5 0 00-4.95 0l-2.5 2.5a3.5 3.5 0 004.95 4.95l1.25-1.25a.75.75 0 00-1.06-1.06l-1.25 1.25a2 2 0 01-2.83 0z"></path></svg></a>TODOs &amp; Contributions</h2>
<ul>
<li>
<p>Further exporter</p>
<ul>
<li>SCORM 2004</li>
<li>AICC</li>
<li>xAPI</li>
<li>IMS Cartridge</li>
<li>PDF</li>
<li>ePub</li>
</ul>
</li>
<li>
<p>Integration into the Atom IDE</p>
</li>
<li>
<p>GitHub actions to automate building during push ...</p>
</li>
</ul>
<h3><a id="user-content-custom-extensions" class="anchor" aria-hidden="true" href="#custom-extensions"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M7.775 3.275a.75.75 0 001.06 1.06l1.25-1.25a2 2 0 112.83 2.83l-2.5 2.5a2 2 0 01-2.83 0 .75.75 0 00-1.06 1.06 3.5 3.5 0 004.95 0l2.5-2.5a3.5 3.5 0 00-4.95-4.95l-1.25 1.25zm-4.69 9.64a2 2 0 010-2.83l2.5-2.5a2 2 0 012.83 0 .75.75 0 001.06-1.06 3.5 3.5 0 00-4.95 0l-2.5 2.5a3.5 3.5 0 004.95 4.95l1.25-1.25a.75.75 0 00-1.06-1.06l-1.25 1.25a2 2 0 01-2.83 0z"></path></svg></a>Custom extensions</h3>
<p>If you are interested in creating integrations for other systems by your own,
you can do this, by defining custom connectors for your target system. They are
located at
<a href="https://github.com/liaScript/LiaScript/tree/master/src/javascript/connectors">src/javascript/connectors</a>.
Actually it is a simple class that inherits all methods from <code>Base/Connector</code>,
which have to be changed in accordance to you system.
<strong>I will have to document this</strong></p>
<h2><a id="user-content-lms-support-list" class="anchor" aria-hidden="true" href="#lms-support-list"><svg class="octicon octicon-link" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M7.775 3.275a.75.75 0 001.06 1.06l1.25-1.25a2 2 0 112.83 2.83l-2.5 2.5a2 2 0 01-2.83 0 .75.75 0 00-1.06 1.06 3.5 3.5 0 004.95 0l2.5-2.5a3.5 3.5 0 00-4.95-4.95l-1.25 1.25zm-4.69 9.64a2 2 0 010-2.83l2.5-2.5a2 2 0 012.83 0 .75.75 0 001.06-1.06 3.5 3.5 0 00-4.95 0l-2.5 2.5a3.5 3.5 0 004.95 4.95l1.25-1.25a.75.75 0 00-1.06-1.06l-1.25 1.25a2 2 0 01-2.83 0z"></path></svg></a>LMS Support List</h2>
<p>Most of the data is taken from:</p>
<ul>
<li><a href="https://www.ispringsolutions.com/supported-lms" rel="nofollow">https://www.ispringsolutions.com/supported-lms</a></li>
<li><a href="https://en.wikipedia.org/wiki/List_of_learning_management_systems" rel="nofollow">https://en.wikipedia.org/wiki/List_of_learning_management_systems</a></li>
</ul>
<table>
<thead>
<tr>
<th>LMS</th>
<th>SCORM 1.2</th>
<th>SCORM 2004</th>
<th>xAPI</th>
<th>AICC</th>
<th>CMI-5</th>
<th>IMS</th>
<th>License</th>
</tr>
</thead>
<tbody>
<tr>
<td>Abara LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Absorb LMS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Academy LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Academy Of Mine</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Accessplanit LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Accord LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Activate LMS</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Administrate LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Adobe Captivate Prime LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Agylia LMS</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Alchemy LMS</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Alumn-e LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>aNewSpring LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Asentia LMS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>aTutor</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>open source</td>
</tr>
<tr>
<td>Axis LMS</td>
<td>partial</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>BIStrainer LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>BizLibrary LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Blackboard LMS</td>
<td>full</td>
<td>full</td>
<td>partial</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>BlueVolt LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>BrainCert LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Bridge LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Brightspace LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Business Training TV (by Vocam)</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Buzz LMS (by Agilix)</td>
<td>full</td>
<td>full</td>
<td></td>
<td>partial</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Canvas LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>open source</td>
</tr>
<tr>
<td>CERTPOINT Systems Inc.</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>Chamilo LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>open source</td>
</tr>
<tr>
<td>Claroline</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>open source</td>
</tr>
<tr>
<td>Claromentis LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>chocolateLMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Coggno LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Cognology LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Collaborator LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>ComplianceWire LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Cornerstone LMS</td>
<td>partial</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>CourseMill LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>CoursePark LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Coursepath LMS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Courseplay LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>CourseSites LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>CrossKnowledge Learning Suite</td>
<td>full</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Curatr LMS</td>
<td>partial</td>
<td>partial</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>DigitalChalk LMS</td>
<td>full</td>
<td>no</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Desire2Learn</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td>full</td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>Docebo LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>EasyCampus LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>eCollege</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>Edmodo</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>EduBrite LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>EducationFolder LMS</td>
<td></td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>EduNxt</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>Eduson LMS</td>
<td>partial</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Edvance360 LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Effectus LMS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>eFront LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>open source</td>
</tr>
<tr>
<td>eLeap LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>ELMO</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Elsevier Performance Manager LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Emtrain LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Engrade</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>eSSential LMS</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>eTraining TV (by Vocam)</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Evolve LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Exceed LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>ExpertusONE LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>EZ LCMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Firmwater LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Flora</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Forma LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Geenio LMS</td>
<td>partial</td>
<td>partial</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>GlobalScholar</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>Glow</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>GnosisConnect LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Google Classroom</td>
<td>no</td>
<td>no</td>
<td>no</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>GoSkills LMS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>GO1 LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>GrassBlade LRS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Grovo LMS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>GyrusAim LMS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>HealthStream LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>HotChalk</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>ILIAS LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>iLMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td>open source</td>
</tr>
<tr>
<td>IMC Learning Suite</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Informetica LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Inquisiq R4 LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Intuition Rubicon LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>In2itive LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>ISOtrain LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>iSpring Learn</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>JLMS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>JoomlaLMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Kannu</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>KMI LMS</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>LabVine LMS by LTS Health Learning</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>LAMS</td>
<td>partial</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>open source</td>
</tr>
<tr>
<td>LatitudeLearning LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>LearnConnect LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>LearnDash LMS</td>
<td>no</td>
<td>no</td>
<td>no</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>LearningCart LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>learningCentral LMS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>LearningZen LMS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Learning Locker LRS</td>
<td></td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>learnPro LCMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>LearnUpon LMS</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>LearnWorlds LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Learn-WiseGo LMS</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>LifterLMS</td>
<td></td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Litmos LMS</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>LMS365</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>LON-CAPA</td>
<td>partial</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>open source</td>
</tr>
<tr>
<td>MATRIX LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Meridian LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Mobile Agility LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Moodle LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td>partial</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>MOS Chorus LMS</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Myicourse LMS</td>
<td>partial</td>
<td>partial</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>MySkillpad LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>NEO LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>NetDimensions Learning</td>
<td>full</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Nimble LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Ninth Brain LMS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>OLAT LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>OPAL</td>
<td>full</td>
<td>no</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Open edx</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>open source</td>
</tr>
<tr>
<td>OpenOLAT</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>open source</td>
</tr>
<tr>
<td>Opigno LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Oracle Taleo Learn Cloud Service</td>
<td>full</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Paradiso LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Percepium LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Percolate LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Prosperity LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>RISC's Virtual Training Assistant</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
</tr>
<tr>
<td>Saba LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Sakai LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>SAP SuccessFactors LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>ScholarLMS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Schoology LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>Schoox LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>ShareKnowledge LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Shika LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>SilkRoad LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Simplify LMS</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Skilljar LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Skillsoft</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>SkillsServe LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>SmarterU LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Spongelab</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>SuccessFactors</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>SumTotal LMS (by SkillSoft)</td>
<td>full</td>
<td>full</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>SWAD</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>open source</td>
</tr>
<tr>
<td>SwiftLMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Syberworks LMS</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Syfadis Suite LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Thinking Cap LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>TalentLMS</td>
<td>full</td>
<td>no</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Taleo</td>
<td>full</td>
<td>full</td>
<td></td>
<td>partial</td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>TCManager LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Techniworks LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Thinkific LMS</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>TOPYX LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Torch LMS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Totara LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Udutu LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>UpGraduate LMS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>UpsideLMS</td>
<td>full</td>
<td>full</td>
<td>partial</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Uzity</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>proprietary</td>
</tr>
<tr>
<td>ViewCentral LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>viLMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Vowel LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Watershed LRS</td>
<td></td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Wax LRS</td>
<td></td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>WBTServer LMS</td>
<td></td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>WebCampus LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>WeBWorK</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>open source</td>
</tr>
<tr>
<td>WestNet MLP</td>
<td>partial</td>
<td>partial</td>
<td>partial</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>wizBank e-Learning Platform</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>WizIQ LMS</td>
<td>partial</td>
<td>partial</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Workday LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>WorkWize LMS</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>xapiapps LMS</td>
<td>full</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>360Learning LMS</td>
<td>full</td>
<td>full</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
</tbody>
</table>
</article>
      </div>
  </div>


</div>
    <div class="flex-shrink-0 col-12 col-md-3">


      <div class="BorderGrid BorderGrid--spacious" data-pjax>
        <div class="BorderGrid-row hide-sm hide-md">
          <div class="BorderGrid-cell">
            <h2 class="mb-3 h4">About</h2>

    <p class="f4 mt-3">
      A simple module to export LiaScript docs into other formats...
    </p>


  <h3 class="sr-only">Resources</h3>
  <div class="mt-3">
    <a class="muted-link" href="#readme">
      <svg mr="2" height="16" class="octicon octicon-book mr-2" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M0 1.75A.75.75 0 01.75 1h4.253c1.227 0 2.317.59 3 1.501A3.744 3.744 0 0111.006 1h4.245a.75.75 0 01.75.75v10.5a.75.75 0 01-.75.75h-4.507a2.25 2.25 0 00-1.591.659l-.622.621a.75.75 0 01-1.06 0l-.622-.621A2.25 2.25 0 005.258 13H.75a.75.75 0 01-.75-.75V1.75zm8.755 3a2.25 2.25 0 012.25-2.25H14.5v9h-3.757c-.71 0-1.4.201-1.992.572l.004-7.322zm-1.504 7.324l.004-5.073-.002-2.253A2.25 2.25 0 005.003 2.5H1.5v9h3.757a3.75 3.75 0 011.994.574z"></path></svg>
      Readme
</a>  </div>

  <h3 class="sr-only">License</h3>
  <div class="mt-3">
    <a href="/LiaScript/LiaScript-Exporter/blob/master/LICENSE" class="muted-link" >
      <svg mr="2" height="16" class="octicon octicon-law mr-2" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M8.75.75a.75.75 0 00-1.5 0V2h-.984c-.305 0-.604.08-.869.23l-1.288.737A.25.25 0 013.984 3H1.75a.75.75 0 000 1.5h.428L.066 9.192a.75.75 0 00.154.838l.53-.53-.53.53v.001l.002.002.002.002.006.006.016.015.045.04a3.514 3.514 0 00.686.45A4.492 4.492 0 003 11c.88 0 1.556-.22 2.023-.454a3.515 3.515 0 00.686-.45l.045-.04.016-.015.006-.006.002-.002.001-.002L5.25 9.5l.53.53a.75.75 0 00.154-.838L3.822 4.5h.162c.305 0 .604-.08.869-.23l1.289-.737a.25.25 0 01.124-.033h.984V13h-2.5a.75.75 0 000 1.5h6.5a.75.75 0 000-1.5h-2.5V3.5h.984a.25.25 0 01.124.033l1.29.736c.264.152.563.231.868.231h.162l-2.112 4.692a.75.75 0 00.154.838l.53-.53-.53.53v.001l.002.002.002.002.006.006.016.015.045.04a3.517 3.517 0 00.686.45A4.492 4.492 0 0013 11c.88 0 1.556-.22 2.023-.454a3.512 3.512 0 00.686-.45l.045-.04.01-.01.006-.005.006-.006.002-.002.001-.002-.529-.531.53.53a.75.75 0 00.154-.838L13.823 4.5h.427a.75.75 0 000-1.5h-2.234a.25.25 0 01-.124-.033l-1.29-.736A1.75 1.75 0 009.735 2H8.75V.75zM1.695 9.227c.285.135.718.273 1.305.273s1.02-.138 1.305-.273L3 6.327l-1.305 2.9zm10 0c.285.135.718.273 1.305.273s1.02-.138 1.305-.273L13 6.327l-1.305 2.9z"></path></svg>
        BSD-3-Clause License
    </a>
  </div>

          </div>
        </div>
          <div class="BorderGrid-row">
            <div class="BorderGrid-cell">
              <h2 class="h4 mb-3">
  <a href="/LiaScript/LiaScript-Exporter/releases" class="link-gray-dark no-underline ">
    Releases
</a></h2>

    <a class="link-gray-dark no-underline" href="/LiaScript/LiaScript-Exporter/releases">
      <svg height="16" class="octicon octicon-tag" viewBox="0 0 16 16" version="1.1" width="16" aria-hidden="true"><path fill-rule="evenodd" d="M2.5 7.775V2.75a.25.25 0 01.25-.25h5.025a.25.25 0 01.177.073l6.25 6.25a.25.25 0 010 .354l-5.025 5.025a.25.25 0 01-.354 0l-6.25-6.25a.25.25 0 01-.073-.177zm-1.5 0V2.75C1 1.784 1.784 1 2.75 1h5.025c.464 0 .91.184 1.238.513l6.25 6.25a1.75 1.75 0 010 2.474l-5.026 5.026a1.75 1.75 0 01-2.474 0l-6.25-6.25A1.75 1.75 0 011 7.775zM6 5a1 1 0 100 2 1 1 0 000-2z"></path></svg>
      <span class="text-bold">5</span>
      <span class="text-gray">tags</span>
</a>
            </div>
          </div>
          <div class="BorderGrid-row">
            <div class="BorderGrid-cell">
              <h2 class="h4 mb-3">
  <a href="/orgs/LiaScript/packages?repo_name=LiaScript-Exporter" class="link-gray-dark no-underline ">
    Packages <span title="0" hidden="hidden" class="Counter ">0</span>
</a></h2>


      <div class="text-small">
        No packages published <br>
      </div>



            </div>
          </div>
          <div class="BorderGrid-row" hidden>
            <div class="BorderGrid-cell">
              <include-fragment src="/LiaScript/LiaScript-Exporter/used_by_list" accept="text/fragment+html">
</include-fragment>
            </div>
          </div>
          <div class="BorderGrid-row">
            <div class="BorderGrid-cell">
              <h2 class="h4 mb-3">Languages</h2>
<div class="mb-2">
  <span class="Progress ">
    <span itemprop="keywords" aria-label="JavaScript 100.0" style="background-color: #f1e05a;width: 100.0%;" class="Progress-item "></span>
</span></div>
<ul class="list-style-none">
    <li class="d-inline">
      <a class="d-inline-flex flex-items-center flex-nowrap link-gray no-underline text-small mr-3" href="/LiaScript/LiaScript-Exporter/search?l=javascript"  data-ga-click="Repository, language stats search click, location:repo overview">
        <svg class="octicon octicon-dot-fill mr-2" style="color:#f1e05a;" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8z"></path></svg>
        <span class="text-gray-dark text-bold mr-1">JavaScript</span>
        <span>100.0%</span>
      </a>
    </li>
</ul>

            </div>
          </div>
      </div>

</div></div>

  </div>
</div>

    </main>
  </div>

  </div>


<div class="footer container-xl width-full p-responsive" role="contentinfo">
    <div class="position-relative d-flex flex-row-reverse flex-lg-row flex-wrap flex-lg-nowrap flex-justify-center flex-lg-justify-between pt-6 pb-2 mt-6 f6 text-gray border-top border-gray-light ">
      <ul class="list-style-none d-flex flex-wrap col-12 col-lg-5 flex-justify-center flex-lg-justify-between mb-2 mb-lg-0">
        <li class="mr-3 mr-lg-0">&copy; 2020 GitHub, Inc.</li>
          <li class="mr-3 mr-lg-0"><a data-ga-click="Footer, go to terms, text:terms" href="https://github.com/site/terms">Terms</a></li>
          <li class="mr-3 mr-lg-0"><a data-ga-click="Footer, go to privacy, text:privacy" href="https://github.com/site/privacy">Privacy</a></li>
          <li class="mr-3 mr-lg-0"><a data-ga-click="Footer, go to security, text:security" href="https://github.com/security">Security</a></li>
          <li class="mr-3 mr-lg-0"><a href="https://githubstatus.com/" data-ga-click="Footer, go to status, text:status">Status</a></li>
          <li><a data-ga-click="Footer, go to help, text:help" href="https://docs.github.com">Help</a></li>
      </ul>

      <a aria-label="Homepage" title="GitHub" class="footer-octicon d-none d-lg-block mx-lg-4" href="https://github.com">
        <svg height="24" class="octicon octicon-mark-github" viewBox="0 0 16 16" version="1.1" width="24" aria-hidden="true"><path fill-rule="evenodd" d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"></path></svg>
</a>
      <ul class="list-style-none d-flex flex-wrap col-12 col-lg-5 flex-justify-center flex-lg-justify-between mb-2 mb-lg-0">
          <li class="mr-3 mr-lg-0"><a data-ga-click="Footer, go to contact, text:contact" href="https://github.com/contact">Contact GitHub</a></li>
          <li class="mr-3 mr-lg-0"><a href="https://github.com/pricing" data-ga-click="Footer, go to Pricing, text:Pricing">Pricing</a></li>
        <li class="mr-3 mr-lg-0"><a href="https://docs.github.com" data-ga-click="Footer, go to api, text:api">API</a></li>
        <li class="mr-3 mr-lg-0"><a href="https://services.github.com" data-ga-click="Footer, go to training, text:training">Training</a></li>
          <li class="mr-3 mr-lg-0"><a href="https://github.blog" data-ga-click="Footer, go to blog, text:blog">Blog</a></li>
          <li><a data-ga-click="Footer, go to about, text:about" href="https://github.com/about">About</a></li>
      </ul>
    </div>
  <div class="d-flex flex-justify-center pb-6">
    <span class="f6 text-gray-light"></span>
  </div>
</div>



  <div id="ajax-error-message" class="ajax-error-message flash flash-error">
    <svg class="octicon octicon-alert" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M8.22 1.754a.25.25 0 00-.44 0L1.698 13.132a.25.25 0 00.22.368h12.164a.25.25 0 00.22-.368L8.22 1.754zm-1.763-.707c.659-1.234 2.427-1.234 3.086 0l6.082 11.378A1.75 1.75 0 0114.082 15H1.918a1.75 1.75 0 01-1.543-2.575L6.457 1.047zM9 11a1 1 0 11-2 0 1 1 0 012 0zm-.25-5.25a.75.75 0 00-1.5 0v2.5a.75.75 0 001.5 0v-2.5z"></path></svg>
    <button type="button" class="flash-close js-ajax-error-dismiss" aria-label="Dismiss error">
      <svg class="octicon octicon-x" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M3.72 3.72a.75.75 0 011.06 0L8 6.94l3.22-3.22a.75.75 0 111.06 1.06L9.06 8l3.22 3.22a.75.75 0 11-1.06 1.06L8 9.06l-3.22 3.22a.75.75 0 01-1.06-1.06L6.94 8 3.72 4.78a.75.75 0 010-1.06z"></path></svg>
    </button>
    You can’t perform that action at this time.
  </div>


    <script crossorigin="anonymous" async="async" integrity="sha512-bn/3rKJzBl2H64K38R8KaVcT26vKK7BJQC59lwYc+9fjlHzmy0fwh+hzBtsgTdhIi13dxjzNKWhdSN8WTM9qUw==" type="application/javascript" id="js-conditional-compat" data-src="https://github.githubassets.com/assets/compat-bootstrap-6e7ff7ac.js"></script>
    <script crossorigin="anonymous" integrity="sha512-CxjaMepCmi+z0LTeztU2S8qGD25LyHD6j9t0RSPevy63trFWJVwUM6ipAVLgtpMBBgZ53wq8JPkSeQ6ruaZL2w==" type="application/javascript" src="https://github.githubassets.com/assets/environment-bootstrap-0b18da31.js"></script>
    <script crossorigin="anonymous" async="async" integrity="sha512-DImiAPgQTAkCA4RyCAGFFpx8gPm5ucQbIc8CPplJzZa0pVKUP6kjV+J6eoUznePOu7lTGgU7RkdwX/qsuVWV7w==" type="application/javascript" src="https://github.githubassets.com/assets/vendor-0c89a200.js"></script>
    <script crossorigin="anonymous" async="async" integrity="sha512-Org5Wi1gz9RDCkgl9QAoT4RxCF9a/D8/I57AuHRIlle2Iow1y784MC/SixOxSE1hTQ08eEw9QBmuRO+2D0EfGg==" type="application/javascript" src="https://github.githubassets.com/assets/frameworks-3ab8395a.js"></script>

    <script crossorigin="anonymous" async="async" integrity="sha512-98QaLrGh4KNq7KoHN0RXiRQZRS0e1Cf7xVs9DwexiWwXC8VMb6GULlHBX/tdYF6WB3gZEVJAbsArJBpABG9p2Q==" type="application/javascript" src="https://github.githubassets.com/assets/behaviors-bootstrap-f7c41a2e.js"></script>

      <script crossorigin="anonymous" async="async" integrity="sha512-8hScl0DkWwAjCqAQA50kQOn2QTYfPcKEyJjkKYtjGB88r9GB/6kmBBsneJPgwhW3yewwt64ABgsQGpQSLX8zpg==" type="application/javascript" data-module-id="./contributions-spider-graph.js" data-src="https://github.githubassets.com/assets/contributions-spider-graph-f2149c97.js"></script>
      <script crossorigin="anonymous" async="async" integrity="sha512-tOylDKH5chpzhE2ZsMmrE55TfOBsuEsDe2QvqJyNuSnHWi3o3WYGSctVFSF/UUZ5uTFG+QY51Fv6yCCRNhHIyA==" type="application/javascript" data-module-id="./drag-drop.js" data-src="https://github.githubassets.com/assets/drag-drop-b4eca50c.js"></script>
      <script crossorigin="anonymous" async="async" integrity="sha512-CHxIBga4MYdNaOV87MeweMwh5KGsRHXDorQuhd4PWq6PFxO5ImXzwlgaCKqipERN9dh5ulmafL6PQisq2J7dCg==" type="application/javascript" data-module-id="./jump-to.js" data-src="https://github.githubassets.com/assets/jump-to-087c4806.js"></script>
      <script crossorigin="anonymous" async="async" integrity="sha512-t81wueaXkmyFWg/8jCkbdtX8s/6GWxbdZFyZzW9yQ3DPUbVtBFWGT+1UjYUJRZSdDmhWov/w8qkAxsGTwYrubw==" type="application/javascript" data-module-id="./manage-membership.js" data-src="https://github.githubassets.com/assets/manage-membership-bootstrap-b7cd70b9.js"></script>
      <script crossorigin="anonymous" async="async" integrity="sha512-4/IFeY0KnnbEE96g3TbafnrIClyglViqArtUpkCBPSUmd3g4V6OziUCAaRGJnBQ1Uqu6/njfPWKdVqYFK4sifA==" type="application/javascript" data-module-id="./profile-pins-element.js" data-src="https://github.githubassets.com/assets/profile-pins-element-e3f20579.js"></script>
      <script crossorigin="anonymous" async="async" integrity="sha512-JXSmOrOQXof4xz7y+engxtqrugUopipC5LwEmsfxit4PlVe48UECBUCLuujjIADm1kjb2f/9/azX+qNspSy90w==" type="application/javascript" data-module-id="./randomColor.js" data-src="https://github.githubassets.com/assets/randomColor-2574a63a.js"></script>
      <script crossorigin="anonymous" async="async" integrity="sha512-FOUgzyCYz3T1et4Stcl3MeKUX3mZkQcsMsTQDgBj6/CtW3HrwyGMaCeXGyhSjTGibphNptgZKgDNkvL+O+2uYw==" type="application/javascript" data-module-id="./sortable-behavior.js" data-src="https://github.githubassets.com/assets/sortable-behavior-14e520cf.js"></script>
      <script crossorigin="anonymous" async="async" integrity="sha512-Sqqua2FOZToK8Mzg1e4jBubR6ZCFO0gL2JHjgpqafLawUXr69ffELu+IhApoX5uhWlxXxJ0ooE89ANBMtWiUNA==" type="application/javascript" data-module-id="./tweetsodium.js" data-src="https://github.githubassets.com/assets/tweetsodium-4aaaae6b.js"></script>
      <script crossorigin="anonymous" async="async" integrity="sha512-ESSJw3PgRUFa5pbcX6tK9RegCXQoksTc91dc9nAvhQwqZ3WoVtL1bvwb7bd9Z1ZVdkLgW4idJIMoB6KcvrCNNQ==" type="application/javascript" data-module-id="./user-status-submit.js" data-src="https://github.githubassets.com/assets/user-status-submit-112489c3.js"></script>

    <script crossorigin="anonymous" async="async" integrity="sha512-P/0jNVcAOnXKFBD2DMItd3I0mlTB0TKvyMGyrKKQUztODr0q6ppku3eh+Es23VjU0d6k6/xLQ5ms5CBUCQ/JwA==" type="application/javascript" src="https://github.githubassets.com/assets/repositories-bootstrap-3ffd2335.js"></script>
<script crossorigin="anonymous" async="async" integrity="sha512-ime3v+KeEQSWJ/cYCXzE3RmUtS5BTC/5+2o5fB6TCi2V2PtmFdtODdnbz3uu6/2CmQQcz0v97AVEb1sLLhwZ4g==" type="application/javascript" src="https://github.githubassets.com/assets/github-bootstrap-8a67b7bf.js"></script>
  <div class="js-stale-session-flash flash flash-warn flash-banner" hidden
    >
    <svg class="octicon octicon-alert" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M8.22 1.754a.25.25 0 00-.44 0L1.698 13.132a.25.25 0 00.22.368h12.164a.25.25 0 00.22-.368L8.22 1.754zm-1.763-.707c.659-1.234 2.427-1.234 3.086 0l6.082 11.378A1.75 1.75 0 0114.082 15H1.918a1.75 1.75 0 01-1.543-2.575L6.457 1.047zM9 11a1 1 0 11-2 0 1 1 0 012 0zm-.25-5.25a.75.75 0 00-1.5 0v2.5a.75.75 0 001.5 0v-2.5z"></path></svg>
    <span class="js-stale-session-flash-signed-in" hidden>You signed in with another tab or window. <a href="">Reload</a> to refresh your session.</span>
    <span class="js-stale-session-flash-signed-out" hidden>You signed out in another tab or window. <a href="">Reload</a> to refresh your session.</span>
  </div>
  <template id="site-details-dialog">
  <details class="details-reset details-overlay details-overlay-dark lh-default text-gray-dark hx_rsm" open>
    <summary role="button" aria-label="Close dialog"></summary>
    <details-dialog class="Box Box--overlay d-flex flex-column anim-fade-in fast hx_rsm-dialog hx_rsm-modal">
      <button class="Box-btn-octicon m-0 btn-octicon position-absolute right-0 top-0" type="button" aria-label="Close dialog" data-close-dialog>
        <svg class="octicon octicon-x" viewBox="0 0 16 16" version="1.1" width="16" height="16" aria-hidden="true"><path fill-rule="evenodd" d="M3.72 3.72a.75.75 0 011.06 0L8 6.94l3.22-3.22a.75.75 0 111.06 1.06L9.06 8l3.22 3.22a.75.75 0 11-1.06 1.06L8 9.06l-3.22 3.22a.75.75 0 01-1.06-1.06L6.94 8 3.72 4.78a.75.75 0 010-1.06z"></path></svg>
      </button>
      <div class="octocat-spinner my-6 js-details-dialog-spinner"></div>
    </details-dialog>
  </details>
</template>

  <div class="Popover js-hovercard-content position-absolute" style="display: none; outline: none;" tabindex="0">
  <div class="Popover-message Popover-message--bottom-left Popover-message--large Box box-shadow-large" style="width:360px;">
  </div>
</div>


  </body>
</html>



*/
