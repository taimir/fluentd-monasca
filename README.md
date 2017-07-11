# fluentd-monasca
Fluentd output plugin for monasca

## Requirements
* `ruby`
* `td-agent`

## Installation
To install the `fluentd-monasca-output` gem:

    gem build fluentd-monasca-output.gemspec
    gem install fluentd-monasca-output-<version>.gem
    td-agent-gem install fluentd-monasca-output

## Configuration
Example `td-agent.conf` configuration that forwards all logs to monasca:

    <match *.**>
        type copy
        <store>
           @type monasca
           keystone_url <keystone URL>
           monasca_log_api <log API URL>
           monasca_log_api_version v3.0
           username <username>
           password <password>
           domain_id <domain ID>
           project_name <project name>
        </store>
    </match>
