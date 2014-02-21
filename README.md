# Alephant::Publisher

Static publishing to S3 based on SQS messages

[![Build Status](https://travis-ci.org/BBC-News/alephant-publisher.png?branch=master)](https://travis-ci.org/BBC-News/alephant-publisher)

[![Dependency Status](https://gemnasium.com/BBC-News/alephant-publisher.png)](https://gemnasium.com/BBC-News/alephant-publisher)

[![Gem Version](https://badge.fury.io/rb/alephant-publisher.png)](http://badge.fury.io/rb/alephant-publisher)

## Dependencies

- JRuby 1.7.8
- An AWS account (you'll need to create):
  - An S3 bucket
  - An SQS Queue (if no sequence id provided then `sequence_id` will be used)
  - A Dynamo DB table (optional, will attempt to create if can't be found)

## Installation

Add this line to your application's Gemfile:

    gem 'alephant-publisher'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install alephant-publisher

## Setup

Ensure you have a `config/aws.yml` in the format:

```yaml
access_key_id: ACCESS_KEY_ID
secret_access_key: SECRET_ACCESS_KEY
```

## Usage

**In your application:**

```rb
require 'alephant'
opts = {
  :s3_bucket_id => 'bucket-id',
  :s3_object_path => 'path/to/object',
  :s3_object_id => 'object_id',
  :table_name => 'your_dynamo_db_table',
  :sqs_queue_id => 'https://your_amazon_sqs_queue_url',
  :sequential_proc => Proc.new { |last_seen_id, data|
    last_seen_id < data["sequence_id"].to_i
  },
  :set_last_seen_proc => Proc.new { |data|
    data["sequence_id"].to_i
  }
}

logger = Logger.new

thread = Alephant::Alephant.new(opts, logger).run!
thread.join
```

logger is optional, and must confirm to the Ruby standard logger interface

Provide a view in a folder (fixtures are optional):

```
└── views
    ├── models
    │   └── foo.rb
    ├── fixtures
    │   └── foo.json
    └── templates
        └── foo.mustache
```

**SQS Message Format**

```json
{
  "content": "hello world",
  "sequential_id": 1
}
```

**foo.rb**

```rb
module MyApp
  module Views
    class Foo < Alephant::Views::Base
      def content
        @data['content']
      end
    end
  end
end
```

**foo.mustache**

```mustache
{{content}}
```

**S3 Output**

```
hello world
```

## Build the gem locally

If you want to test a modified version of the gem within your application without publishing it then you can follow these steps...

- `gem uninstall alephant-publisher`
- `gem build alephant-publisher.gemspec` (this will report the file generated which you reference in the next command)
- `gem install ./alephant-publisher-0.0.9.1-java.gem`

Now you can test the gem from within your application as you've installed the gem from the local version rather than your published version

## Preview Server

`alephant preview`

The included preview server allows you to see the html generated by your
templates, both standalone and in the context of a page.

**Standalone**

`/component/:id/?:fixture?`

### Full page preview

When viewing the component in the context of a page, you'll need to retrieve a
mustache template to provide the page context.

When performing an update a regex is applied to replace the static hostnames in
the retrieved html.

**Environment Variables**

```sh
STATIC_HOST_REGEX="static.(sandbox.dev|int|test|stage|live).yourapp(i)?.com\/"
PREVIEW_TEMPLATE_URL="http://yourapp.com/template"
```

**Example Remote Template**

`id` is the component/folder name  

`template` is the mustache template file name  

`location_in_page` should be something like (for example) `page_head` (specified within a `preview.mustache` file that the consuming application needs to create).

- `http://localhost:4567/component/id/template`
- `http://localhost:4567/preview/id/template/location_in_page`

`alephant update`

**In page**

`/preview/:id/:region/?:fixture?`

## Contributing

1. Fork it ( http://github.com/BBC-News/alephant-publisher/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request