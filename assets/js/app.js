import css from "../css/app.css";

import "phoenix_html";
import StockListView from "./stock_list_view";

window.addEventListener("DOMContentLoaded", () => {
  const stocks = new StockListView();

  const source = new EventSource("/sse");

  source.addEventListener("message", e => {
    const event = JSON.parse(e.data);
    stocks.onStockEvent(event);
  });

  source.addEventListener("error", e => {
    statusEl.innerText = new Date().toString();
    console.log("error", e);
  });

  window.addEventListener("beforeunload", () => {
    console.log("disconnect");
    source.close();
  });
});
