import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import App from "./App";
import Warning from "./Warning";

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <React.StrictMode>
    {window.innerWidth > 1024 ? <App /> : <Warning />}
  </React.StrictMode>
);
