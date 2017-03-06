# Clearwater::Styled

Clearwater::Styled is a library that generates components that can be styled using any available CSS styles, including pseudoelements like `:hover` and `:active`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clearwater-styled'
```

And then execute:

    $ bundle

## Usage

After installation, ensure the gem is loaded into memory in your app (either by requiring `clearwater/styled`, calling `Bundler.require`, or if you're using Rails will handle it for you), then you can generate a component class.

For example, let's say we want to create a `button` element, but we have a few variations on buttons for UX purposes. Instead of writing this:

```ruby
button({ style: primary_button_style, onclick: handler }, 'Click me')
```

We instead want to write something more expressive:

```ruby
MyButton.new({ primary: true, onclick: handler }, 'Click me')
```

We can do this simply and have the styles associated with the button component:

```ruby
MyButton = Clearwater::Styled.button(
  # Exactly like inline styles on elements
  font_size: '1em',
  border: '2px solid palevioletred',
  border_radius: '3px',

  background_color: ->props { props.primary && :palevioletred },
  color:            ->props { props.primary ? :white : :palevioletred },

  # Hover state is supported, so let's get weird with it.
  '&:hover' => {
    font_size: '2em',
    background_color: ->props { props.primary && :green },
  },

  # Uses the :active state when the button is clicked
  '&:active' => {
    color: 'blue',
  },
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/clearwater-rb/clearwater-styled. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
