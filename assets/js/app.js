import css from "../css/app.css"

import "phoenix_html"

window.addEventListener('DOMContentLoaded', () => {
  let source = new EventSource("/sse");

  source.addEventListener('error', e => {
    console.log("error", e);
    console.log('SSE state:', source.readyState);
  });

  source.addEventListener('message', e => {
    console.log("message", e.data);
  });

  window.addEventListener("beforeunload", () => {
    console.log("disconnect");
    source.close();
  });
});
