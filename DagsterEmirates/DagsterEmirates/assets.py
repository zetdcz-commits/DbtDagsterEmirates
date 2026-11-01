from dagster import AssetExecutionContext
from dagster_dbt import DbtCliResource, dbt_assets

from .project import DbtEmirates_project


@dbt_assets(manifest=DbtEmirates_project.manifest_path)
def DbtEmirates_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream()
    