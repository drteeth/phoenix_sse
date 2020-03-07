import css from "../css/app.css"

import "phoenix_html"

window.addEventListener("DOMContentLoaded", () => {
  const idEl = document.getElementById("message-id");
  const valueEl = document.getElementById("stock-value");
  const symbolEl = document.getElementById("stock-symbol");
  const statusEl = document.getElementById("status");
  const injectButton = document.getElementById("inject-stock");

  const source = new EventSource("/sse");

  source.addEventListener("error", e => {
    statusEl.innerText = new Date().toString();
    console.log("error", e);
    console.log("SSE state:", source.readyState);
  });

  source.addEventListener("message", e => {
    const event = JSON.parse(e.data);
    idEl.innerText = event.id;
    symbolEl.innerText = event.symbol;
    valueEl.innerText = event.value;
  });

  window.addEventListener("beforeunload", () => {
    console.log("disconnect");
    source.close();
  });

  injectButton.addEventListener("click", () => {
    const stock = { symbol: "ELXR", value: 1000 };
    post("/api/stocks", stock)
  });

  function post(url, data) {
    var xhr = new XMLHttpRequest();
    xhr.onload = function () {
      if (xhr.status >= 200 && xhr.status < 300) {
        console.log("success!", xhr.status);
      } else {
        console.log("The request failed!");
      }
    };

    xhr.open("POST", "/api/stocks");
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.send(JSON.stringify(data));
  }
});
