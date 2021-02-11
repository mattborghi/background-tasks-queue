import { gql } from '@apollo/client';

export const DELETE_RESULT = gql`
mutation($resultId: Int!) {
  deleteResult(resultId: $resultId) {
    resultId
  }
}
`;

export const CREATE_RESULT = gql`
mutation($name: String!) {
  createResult(name: $name) {
    result {
      id
      name
      value
      createdAt
      status
    }
  }
}
`;
