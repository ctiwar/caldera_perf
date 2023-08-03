from grizzly.steps import *

from typing import cast

from grizzly.types import RequestDirection, RequestMethod
from grizzly.types.behave import Context, register_type, then, given, when
from grizzly.steps._helpers import add_request_task, get_task_client, is_template
from grizzly.context import GrizzlyContext
from grizzly.tasks import (
    LogMessageTask,
    WaitTask,
    TransformerTask,
    UntilRequestTask,
    DateTask,
    AsyncRequestGroupTask,
    TimerTask,
    TaskWaitTask,
    LoopTask,
    ConditionalTask,
)

from grizzly_extras.transformer import TransformerContentType


register_type(
    Direction=RequestDirection.from_string,
    Method=RequestMethod.from_string,
    ContentType=TransformerContentType.from_string,
)


@then(u'{method:Method} request to template "{source}" with name "{name}" to endpoint "{endpoint}"')
def step_task_request_file_with_name_endpoint(context: Context, method: RequestMethod, source: str, name: str, endpoint: str) -> None:
    """
    Creates an instance of the {@pylink grizzly.tasks.request} task, where the payload is defined in a template file.

    See {@pylink grizzly.tasks.request} task documentation for more information about arguments.

    Example:

    ``` gherkin
    Then send request "test/request.j2.json" with name "test-send" to endpoint "queue:receive-queue"
    Then post request "test/request.j2.json" with name "test-post" to endpoint "/api/test"
    Then put request "test/request.j2.json" with name "test-put" to endpoint "/api/test"
    ```

    Args:
        method (RequestMethod): type of request
        source (str): path to a template file relative to the directory `requests/`, which **must** exist in the directory the feature file is located
        name (str): name of the requests in logs, can contain variables
        endpoint (str): URI relative to `host` in the scenario, can contain variables and in certain cases `user_class_name` specific parameters
    """
    assert method.direction == RequestDirection.TO, f'{method.name} is not allowed'
    assert context.text is not None, f'step text is not allowed for {method.name}'
    assert not is_template(source), 'source file cannot be a template'
    from test_file import convert_to_json
    convert_to_json(source, context.text)
    add_request_task(context, method=method, source=source+".json", name=name, endpoint=endpoint)