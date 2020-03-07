class StockView {
  constructor(symbol, element) {
    this.symbol = symbol;
    this.element = element
    this.valueEl = element.getElementsByClassName("value")[0];
    this.idEl = element.getElementsByClassName("id")[0];

    const symbolElement = element.getElementsByClassName("symbol")[0];
    symbolElement.innerText = symbol;
  }

  show() {
    this.element.style.display = "block";
  }

  render(eventId, value) {
    this.idEl.innerText = eventId;
    this.valueEl.innerText = value;
  }

  highlight() {
    this.element.classList.add('active');
  }

  clearHighlight() {
    this.element.classList.remove('active');
  }
}

export default StockView;
