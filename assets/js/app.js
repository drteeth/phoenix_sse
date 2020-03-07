import css from "../css/app.css"

import "phoenix_html"

window.addEventListener('DOMContentLoaded', () => {
  let idEl = document.getElementById("message-id");
  let valueEl = document.getElementById("stock-value");
  let symbolEl = document.getElementById("stock-symbol");
  let statusEl = document.getElementById("status");

  let source = new EventSource("/sse");

  source.addEventListener('error', e => {
    statusEl.innerText = e;
    console.log("error", e);
    console.log('SSE state:', source.readyState);
  });

  source.addEventListener('message', e => {
    let event = JSON.parse(e.data);
    idEl.innerText = event.id;
    symbolEl.innerText = event.symbol;
    valueEl.innerText = event.value;
  });

  window.addEventListener("beforeunload", () => {
    console.log("disconnect");
    source.close();
  });
});
