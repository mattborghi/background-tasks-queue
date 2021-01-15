UPDATE_RESULT_STATUS = """
mutation(\$resultId: Int!, \$status: String!) {
    updateResultStatus(resultId: \$resultId, status: \$status) {
      result {
        id
        name
        value
        createdAt
        status
      }
    }
  }
"""

UPDATE_RESULT = """
mutation(\$resultId: Int!, \$value: Float!) {
  updateResult(resultId: \$resultId, value: \$value) {
    result {
      id
      name
      value
      createdAt
      status
    }
  }
}
"""