{# Define a macro called generate_schema_name with arguments custom_schema_name and node #}
{% macro generate_schema_name(custom_schema_name, node) -%}

    {# Set a variable default_schema to the value of target.schema #}
    {%- set default_schema = target.schema -%}

    {# Check if custom_schema_name is None #}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}
        {# Output the default_schema variable if custom_schema_name is None #}

    {# Handle the case where custom_schema_name is not None #}
    {%- else -%}

        {{ custom_schema_name | trim }}
        {# Output custom_schema_name after applying the trim filter to remove leading/trailing whitespace #}

    {# End the if-else block #}
    {%- endif -%}

{# End the macro definition #}
{%- endmacro %}
