import graphene

import results.schema


class Query(
        results.schema.Query,
        graphene.ObjectType):
    pass


class Mutation(
    results.schema.Mutation,
    graphene.ObjectType,
):
    pass
    # token_auth = graphql_jwt.ObtainJSONWebToken.Field()
    # verify_token = graphql_jwt.Verify.Field()
    # refresh_token = graphql_jwt.Refresh.Field()


schema = graphene.Schema(query=Query, mutation=Mutation)
# instead of using schema.execute() we are going to use GraphiQL.
