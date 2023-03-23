export const setupMatomo = domain => siteId => () => {
  var _paq = window._paq = window._paq || [];
  /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function() {
    var url = "https://" + domain + "/";
    _paq.push(['setTrackerUrl', url + 'matomo.php']);
    _paq.push(['setSiteId', siteId]);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
    g.async = true;
    g.src = url+'matomo.js';
    s.parentNode.insertBefore(g,s);
  })();
};
