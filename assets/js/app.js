import css from "../css/app.css"

import "phoenix_html"

window.addEventListener('DOMContentLoaded', () => {
  let source = new EventSource("/sse");

  source.addEventListener('error', () => {
    console.log("errored at " + count + "seconds");
    console.log('SSE state:', source.readyState);
    count = 0;
  });

  source.addEventListener('message', e => {
    console.log("message", e.data);
  });

  window.addEventListener("beforeunload", () => {
    console.log("disconnect");
    source.close();
  });
});
