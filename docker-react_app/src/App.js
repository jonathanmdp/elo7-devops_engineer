import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';

class App extends Component {
  render() {
    return (
      <div className="App">
        <div className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h2>Welcome to Infra as code</h2>
          <h3>#DevOps</h3>
        </div>
        <p className="App-intro">
          Para começar, edite <code>src/App.js</code> , salve e reinicie o App.
        </p>
      </div>
    );
  }
}

export default App;
