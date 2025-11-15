# Ductwork Changelog

## Unreleased

- fix: allow steps to be chained while pipeline is expanded or divided (before collapsing or combining) - before this incorrectly raised a `CollapseError` or `CombineError`
- feat: validate argument(s) passed to step transition DSL methods to be valid step class

## [0.1.0]

- Initial release - see [documentation](https://docs.getductwork.io/) for details
