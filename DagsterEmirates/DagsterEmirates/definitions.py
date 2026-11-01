from dagster import Definitions
from dagster_dbt import DbtCliResource
from .assets import DbtEmirates_dbt_assets
from .project import DbtEmirates_project
from .schedules import schedules

defs = Definitions(
    assets=[DbtEmirates_dbt_assets],
    schedules=schedules,
    resources={
        "dbt": DbtCliResource(project_dir=DbtEmirates_project),
    },
)