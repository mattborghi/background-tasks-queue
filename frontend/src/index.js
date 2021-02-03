import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';

import { ApolloClient, InMemoryCache } from '@apollo/client';
import { ApolloProvider, createHttpLink } from '@apollo/client';

console.log(process.env.NODE_ENV === 'development' ? 'Development mode' : 'Production mode')

const link = createHttpLink({
  uri: process.env.NODE_ENV === 'development' ? 'http://127.0.0.1:8000/graphql/' : 'https://backend-django-task-queues.herokuapp.com/graphql/',
  credentials: 'same-origin'
});

const client = new ApolloClient({
  link,
  cache: new InMemoryCache({
    typePolicies: {
      Query: {
        fields: {
          results: {
            merge(existing, incoming) {
              return incoming
            }
          },
        }
      }
    }
  }),
});

ReactDOM.render(
  <ApolloProvider client={client}>
    {/* <React.StrictMode> */}
      <App />
    {/* </React.StrictMode> */}
  </ApolloProvider>,
  document.getElementById('root')
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
