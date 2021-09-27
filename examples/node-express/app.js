const express = require('express');

const app = express();

app.get('/', (req, res) => {
  setTimeout(() => res.send('gottem'), 100)
  // res.send('gottem')
})

app.post('/', (req, res) => {
  res.send('postem')
})

app.patch('/', (req, res) => {
  res.send('patchem')
})

app.put('/', (req, res) => {
  res.send('puttem')
})

app.delete('/', (req, res) => {
  res.send('deletem')
})

app.listen(3000, () => {
  console.log('now listening on port 3000')
})
