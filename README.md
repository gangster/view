# View

Because your Rails views suck and you don't know what to do about it.

## Purpose

It's the most common thing in the world to see shitty ass Rails templates.  And by shitty, I mean:

...You can't fucking find the template you need   
...and when you do find it, the fucker is hundreds of lines long    
...with confusing conditional statements with something like, 10 goddamned if/else branches    
...calling helper methods coming from who the hell knows where    
...and those helper methods are calling other helper methods    
...meanwhile there's @instance variables every goddamn where you look    
...and why exactly are we rendering a collection of 1000 partials here again?    
...and oh shit, each one of these partials include other partials?   
...fucking kill me now.    

And really, the above list barely scratches the surface.  Developers never fail to come up with new
and shameful ways to make their views unmaintainable and painful to work with.

But as Rails developers, it's not our fault.  Well, kind of, but it's just easier to blame the
view architecture Rails ships with, and the conventions it pushes us to follow.  Conventions
that encourage using conditional logic in views, for example.   Or using global helper methods for
any reason whatsoever, being another example.   Need to call a method on an ActiveRecord object and fire off a
database call?  Rails invites your dumb ass to do exactly that.  But by doing so, you violate dozen and one
principles of good object-oriented design, and end up fucking yourself as your application changes and grows.

This gem here is to help you stop fucking yourself.   It does this by giving you two useful abstractions for
organizing your code:  `View::Component` and `View::Presenter`, and they're easy as fuck to use, and I hope
you'll use them.

## Components

### The Basics

At the center of everything is `View::Component`.   In short, it's the building block you've always wanted.
You're welcome.  How do they work?

Defining a component is as simple as writing a class that extends `View::Component` and implementing the `html`
method that returns a string (or an array of strings, more on that later) of markup.  Here's a simple example:

_app/components/fuck_yeah.rb_
```ruby
  class FuckYeah < View::Component
    def html
      content_tag :strong, class: 'blink red' do
        link_to 'Fuck yeah, Components', '#'
      end
    end
  end
```
Components can be invoked from inside your vanilla Rails views using a...wait for it...a global helper method.  I
promise it's the only global helper in this bitch.

_app/views/demo/index.html_ (or whatever)
```erb
<%= component FuckYeah %>
```
_Output:_
```html
<strong class="blink red">
  <a href="#">Fuck yeah, components!</a>
</strong>

```
In the example above, the `content_tag` and `link_to` helpers are used to generate the HTML.   In addition to these helpers,
pretty much any other rails helper you could possibly want is at your disposal.   That also includes the `render` helper, which
will allow you to render erb/haml/slim/whatever templates if that's your jam.  Something like this will be very common in
components that you build:

_app/components/fuck_yeah.rb_
```ruby
  class FuckYeah < View::Component
    def html
      render 'components/fuck_yeah/index'
    end
  end
```

_app/views/components/fuck_yeah/index.html_ (or whatever)

```erb
<strong class="blink red">
  <%= link_to "Fuck yeah, components!", "#" %>
</strong>

```

It's your choice.  There are cases where using `content_tag` and friends make sense, and others where rending templates is
a better option.  Hell, if you wanted to concatenate strings and return that, by all means, be the asshole and do that.

### Component state

Components are stateful.  State is represented as a hash, and you pass that hash to the component when you invoke it.   In most cases,
state will contain references to the instance variables containing your models and what have you.  Another case would include things like
the value of `user_signed_in?` if you're using a gem like devise, and your component needs to know whether the user is signed in or not.

Let's refactor the `FuckYeah` component to render a value we pass in through state instead of a static message.  First, let's take a look
at what that looks like when we're rendering templates.

_app/components/fuck_yeah.rb_
```ruby
  class FuckYeah < View::Component
    def html
      render 'components/fuck_yeah/index'
    end
  end
```
Haha jk lol.  No refactoring needed in the component class.  I'll explain why in a bit. But we do need to update our component invocation
and pass in some state.

_app/views/demo/index.html_ (or whatever)
```erb
<%= component FuckYeah, what: 'burritos' %>
```

And update the template to use the `what` variable.

_app/views/components/fuck_yeah/index.html_ (or whatever)

```erb
<strong class="blink red">
  <%= link_to "Fuck yeah, #{what}!", "#" %>
</strong>

```

_Voilà:_
```html
<strong class="blink red">
  <a href="#">Fuck yeah, burritos!</a>
</strong>

```

That's what's up.  And here's what the `content_tag` implementation would go.

```ruby
  class FuckYeah < View::Component
    def html
      content_tag :strong, class: 'blink red' do
        link_to "Fuck yeah, #{what}!", '#'
      end
    end
  end
```

Fuck yeah, indeed.   Note, you never access the state variable directly.   In the case of templates,
the state is passed down as locals for you automatically. Inside of the components, state keys are
converted to accessor methods which return their corresponding values.  Booyah.


### WORK IN PROGRESS.  MORE TO COME ###
