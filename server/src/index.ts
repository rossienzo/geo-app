import express from "express";
import routes from "./routes";
import http from "http";

const app = express();
const server = http.createServer(app);
  
// configura o ejs	
app.set("view engine", "ejs");
app.set("views", __dirname + "/views");
app.use(express.static(`${__dirname}/public`));

app.use(express.json());
app.use(routes);

server.listen(3000, () => console.log(`Server running in http://localhost:${3000}`));