const express = require('express')
const app = express()
 
app.get('/', (req, res) => {
  res.send({a:1222})
})
 
app.listen(3000, () => {
  console.log("3000端口启动了")
})