import logo from './logo.svg';
import './App.css';

import { useQuery, gql } from '@apollo/client';

const GET_ALL_RESULTS = gql`
{
	results {
        id
        name
        value
        createdAt
        status
  }
}
`;

function App() {
  const { loading, error, data } = useQuery(GET_ALL_RESULTS);

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error :(</p>;

  console.log(data)
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default App;
