import { gql } from '@apollo/client';

export const GET_ALL_RESULTS = gql`
{
	results {
        id
        name
        value
        code
        createdAt
        status
  }
}
`;