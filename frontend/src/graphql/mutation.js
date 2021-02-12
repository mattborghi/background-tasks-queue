import { gql } from '@apollo/client';

export const DELETE_RESULT = gql`
mutation($resultId: Int!) {
  deleteResult(resultId: $resultId) {
    resultId
  }
}
`;

export const CREATE_RESULT = gql`
mutation($name: String!, $code: String!) {
  createResult(name: $name, code: $code) {
    result {
      id
      name
      value
      code
      createdAt
      status
    }
  }
}
`;
