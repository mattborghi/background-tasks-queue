import graphene
from graphene_django import DjangoObjectType
from graphql import GraphQLError
from .models import Result
from .ventilator import ventilator
# import random
# from django.db.models import Q


class ResultType(DjangoObjectType):
    class Meta:
        model = Result


class Query(graphene.ObjectType):
    results = graphene.List(ResultType)  # , contract_id=graphene.Int()

    def resolve_results(self, info):  # , contract_id=None
        # if contract_id:
        #     filter = Q(created_by__id__exact=contract_id)
        #     return Result.objects.filter(filter)
        return Result.objects.all()


class CreateResult(graphene.Mutation):
    result = graphene.Field(ResultType)

    class Arguments:
        name = graphene.String(required=True)

    def mutate(self, info, name):
        # result is created with a null value and updated when the value is obtained later
        # result = random.random()
        # TODO: Send a ISALIVE message send(b'0') and check response if there are workers present
        result = Result(
            name=name,
            # created_by=current_contract,
            # result=result,
        )
        result.save()
        ventilator(result.id, name)
        return CreateResult(result=result)
        

# We should add a new update to change name
# also a new one to change status


class UpdateResult(graphene.Mutation):
    result = graphene.Field(ResultType)

    class Arguments:
        result_id = graphene.Int(required=True)
        value = graphene.Float(required=True)

    def mutate(self, info, result_id, value):
        # user = info.context.user
        result = Result.objects.get(id=result_id)

        # if product.used_by_project.created_by != user:
        # raise GraphQLError('Not permitted to update this product.')

        result.value = value
        result.status = "FINISHED"
        
        result.save()  # persist changes
        return UpdateResult(result=result)


class UpdateResultStatus(graphene.Mutation):
    result = graphene.Field(ResultType)

    class Arguments:
        result_id = graphene.Int(required=True)
        status = graphene.String(required=True)

    def mutate(self, info, result_id, status):
        # user = info.context.user
        result = Result.objects.get(id=result_id)

        # if product.used_by_project.created_by != user:
        # raise GraphQLError('Not permitted to update this product.')

        result.status = status

        result.save()  # persist changes
        return UpdateResult(result=result)



class DeleteResult(graphene.Mutation):
    result_id = graphene.Int()

    class Arguments:
        result_id = graphene.Int(required=True)

    def mutate(self, info, result_id):
        # user = info.context.user
        result = Result.objects.get(id=result_id)

        # if result.created_by.created_by != user:
        # raise GraphQLError("Not permitted to delete this result.")

        result.delete()

        return DeleteResult(result_id=result_id)


class Mutation(graphene.ObjectType):
    create_result = CreateResult.Field()
    delete_result = DeleteResult.Field()
    update_result = UpdateResult.Field()
    update_result_status = UpdateResultStatus.Field()
