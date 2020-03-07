import StockView from "./stock_view";
import Api from "./api";

class StockListView {
  constructor() {
    this.api = new Api();
    this.views = {};
    this.element = document.getElementById('stocks');
    this.template = document.getElementById("stock-template");
    this.newStockButton = document.getElementById("new-stock");
    this.newStockSymbol = document.getElementById("new-stock-symbol");
    this.newStockButton.addEventListener("click", () => this.addSymbol());
  }

  onStockEvent(event) {
    const stockView = this.findStockView(event.symbol);
    stockView.render(event.id, event.value);
    this.highlightActiveView(stockView);
  }

  addSymbol() {
    const symbol = this.newStockSymbol.value

    if (symbol && symbol.length > 0 && !this.hasSymbol(symbol)) {
      this.api.addSymbol(symbol);
      this.newStockSymbol.value = "";
    }
  }

  findStockView(symbol) {
    return this.views[symbol] || this.cloneTemplate(symbol);
  }

  cloneTemplate(symbol) {
    const element = this.template.cloneNode(true);
    const stockView = new StockView(symbol, element);

    stockView.show();
    this.views[symbol] = stockView;
    this.element.appendChild(element);
    return stockView;
  }

  highlightActiveView(stockView) {
    Object.values(this.views).forEach(v => {
      if(v === stockView) {
        v.highlight();
      } else {
        v.clearHighlight();
      }
    });
  }

  hasSymbol(symbol) {
    return Object.keys(this.views).includes(symbol);
  }
}

export default StockListView;
