UPDATE_RESULT_STATUS = """
mutation(\$resultId: Int!, \$status: String!) {
    updateResultStatus(resultId: \$resultId, status: \$status) {
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
"""
