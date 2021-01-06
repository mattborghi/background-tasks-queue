from django.db import models

# Create your models here.


class Result(models.Model):
    #auto id field
    name = models.CharField(max_length=200)
    created_at = models.DateTimeField(auto_now_add=True)
    # created_by = models.ForeignKey('contracts.Contract', related_name='contract_of_result', on_delete=models.CASCADE)
    value = models.FloatField(null=True)
