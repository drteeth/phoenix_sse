class Api {
  addSymbol(symbol) {
    this.post("/api/stocks", { symbol });
  }

  post(url, data) {
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
}

export default Api;
