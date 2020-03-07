import css from "../css/app.css"

import "phoenix_html"

window.addEventListener("DOMContentLoaded", () => {
  const stockList = document.getElementById('stocks');
  const newStockButton = document.getElementById("new-stock");
  const newStockSymbol = document.getElementById("new-stock-symbol");
  const statusEl = document.getElementById("status");
  const stockTemplate = document.getElementById("stock-template");

  const stockElements = {};

  const source = new EventSource("/sse");

  source.addEventListener("error", e => {
    statusEl.innerText = new Date().toString();
    console.log("error", e);
    console.log("SSE state:", source.readyState);
  });

  source.addEventListener("message", e => {
    const event = JSON.parse(e.data);

    const stockEl = findOrAppendStockElement(event.symbol);

    const valueEl = stockEl.getElementsByClassName("value")[0];
    const symbolEl = stockEl.getElementsByClassName("symbol")[0];
    const idEl = stockEl.getElementsByClassName("id")[0];

    idEl.innerText = event.id;
    symbolEl.innerText = event.symbol;
    valueEl.innerText = event.value;
  });

  window.addEventListener("beforeunload", () => {
    console.log("disconnect");
    source.close();
  });

  newStockButton.addEventListener("click", () => {
    const symbol = newStockSymbol.value

    if (symbol && symbol.length > 0) {
      const stock = { symbol: newStockSymbol.value }
      post("/api/stocks", stock)
      newStockSymbol.value = "";
    }
  });

  function findOrAppendStockElement(symbol) {
    let el = stockElements[symbol];

    if (!el) {
      el = stockTemplate.cloneNode(true);
      el.style.display = "block";
      stockList.appendChild(el);
      stockElements[symbol] = el;
    }

    return el;
  }

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
