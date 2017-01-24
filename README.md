[![Build Status](https://travis-ci.org/adjust/dumbo.svg?branch=version-1.0.0)](https://travis-ci.org/adjust/dumbo)

# Dumbo - the PostgreSQL Extension-Development Framework

Dumbo has been created to facilitate development of PostgreSQL extensions. This
tool, together with our [pgbundle project](https://github.com/adjust/pgbundle)
makes maintaining and developing a bundle of PostgreSQL extension dependencies
easier.

Dumbo is a framework for an easy PostgreSQL extension development. Some of the
killer features are improved extension version management, automated
upgrade/downgrade migrations generations and ERB templating support.

## Installation

To install Dumbo you can use rubygems' `gem` command from your command line:

    $ gem install dumbo

This should get you sorted instantly but in special system setup you might to
use `sudo` for this command to run.

## Usage

Dumbo comes with an executable, which would be your main interface to the
functionality of the framework.

### Creating a new extension project

For new PG extension projects, Dumbo can generate a directory sceleton and
create the typical files for you.

    $ dumbo new-extension my_data_type

where "my_data_type" is the name for the new PG extension. As a stating point
take a look at the sample function in `sql/sample.sql` as well as the generated
`Makefile`.

You can already build and install your extension using standard `make install`.

TODO: illustrate the default generated file/directory tree!

### Creating a new version

To initialize a new version on an existing extension:

    $ dumbo new-version 0.1.2

Note that keeping to the (major.minor.patch) versioning is required.

    $ dumbo migrations

### Using ERB templates

TODO: illustrate this!

![](http://img1.wikia.nocookie.net/__cb20091210033559/disney/images/7/76/Dumbo-HQ.JPG)

## Contributing

Contributions in form of Pull Request, documentation improvement and/or [issue
reports](https://github.com/adjust/dumbo/issues) are very welcome. To contribute
code:

1. Fork it (http://github.com/adjust/dumbo/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
