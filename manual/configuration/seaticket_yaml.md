# seaticket_config.yaml

Besides [`.env`](./environment_variables.md) for general settings, the `seaticket_config.yaml` is used to specify the detailed configurations of the all components in SeaTicket docker.

## File structure of seaticket_config.yaml

`seaticket_config.yaml` consists of the following sections (i.e., `global` and name of each component):

```yaml
global:
  # ... configurations for all components
seaqa-ai:
  # ... special configurations for seaqa-ai
seaqa-events:
  # ... special configurations for seaqa-events
seaqa-indexer:
  # ... special configurations for seaqa-indexer
seaqa-web:
  # ... special configurations for seaqa-web
```

## Global settings

The global section is generally used to specify configuration items that are common to all SeaTickets components.

### Internal server URLs used for communication between SeaTicket components (cluster only)

In cluster mode, you need to specify the URLs used for internal communication between components via `seaticket_config.yaml`:

```yaml
global:
  # ... other configurations
  SEAQA_AI_INNER_SERVER_URL: http://<your seaqa-ai server host>:8887
  SEAQA_INDEXER_INNER_SERVER_URL: http://<your seaqa-indexer server host>:8888
  SEAQA_EVENTS_INNER_SERVER_URL: http://<your seaqa-events server host>:6001
```

### LLMs configurations

!!! warning "To ensure the SeaTicket service functions normally, please ensure that `seaticket_config.yaml` contains **at least one valid LLM**"

For LLMs configurations, you should configure a list option `LLM_MODELS` in `seaticket_config.yaml`:

```yaml
global:
  LLM_MODELS:
    # <model 1 configuration>
    - type: 'your_llm_provider' # required, please refer https://docs.litellm.ai/docs/providers for the details
      model: 'your_model_id' # required
      url: 'llm_endpoint' # required for some provider (or type)
      key: 'llm_secret_key' # required for non-self deploy LLM server (including OpenAI proxy)
      label: 'display_name' # optional, display name on SeaTicket chat page, default to option `model` if not set
      hidden: false # optional, hidden on SeaTicket chat page but still can be used with API calling and other components, default to `false`
      disable: false # optional, disable this LLM, default to `false`
      tier: # optional (must be one of `low`, `medium`, or `high`.), used to specify the inference strength of the model to facilitate invocation between different tasks. If two LLMs have the same `tier`, only the LLM that specifies that `tier` will be used, as specified by the first item in the `LLM_MODELS` list.
      price: # required only need to specify this when you need to track user token usage.
        input: 1 # dollars / 1 M tokens (non-cached)
        output: 10 # dollars / 1 M tokens

    # <model 2 configuration>
    # - type: ...

    # <model 3 configuration>
    # - type : ...
```

#### LLMs reference configuration

=== "OpenAI"

    ```yaml
    global:
    # ...
    LLM_MODELS:
      - type: openai
        model: <your model-id>  # e.g., gpt-4o-mini
        key: <your openai LLM access key>
    ```

=== "Gemini"

    ```yaml
    global:
    # ...
    LLM_MODELS:
      - type: gemini
        model: <your model-id>  # e.g., gemini-2.5-flash
        key: <your gemini LLM access key>
    ```

=== "Qwen"

    ```yaml
    global:
    # ...
    LLM_MODELS:
      - type: dashscope
        model: <your model-id>  # e.g., qwen3-max
        key: <your qwen LLM access key>
    ```

=== "Deepseek"

    ```yaml
    global:
    # ...
    LLM_MODELS:
      - type: deepseek
        model: <model_id> # e.g. deepseek-chat
        key: <your LLM access key>
    ```

=== "Azure OpenAI"

    ```yaml
    global:
    # ...
    LLM_MODELS:
      - type: azure
        model: <your deployment name>
        url: # your deployment url, leave blank to use default endpoint
        key: <your LLM access key>
    ```

=== "Ollama"

    ```yaml
    global:
    # ...
    LLM_MODELS:
      - type: ollama
        model: <your model-id>
        url: <your LLM endpoint>
        key: <your LLM access key>
    ```

=== "HuggingFace"

    ```yaml
    global:
    # ...
    LLM_MODELS:
      - type: huggingface
        model: <model provider>/<model-id>
        url: <your huggingface API endpoint>
        key: <your huggingface API key>
    ```

=== "Self-proxy OpenAI Server"

    ```yaml
    global:
    # ...
    LLM_MODELS:
      - type: proxy
        model: <model-id>
        url: <your proxy url>
        key: <your proxy virtual key>
    ```

=== "Other"
    Seafile AI utilizes [LiteLLM](https://docs.litellm.ai/docs/) to interact with LLM services. For a complete list of supported LLM providers, please refer to [this documentation](https://docs.litellm.ai/docs/providers). Then fill the following fields in your `seaticket_config.yaml`:

    For example, if you are using a LLM service with ***OpenAI-compatible endpoints***, you should set `type` to `other`, and set other LLM configuration items accurately.

### Embedding model

!!! warning "To ensure the SeaTicket service functions normally, please ensure that `seaticket_config.yaml` has specified embedding model"

The configuration of embedding models is similar to that of an element in the `LLM_MODELS` list:

```yaml
global:
  EMBEDDING_MODEL:
    type: ...
    model: embedding_model_id
    url: embedding_model_endpoint # required for some provider (or type)
    key: embedding_model_secret_key # required for non-self deployment LLM server (including OpenAI-proxy)
    price: 0.02 # dollars / 1 M input tokens, required only need to specify this when you need to track user token usage.
```

## seaqa-ai settings

The following are the default values, normally, you don't need to make any additional settings for this part

```yaml
seaqa-ai:
  COMPLETION_MAX_RETRIES: 2 # Maximum number of chating completion retries with LLM
  TOOL_CALL_MAX_RETRIES: 2 # Maximum number of executing tool retries with LLM
  THOUGHT_PROCESS: # Configure which content to record in the thought process.
    tasks:
      enabled: true
      system_prompt: false
      user_input: true
      user_input_raw: false
    context: false
    tool_details: false
  AI_UTILS_TIER: # The tier level required to configure AI functionality (must be one of `low`, `medium`, and `high`) will be matched in `LLM_MODELS`.
    generate_ticket: low
    generate_summary: low
    rerank_relevance: medium
```

## seaqa-events settings

```yaml
seaqa-events:
  AI_STATS: # optional
    enabled: true # Enable AI tokens usage statistics (default is `true`)
```
