# PBOM

Paper Bill of Materials (PBOM) is a tool to generate a bill of materials for an academic paper. It uses syft to generate an SBOM from a directory of code, git repository or docker image. It then uses the SBOM to generate a bill of materials for the paper. The bill of materials is a list of all the software dependencies used in the paper, including the version of the software and the license.

## Installation

[syft](https://github.com/anchore/syft) is required to generate the SBOM. Install syft using the following command:

```bash
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
```

or alternative options listed in the [syft installation guide](https://github.com/anchore/syft?tab=readme-ov-file#installation)

Install pbom using the following command:

```bash
gem install pbom
```

## Usage

```bash
pbom generate --input /path/to/code --output /path/to/output
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pbom. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/pbom/blob/main/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the Pbom project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/pbom/blob/main/CODE_OF_CONDUCT.md).

## License

AGPL-3.0